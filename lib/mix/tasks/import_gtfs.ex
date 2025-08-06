defmodule Mix.Tasks.ImportGtfs do
  @shortdoc "Imports MBTA_GTFS.zip"

  @moduledoc """
  Mix task to import a GTFS-static feed into the local Arrow database.
  """
  use Mix.Task

  require Logger

  @impl Mix.Task
  def run(args) do
    with {:ok, gtfs_path} <- get_gtfs_path(args),
         {:ok, unzip} <- get_unzip(gtfs_path),
         {:ok, version} <- get_version(unzip) do
      Ecto.Migrator.with_repo(Arrow.Repo, fn _repo ->
        Arrow.Gtfs.import(unzip, version)
      end)
    else
      {:info, message} -> Mix.shell().info(message)
      {:error, message} -> Mix.shell().error(message)
    end
  end

  @spec get_gtfs_path([String.t()]) :: {:ok | :error | :info, String.t()}
  defp get_gtfs_path([path]) do
    exp = Path.expand(path, File.cwd!())

    cond do
      not File.exists?(exp) -> {:error, "No file exists at path: #{exp} (expanded from #{path})"}
      not File.regular?(exp) -> {:error, "Path is a directory: #{exp} (expanded from #{path})"}
      :else -> {:ok, exp}
    end
  end

  defp get_gtfs_path([]) do
    Mix.shell().info("No path to MBTA_GTFS.zip provided.")

    use_tmp_dir_feed? = fn ->
      Mix.shell().yes?(
        "Would you like to use the feed previously downloaded by this mix task? (timestamp: #{tmp_file_timestamp!()})"
      )
    end

    use_downloaded_feed? = fn ->
      Mix.shell().yes?("Would you like to download and use the latest feed from #{feed_url()}?")
    end

    cond do
      tmp_file_exists?() and use_tmp_dir_feed?.() -> get_tmp_file_path()
      use_downloaded_feed?.() -> download_feed()
      :else -> {:info, "Exiting."}
    end
  end

  defp get_gtfs_path(_) do
    task_name = Mix.Task.task_name(__MODULE__)

    message = """
    Usage: #{task_name} [path/to/MBTA_GTFS.zip]
    If path is not provided, task will attempt to download the feed from #{feed_url()}.
    """

    {:info, message}
  end

  @spec get_unzip(String.t()) :: {:ok, Unzip.t()} | {:error, String.t()}
  defp get_unzip(gtfs_path) do
    file_access = Unzip.LocalFile.open(gtfs_path)

    case Unzip.new(file_access) do
      {:ok, _unzip} = success -> success
      {:error, reason} -> {:error, "Couldn't open feed archive: #{reason}"}
    end
  end

  @spec get_version(Unzip.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp get_version(unzip) do
    unzip
    |> Arrow.Gtfs.ImportHelper.stream_csv_rows("feed_info.txt")
    |> Enum.at(0, %{})
    |> Map.fetch("feed_version")
    |> case do
      {:ok, _version} = success -> success
      :error -> {:error, "feed_info.txt is missing or empty"}
    end
  end

  @spec download_feed() :: {:ok, String.t()} | {:error, String.t()}
  defp download_feed do
    with {:ok, body} <- do_download(),
         {:ok, path} <- get_tmp_file_path(),
         :ok <- write_tmp_file(path, body) do
      {:ok, path}
    end
  end

  @spec write_tmp_file(String.t(), binary()) :: :ok | {:error, String.t()}
  defp write_tmp_file(path, contents) do
    case File.write(path, contents) do
      :ok -> :ok
      {:error, e} -> {:error, "Failed to write downloaded file to disk. POSIX error code: #{e}"}
    end
  end

  @spec tmp_file_exists?() :: boolean()
  defp tmp_file_exists? do
    case get_tmp_file_path() do
      {:ok, path} -> File.exists?(path)
      {:error, _} -> false
    end
  end

  @spec tmp_file_timestamp!() :: DateTime.t()
  defp tmp_file_timestamp! do
    {:ok, path} = get_tmp_file_path()
    stat = File.stat!(path, time: :posix)
    DateTime.from_unix!(stat.mtime)
  end

  @spec get_tmp_file_path() :: {:ok, String.t()} | {:error, String.t()}
  defp get_tmp_file_path do
    case System.tmp_dir() do
      nil ->
        {:error, "Could not locate your system's tmp directory to save feed in"}

      dir ->
        subdir = Path.join(dir, Mix.Task.task_name(__MODULE__))
        File.mkdir_p!(subdir)
        {:ok, Path.join([subdir, "MBTA_GTFS.zip"])}
    end
  end

  @spec do_download() :: {:ok, binary()} | {:error, String.t()}
  defp do_download do
    fetch_module = Application.get_env(:arrow, :http_client)
    {:ok, _} = fetch_module.start()

    case fetch_module.get(feed_url()) do
      {:ok, %{status_code: 200, body: body}} -> {:ok, body}
      {:ok, %{status_code: code}} -> {:error, "Download failed with status code #{code}"}
      {:error, exception} -> {:error, "Download failed: #{Exception.message(exception)}"}
    end
  end

  defp feed_url, do: "https://cdn.mbta.com/MBTA_GTFS.zip"
end
