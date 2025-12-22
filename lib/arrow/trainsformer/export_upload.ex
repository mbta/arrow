defmodule Arrow.Trainsformer.ExportUpload do
  import Ecto.Query, only: [from: 2]

  @moduledoc """
  Functions for validating, parsing, and saving Trainsformer export uploads.
  """

  require Logger

  @type t :: %__MODULE__{
          zip_binary: binary()
        }

  @enforce_keys [:zip_binary]
  defstruct @enforce_keys

  @doc """
  Parses a Trainsformer export and returns extracted data
  """
  @spec extract_data_from_upload(%{path: binary()}, String.t()) ::
          {:ok, {:ok, t()} | {:error, String.t()} | {:invalid_export_stops, [String.t()]}}
  def extract_data_from_upload(%{path: zip_path}, user_id) do
    tmp_dir = ~c"tmp/trainsformer/#{user_id}"
    unzip = Unzip.LocalFile.open(zip_path)

    with {:ok, unzip} <- Unzip.new(unzip),
         :ok <-
           validate_stop_times_in_gtfs(unzip) do
      export_data = %__MODULE__{
        zip_binary: unzip
      }

      {:ok, {:ok, export_data}}
    else
      error ->
        _ = File.rm_rf!(tmp_dir)
        {:ok, error}
    end
  end

  def validate_stop_times_in_gtfs(
        unzip,
        unzip_module \\ Unzip,
        import_helper \\ Arrow.Gtfs.ImportHelper,
        repo \\ Arrow.Repo
      ) do
    [%Unzip.Entry{file_name: stop_times_file}] =
      unzip
      |> unzip_module.list_entries()
      |> Enum.filter(&String.contains?(&1.file_name, "stop_times.txt"))

    trainsformer_stop_ids =
      import_helper.stream_csv_rows(unzip, stop_times_file)
      |> Stream.uniq_by(fn row -> Map.get(row, "stop_id") end)
      |> Enum.map(fn row -> Map.get(row, "stop_id") end)

    gtfs_stop_ids =
      MapSet.new(
        repo.all(
          from s in Arrow.Gtfs.Stop,
            where: s.id in ^trainsformer_stop_ids,
            select: s.id
        )
      )

    stops_missing_from_gtfs =
      Enum.filter(trainsformer_stop_ids, fn stop -> !MapSet.member?(gtfs_stop_ids, stop) end)

    if Enum.any?(stops_missing_from_gtfs) do
      {:error, {:invalid_export_stops, stops_missing_from_gtfs}}
    else
      :ok
    end
  rescue
    e ->
      Logger.warning(
        "Trainsformer.ExportUpload failed to parse zip, message=#{Exception.format(:error, e, __STACKTRACE__)}"
      )

      # Must be wrapped in an ok tuple for caller, consume_uploaded_entry/3
      {:ok,
       {:error, Could not parse zip."}}
  end

  @spec upload_to_s3(binary(), String.t(), String.t() | integer()) ::
          {:ok, String.t()} | {:error, term()}
  def upload_to_s3(file_data, filename, disruption_id) do
    if Application.fetch_env!(:arrow, :trainsformer_export_storage_enabled?) do
      timestamp = System.system_time(:second)
      basename = Path.basename(filename, Path.extname(filename))
      ext = Path.extname(filename)
      modified_filename = "#{timestamp}_#{basename}_disruption_#{disruption_id}#{ext}"
      do_upload(file_data, modified_filename)
    else
      {:ok, "disabled"}
    end
  end

  defp do_upload(file_data, filename) do
    s3_bucket = Application.fetch_env!(:arrow, :trainsformer_export_storage_bucket)
    path = get_upload_path(filename)

    upload_op =
      ExAws.S3.put_object(s3_bucket, path, file_data,
        content_type: "application/zip",
        if_none_match: "*"
      )

    {mod, fun} = Application.fetch_env!(:arrow, :trainsformer_export_storage_request_fn)

    case apply(mod, fun, [upload_op]) do
      {:ok, _} -> {:ok, Path.join(["s3://", s3_bucket, path])}
      {:error, _} = error -> error
    end
  end

  defp get_upload_path(filename) do
    prefix_env = Application.get_env(:arrow, :trainsformer_export_storage_prefix_env)
    s3_prefix = Application.fetch_env!(:arrow, :trainsformer_export_storage_prefix)

    username_prefix =
      if Application.fetch_env!(:arrow, :use_username_prefix?) do
        {username, _} = System.cmd("whoami", [])
        String.trim(username)
      end

    [prefix_env, username_prefix, s3_prefix, filename]
    |> Enum.reject(&is_nil/1)
    |> Path.join()
  defp validate_csvs(
         zip_bin,
         unzip_module \\ Unzip,
         _import_helper \\ Arrow.Gtfs.ImportHelper
       ) do
    {:ok, unzip} = Unzip.new(zip_bin)

    Enum.each(unzip_module.list_entries(unzip), fn entry ->
      # like import_helper.stream_csv_rows(unzip, entry.file_name) with add'l option
      unzip
      |> Unzip.file_stream!(entry.file_name)
      # Flatten iodata for compatibility with CSV.decode
      |> Stream.flat_map(&List.flatten/1)
      |> CSV.decode!(validate_row_length: true)
    end)

    :ok
  end
end
