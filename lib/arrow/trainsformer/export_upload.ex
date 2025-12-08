defmodule Arrow.Trainsformer.ExportUpload do
  @moduledoc """
  Functions for validating, parsing, and saving Trainsformer export uploads.
  """

  @type t :: %__MODULE__{
          zip_binary: binary()
        }

  @enforce_keys [:zip_binary]
  defstruct @enforce_keys

  @filenames [
    ~c"multi_route_trips.txt",
    ~c"stop_times.txt",
    ~c"transfers.txt",
    ~c"trips.txt"
  ]

  @doc """
  Parses a Trainsformer export and returns extracted data
  """
  @spec extract_data_from_upload(%{path: binary()}, String.t()) ::
          {:ok, {:ok, t()} | {:error, String.t()}}
  def extract_data_from_upload(%{path: zip_path}, user_id) do
    tmp_dir = ~c"tmp/trainsformer/#{user_id}"

    with {:ok, zip_bin} <- File.read(zip_path),
         {:ok, _unzipped_file_list} <- :zip.unzip(zip_bin, file_list: @filenames, cwd: tmp_dir) do
      _ = File.rm_rf!(tmp_dir)

      export_data = %__MODULE__{
        zip_binary: zip_bin
      }

      {:ok, {:ok, export_data}}
    else
      {:error, error} ->
        _ = File.rm_rf!(tmp_dir)
        {:ok, {:error, error}}
    end
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
  end
end
