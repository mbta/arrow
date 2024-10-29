defmodule Arrow.Gtfs do
  @moduledoc """
  GTFS import logic.
  """

  require Logger
  alias Arrow.Gtfs.Importable
  alias Arrow.Repo

  @import_timeout_ms :timer.minutes(10)

  @doc """
  Loads a GTFS archive into Arrow's gtfs_* DB tables,
  replacing the previous archive's data.

  Setting `dry_run?` true causes the transaction to be rolled back
  instead of committed, even if all queries succeed.

  Returns:

  - `:ok` on successful import or dry-run, or skipped import due to unchanged version.
  - `{:error, reason}` if the import or dry-run failed.
  """
  @spec import(Unzip.t(), String.t(), String.t() | nil, Oban.Job.t(), boolean) ::
          :ok | {:error, term}
  def import(unzip, new_version, current_version, job, dry_run? \\ false) do
    Logger.info("GTFS import or validation job starting #{job_logging_params(job)}")

    with :ok <- validate_required_files(unzip),
         :ok <- validate_version_change(new_version, current_version) do
      case import_transaction(unzip, dry_run?) do
        {:ok, _} ->
          Logger.info("GTFS import success #{job_logging_params(job)}")
          :ok

        {:error, :dry_run_success} ->
          Logger.info("GTFS validation success #{job_logging_params(job)}")
          :ok

        {:error, reason} = error ->
          Logger.warning(
            "GTFS import or validation failed #{job_logging_params(job)} reason=#{inspect(reason)}"
          )

          error
      end
    else
      :unchanged ->
        Logger.info("GTFS import skipped due to unchanged version #{job_logging_params(job)}")

        :ok

      {:error, reason} = error ->
        Logger.warning(
          "GTFS import or validation failed #{job_logging_params(job)} reason=#{inspect(reason)}"
        )

        error
    end
  end

  defp job_logging_params(job) do
    s3_object_key =
      job.args
      |> Map.fetch!("s3_uri")
      |> URI.parse()
      |> then(& &1.path)

    archive_version = Map.fetch!(job.args, "archive_version")

    "job_id=#{job.id} archive_s3_object_key=#{s3_object_key} archive_version=\"#{archive_version}\" job_worker=#{job.worker}"
  end

  defp import_transaction(unzip, dry_run?) do
    transaction = fn ->
      _ = truncate_all()
      import_all(unzip)

      if dry_run? do
        # Set any deferred constraints to run now, instead of on transaction commit,
        # since we don't actually commit the transaction in this case.
        _ = Repo.query!("SET CONSTRAINTS ALL IMMEDIATE")
        Repo.rollback(:dry_run_success)
      end
    end

    {elapsed_ms, result} =
      fn -> Repo.transaction(transaction, timeout: @import_timeout_ms) end
      |> :timer.tc(:millisecond)

    action = if dry_run?, do: "validation", else: "import"
    Logger.info("GTFS archive #{action} transaction completed elapsed_ms=#{elapsed_ms}")

    result
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

      {:error, "GTFS archive is missing required file(s) missing=#{missing}"}
    end
  end

  @spec validate_version_change(String.t(), String.t() | nil) :: :ok | :unchanged
  defp validate_version_change(new_version, current_version)

  defp validate_version_change(version, version), do: :unchanged
  defp validate_version_change(_new_version, _current_version), do: :ok

  defp importable_schemas do
    # Listed in the order in which they should be imported.
    [
      Arrow.Gtfs.FeedInfo,
      Arrow.Gtfs.Agency,
      Arrow.Gtfs.Checkpoint,
      Arrow.Gtfs.Level,
      Arrow.Gtfs.Line,
      Arrow.Gtfs.Service,
      Arrow.Gtfs.Calendar,
      Arrow.Gtfs.CalendarDate,
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
    importable_schemas()
    |> Enum.flat_map(& &1.filenames())
    |> MapSet.new()
  end
end
