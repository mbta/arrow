defmodule Arrow.Gtfs do
  @moduledoc """
  GTFS import logic.
  """

  require Logger
  alias Arrow.Gtfs.Importable
  alias Arrow.Gtfs.ImportHelper
  alias Arrow.Repo

  @import_timeout_ms 60_000

  @doc """
  Loads a GTFS archive into Arrow's gtfs_* DB tables,
  replacing the previous archive's data.

  Setting `dry_run?` true causes the transaction to be rolled back
  instead of committed, even if all queries succeed.

  Returns:

  - `:ok` on successful import or dry-run
  - `:unchanged` if the archive has the same version as the GTFS data currently stored in the DB
  - `:error` if the import or dry-run failed.
  """
  @spec import(Path.t(), String.t() | nil, boolean) :: :ok | :unchanged | :error
  def import(zip_path, current_version, dry_run? \\ false) do
    zip_file = Unzip.LocalFile.open(zip_path)
    {:ok, unzip} = Unzip.new(zip_file)

    result =
      with :ok <- validate_required_files(unzip),
           :ok <- validate_version_change(unzip, current_version) do
        try do
          {ms, result} = :timer.tc(fn -> import_transaction(unzip, dry_run?) end, :millisecond)

          case result do
            {:ok, _} ->
              Logger.info("GTFS import success elapsed_sec=#{ms / 1000}")
              :ok

            {:error, :dry_run_success} ->
              Logger.info("GTFS dry-run success elapsed_sec=#{ms / 1000}")
              :ok

            {:error, reason} ->
              Logger.warn("GTFS import failure reason=#{inspect(reason)}")
              :error
          end
        rescue
          error ->
            Logger.warn("GTFS import failure message=#{Exception.message(error)}")
            :error
        end
      end

    if result == :unchanged do
      Logger.info("GTFS import skipped due to unchanged version version=\"#{current_version}\"")
    end

    Unzip.LocalFile.close(zip_file)
    result
  end

  defp import_transaction(unzip, dry_run?) do
    Repo.transaction(
      fn ->
        truncate_all()
        import_all(unzip)

        if dry_run? do
          Repo.query!("SET CONSTRAINTS ALL IMMEDIATE")
          Repo.rollback(:dry_run_success)
        end
      end,
      timeout: @import_timeout_ms
    )
  end

  defp truncate_all do
    tables = Enum.map_join(importable_schemas(), ", ", & &1.__schema__(:source))
    Repo.query!("TRUNCATE #{tables}")
  end

  defp import_all(unzip) do
    Enum.each(importable_schemas(), &Importable.import(&1, unzip))
  end

  defp validate_required_files(unzip) do
    files =
      unzip
      |> Unzip.list_entries()
      |> MapSet.new(& &1.file_name)

    if MapSet.subset?(required_files(), files) do
      :ok
    else
      missing =
        MapSet.difference(required_files(), files)
        |> Enum.sort()
        |> Enum.join(",")

      Logger.warn("GTFS archive is missing required file(s) missing=#{missing}")
      :error
    end
  end

  @spec validate_version_change(Unzip.t(), String.t() | nil) :: :ok | :unchanged | :error
  defp validate_version_change(unzip, current_version) do
    unzip
    |> ImportHelper.stream_csv_rows("feed_info.txt")
    |> Enum.at(0, %{})
    |> Map.fetch("feed_version")
    |> case do
      {:ok, ^current_version} ->
        :unchanged

      {:ok, _other_version} ->
        :ok

      :error ->
        Logger.warn("could not find a feed_version value in feed_info.txt")
        :error
    end
  end

  defp importable_schemas do
    # Listed in the order in which they should be imported.
    [
      Arrow.Gtfs.FeedInfo,
      Arrow.Gtfs.Agency,
      Arrow.Gtfs.Checkpoint,
      Arrow.Gtfs.Level,
      Arrow.Gtfs.Line,
      Arrow.Gtfs.Service,
      Arrow.Gtfs.ServiceDate,
      Arrow.Gtfs.Stop,
      Arrow.Gtfs.Shape,
      Arrow.Gtfs.ShapePoint,
      Arrow.Gtfs.Route,
      Arrow.Gtfs.Direction,
      Arrow.Gtfs.RoutePattern,
      Arrow.Gtfs.Trip,
      Arrow.Gtfs.StopTime
    ]
  end

  defp required_files do
    MapSet.new(importable_schemas(), & &1.filename())
  end
end
