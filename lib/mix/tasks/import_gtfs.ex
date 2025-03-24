defmodule Mix.Tasks.ImportGtfs do
  @moduledoc """
  Mix task to import a GTFS-static feed into the local Arrow database.
  """

  use Mix.Task
  require Logger

  @shortdoc "Imports MBTA_GTFS.zip"
  @impl Mix.Task
  def run(args) do
    with {:ok, gtfs_path} <- fetch_gtfs_path(args),
         {:ok, unzip} <- get_unzip(gtfs_path),
         {:ok, version} <- get_version(unzip) do
      Ecto.Migrator.with_repo(Arrow.Repo, fn _repo ->
        Arrow.Gtfs.import(unzip, version)
      end)
    end
  end

  defp get_version(unzip) do
    unzip
    |> Arrow.Gtfs.ImportHelper.stream_csv_rows("feed_info.txt")
    |> Enum.at(0, %{})
    |> Map.fetch("feed_version")
    |> case do
      {:ok, _version} = success ->
        success

      :error ->
        Mix.shell().error("feed_info.txt is missing or empty")
        :error
    end
  end

  defp get_unzip(gtfs_path) do
    file_access = Unzip.LocalFile.open(gtfs_path)

    case Unzip.new(file_access) do
      {:ok, _unzip} = success ->
        success

      {:error, reason} ->
        Mix.shell().error("Couldn't open feed archive: #{reason}")
        :error
    end
  end

  defp fetch_gtfs_path([path]) do
    expanded = Path.expand(path, File.cwd!())

    cond do
      not File.exists?(expanded) ->
        Mix.shell().error("No such file exists at path: #{expanded} (expanded from #{path})")
        :error

      not File.regular?(expanded) ->
        Mix.shell().error("Path is a directory: #{expanded} (expanded from #{path})")
        :error

      :else ->
        {:ok, expanded}
    end
  end

  defp fetch_gtfs_path([]) do
    Mix.shell().info("No path to MBTA_GTFS.zip provided.")

    cond do
      tmp_file_exists?() and
          Mix.shell().yes?(
            "Would you like to use the feed previously downloaded by this mix task? (timestamp: #{tmp_file_timestamp!()})"
          ) ->
        get_tmp_file_path()

      Mix.shell().yes?("Would you like to download and use the latest feed from #{feed_url()}?") ->
        download_feed()

      :else ->
        Mix.shell().info("Exiting.")
        :error
    end
  end

  defp fetch_gtfs_path(_) do
    task_name = Mix.Task.task_name(__MODULE__)

    Mix.shell().info("""
    Usage: #{task_name} [path/to/MBTA_GTFS.zip]
    If path is not provided, task will attempt to download the feed from #{feed_url()}.
    """)

    :error
  end

  defp download_feed do
    with {:ok, body} <- do_download(),
         {:ok, path} <- get_tmp_file_path(),
         :ok <- write_tmp_file(path, body) do
      {:ok, path}
    end
  end

  defp write_tmp_file(path, contents) do
    case File.write(path, contents) do
      :ok ->
        :ok

      {:error, err} ->
        Mix.shell().error("Failed to write downloaded file to disk. POSIX error code: #{err}")
        :error
    end
  end

  defp tmp_file_exists? do
    case get_tmp_file_path() do
      {:ok, path} -> File.exists?(path)
      :error -> false
    end
  end

  defp tmp_file_timestamp! do
    {:ok, path} = get_tmp_file_path()
    stat = File.stat!(path, time: :posix)
    DateTime.from_unix!(stat.mtime)
  end

  defp get_tmp_file_path do
    case System.tmp_dir() do
      nil ->
        Mix.shell().error("Could not locate your system's tmp directory to save feed in")
        :error

      dir ->
        subdir = Path.join(dir, Mix.Task.task_name(__MODULE__))
        File.mkdir_p!(subdir)
        {:ok, Path.join([subdir, "MBTA_GTFS.zip"])}
    end
  end

  defp do_download do
    fetch_module = Application.get_env(:arrow, :http_client)
    {:ok, _} = fetch_module.start()

    case fetch_module.get(feed_url()) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status_code: code}} ->
        Mix.shell().error("Download failed with status code #{code}")
        :error

      {:error, exception} ->
        Mix.shell().error("Download failed: #{Exception.message(exception)}")
        :error
    end
  end

  defp feed_url, do: "https://cdn.mbta.com/MBTA_GTFS.zip"
end
