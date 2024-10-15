defmodule ArrowWeb.API.GtfsImportController do
  use ArrowWeb, :controller

  require Logger
  import Ecto.Query

  @type error_tuple :: {:error, term} | {:error, status :: atom, term}

  @doc """
  When successful, responds with 200 status + JSON body `{"id": integer}` containing the ID of the enqueued job.

  When unsuccessful, responds with non-200 status and an error message in plaintext.
  """
  def enqueue_import(conn, _) do
    enqueue_job(conn, Arrow.Gtfs.ImportWorker)
  end

  @doc """
  When the requested job exists, responds with 200 status + JSON body `{"status": st}` where `st` is one of:
  - "queued"
  - "executing"
  - "success"
  - "failure"
  - "cancelled"

  Responds with 400 status if `id` request param is missing.

  Responds with 404 status if no job exists with the requested `id`.
  """
  def import_status(conn, params) do
    case Map.fetch(params, "id") do
      {:ok, id} -> check_status(conn, id, Arrow.Gtfs.ImportWorker, "import")
      :error -> send_resp(conn, :bad_request, "missing `id` query parameter")
    end
  end

  @doc """
  When successful, responds with 200 status + JSON body `{"id": integer}` containing the ID of the enqueued job.

  When unsuccessful, responds with non-200 status and an error message in plaintext.
  """
  def enqueue_validation(conn, _) do
    enqueue_job(conn, Arrow.Gtfs.ValidationWorker)
  end

  @doc """
  When the requested job exists, responds with 200 status + JSON body `{"status": st}` where `st` is one of:
  - "queued"
  - "executing"
  - "success"
  - "failure"
  - "cancelled"

  Responds with 400 status if `id` request param is missing.

  Responds with 404 status if no job exists with the requested `id`.
  """
  def validation_status(conn, params) do
    case Map.fetch(params, "id") do
      {:ok, id} -> check_status(conn, id, Arrow.Gtfs.ValidationWorker, "validation")
      :error -> send_resp(conn, :bad_request, "missing `id` query parameter")
    end
  end

  @spec to_resp({:ok, term} | error_tuple, Plug.Conn.t()) :: Plug.Conn.t()
  defp to_resp(result, conn) do
    case result do
      {:ok, value} ->
        json(conn, value)

      {:error, status, message} ->
        Logger.warn("GtfsImportController unsuccessful request message=#{inspect(message)}")
        send_resp(conn, status, message)

      {:error, message} ->
        to_resp({:error, :bad_request, message}, conn)
    end
  end

  @spec enqueue_job(Plug.Conn.t(), module) :: Plug.Conn.t()
  defp enqueue_job(conn, worker_mod) do
    with :ok <- validate_zip_file(conn),
         {:ok, zip_iodata, conn} <- read_whole_body(conn),
         {:ok, version} <- get_version(zip_iodata),
         :ok <- validate_no_duplicates(version, worker_mod),
         {:ok, s3_uri} <- upload_zip(zip_iodata) do
      changeset = worker_mod.new(%{s3_uri: s3_uri, archive_version: version})

      case Oban.insert(changeset) do
        {:ok, job} ->
          Logger.info(
            "Job enqueued for GTFS archive job_id=#{job.id} archive_version=\"#{version}\" worker=#{inspect(worker_mod)}"
          )

          {:ok, %{id: job.id}}

        {:error, reason} ->
          {:error, :internal_server_error, "failed to enqueue job, reason: #{reason}"}
      end
      |> to_resp(conn)
    else
      # Returned when `read_whole_body` fails
      {:error, reason, %Plug.Conn{} = conn} -> to_resp({:error, reason}, conn)
      error -> to_resp(error, conn)
    end
  end

  @spec check_status(Plug.Conn.t(), String.t(), module, String.t()) :: Plug.Conn.t()
  defp check_status(conn, id, worker_mod, job_description) do
    worker_name = inspect(worker_mod)

    with {:ok, id} <- parse_job_id(id) do
      job_status =
        Arrow.Repo.one(
          from job in Oban.Job,
            where: job.id == ^id,
            where: job.worker == ^worker_name,
            select: job.state
        )

      report_job_status(job_status, "could not find #{job_description} job with id #{id}")
    end
    |> to_resp(conn)
  end

  @spec report_job_status(String.t() | nil, String.t()) :: {:ok, term} | error_tuple
  defp report_job_status(job_status, not_found_message) do
    case job_status do
      nil -> {:error, :not_found, not_found_message}
      queued when queued in ~w[scheduled available] -> {:ok, %{status: :queued}}
      executing when executing in ~w[executing retryable] -> {:ok, %{status: :executing}}
      "completed" -> {:ok, %{status: :success}}
      "discarded" -> {:ok, %{status: :failure}}
      "cancelled" -> {:ok, %{status: :cancelled}}
    end
  end

  @spec validate_zip_file(Plug.Conn.t()) :: :ok | error_tuple
  defp validate_zip_file(conn) do
    case get_req_header(conn, "content-type") do
      ["application/zip"] ->
        :ok

      [] ->
        {:error, "missing content-type header"}

      [other] ->
        {:error, "expected content-type of application/zip, got: #{other}"}

      others ->
        {:error, "expected a single content-type header, got multiple: #{inspect(others)}"}
    end
  end

  @spec validate_no_duplicates(String.t(), module) :: :ok | error_tuple
  defp validate_no_duplicates(version, worker_mod) do
    worker_name = inspect(worker_mod)

    duplicates =
      Arrow.Repo.all(
        from job in Oban.Job,
          where: job.state not in ~w[completed discarded cancelled],
          where: job.worker == ^worker_name,
          where: job.args["archive_version"] == ^version
      )

    if duplicates == [] do
      :ok
    else
      {:error,
       "duplicate pending or active job exists for archive with version \"#{version}\", worker #{inspect(worker_mod)}"}
    end
  end

  @spec get_version(iodata) :: {:ok, String.t()} | error_tuple
  defp get_version(zip_iodata) do
    with {:ok, unzip} <- get_unzip(zip_iodata) do
      unzip
      |> Arrow.Gtfs.ImportHelper.stream_csv_rows("feed_info.txt")
      |> Enum.at(0, %{})
      |> Map.fetch("feed_version")
      |> case do
        {:ok, _version} = success -> success
        :error -> {:error, "feed_info.txt is missing or empty"}
      end
    end
  end

  @spec get_unzip(iodata) :: {:ok, Unzip.t()} | error_tuple
  defp get_unzip(zip_iodata) do
    zip_iodata
    |> Arrow.Gtfs.Archive.from_iodata()
    |> Unzip.new()
    |> case do
      {:ok, _} = success -> success
      {:error, reason} -> {:error, "could not read zip file, reason: #{inspect(reason)}"}
    end
  end

  @spec read_whole_body(Plug.Conn.t()) ::
          {:ok, iodata, Plug.Conn.t()} | {:error, String.t(), Plug.Conn.t()}
  defp read_whole_body(conn, acc \\ []) do
    case read_body(conn) do
      {:more, chunk, conn} ->
        read_whole_body(conn, [acc, chunk])

      {:ok, chunk, conn} ->
        {:ok, [acc, chunk], conn}

      {:error, reason} ->
        {:error, "could not read request body, reason: #{inspect(reason)}", conn}
    end
  end

  @spec upload_zip(iodata) :: {:ok, String.t()} | error_tuple
  defp upload_zip(zip_iodata) do
    case Arrow.Gtfs.Archive.upload_to_s3(zip_iodata) do
      {:ok, _s3_uri} = success ->
        success

      {:error, reason} ->
        {:error, :internal_server_error,
         "failed to upload archive to S3, reason: #{inspect(reason)}"}
    end
  end

  @spec parse_job_id(integer | String.t()) :: {:ok, integer} | error_tuple
  defp parse_job_id(id) when is_integer(id), do: {:ok, id}

  defp parse_job_id(string) when is_binary(string) do
    case Integer.parse(string) do
      {id, ""} -> {:ok, id}
      _ -> {:error, "id must be an integer or an integer-parsble string, got: \"#{string}\""}
    end
  end
end
