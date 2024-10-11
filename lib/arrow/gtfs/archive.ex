defmodule Arrow.Gtfs.Archive do
  @moduledoc """
  Functions for reading, uploading, and downloading a GTFS-static zip archive.
  """

  defmodule Config do
    @moduledoc false

    @type t :: %__MODULE__{
            enabled?: boolean,
            bucket: String.t(),
            prefix: String.t(),
            prefix_env: String.t() | nil,
            request_fn: {module, atom}
          }

    @enforce_keys [:enabled?, :bucket, :prefix, :prefix_env, :request_fn]
    defstruct @enforce_keys

    @spec get() :: t()
    def get do
      %__MODULE__{
        enabled?: Application.fetch_env!(:arrow, :gtfs_archive_storage_enabled?),
        bucket: Application.fetch_env!(:arrow, :gtfs_archive_storage_bucket),
        prefix: Application.fetch_env!(:arrow, :gtfs_archive_storage_prefix),
        prefix_env: Application.get_env(:arrow, :gtfs_archive_storage_prefix_env),
        request_fn: Application.fetch_env!(:arrow, :gtfs_archive_storage_request_fn)
      }
    end
  end

  @type t :: %__MODULE__{
          data: iodata,
          fd: :file.fd()
        }

  @enforce_keys [:data, :fd]
  defstruct @enforce_keys

  @spec from_iodata(iodata) :: t()
  def from_iodata(iodata) do
    {:ok, fd} = :file.open(iodata, [:ram, :read])
    %__MODULE__{data: iodata, fd: fd}
  end

  @spec close(t()) :: :ok | {:error, term}
  def close(%__MODULE__{} = archive) do
    :file.close(archive.fd)
  end

  @spec upload_to_s3(iodata) :: {:ok, s3_uri :: String.t()} | {:ok, :disabled} | {:error, term}
  def upload_to_s3(zip_iodata, now \\ DateTime.utc_now()) do
    config = Config.get()

    if config.enabled? do
      do_upload(zip_iodata, config, now)
    else
      {:ok, :disabled}
    end
  end

  defp do_upload(zip_iodata, config, now) do
    path = get_upload_path(config)
    expires_timestamp = get_expires_timestamp(now)

    upload_op =
      zip_iodata
      |> List.wrap()
      |> Stream.map(&IO.iodata_to_binary/1)
      |> ExAws.S3.upload(config.bucket, path,
        expires: expires_timestamp,
        content_type: "application/zip"
      )

    {mod, fun} = config.request_fn

    case apply(mod, fun, [upload_op]) do
      {:ok, _} -> {:ok, Path.join(["s3://", config.bucket, path])}
      {:error, _} = error -> error
    end
  end

  def to_unzip_struct(%Unzip{} = unzip), do: {:ok, unzip}

  def to_unzip_struct(path) when is_binary(path) do
    case URI.new(path) do
      {:ok, %URI{scheme: "s3"} = uri} ->
        unzip_s3(uri)

      {:ok, %URI{scheme: nil, path: path}} when is_binary(path) ->
        unzip_local(path)

      {:error, _} = error ->
        error
    end
  end

  defp unzip_local(path) do
    with :ok <- check_file_exists(path) do
      zip_file = Unzip.LocalFile.open(path)
      Unzip.new(zip_file)
    end
  end

  defp unzip_s3(%URI{host: bucket, path: object_key}) do
    config = Config.get()
    {mod, fun} = config.request_fn

    get_object_op = ExAws.S3.get_object(bucket, object_key)

    case apply(mod, fun, [get_object_op]) do
      {:ok, %{body: zip_data}} ->
        zip_data
        |> List.wrap()
        |> from_iodata()
        |> Unzip.new()

      {:error, _} = error ->
        error
    end
  end

  defp check_file_exists(path) do
    if File.regular?(path),
      do: :ok,
      else: {:error, "Path does not exist, or is a directory: '#{path}'"}
  end

  defp get_upload_path(config) do
    filename = "MBTA_GTFS-#{Ecto.UUID.generate()}.zip"

    [config.prefix_env, config.prefix, filename]
    |> Enum.reject(&is_nil/1)
    |> Path.join()
  end

  defp get_expires_timestamp(utc_now) do
    utc_now
    |> DateTime.add(div(365, 2), :day)
    |> Calendar.strftime("%a, %d %b %Y %X GMT")
  end

  defimpl Unzip.FileAccess do
    def pread(archive, offset, length) do
      case :file.pread(archive.fd, offset, length) do
        {:ok, data} -> {:ok, IO.iodata_to_binary(data)}
        other -> other
      end
    end

    def size(archive) do
      {:ok, IO.iodata_length(archive.data)}
    end
  end
end
