defmodule Arrow.Gtfs do
  @moduledoc """
  GTFS import logic.
  """
  alias Arrow.Gtfs.Importable
  alias Arrow.Gtfs.JobHelper
  alias Arrow.Repo
  alias Arrow.Repo.ForeignKeyConstraint
  import Ecto.Query

  require Logger

  @import_timeout_ms :timer.minutes(10)

  @doc """
  Loads a GTFS archive into Arrow's gtfs_* DB tables,
  replacing the previous archive's data.

  `job` is the Oban job running this import, or `nil` if the import is being
  run directly, e.g. by `mix import_gtfs`.

  Options:
  - `:validate_only?` - Set true to have the transaction roll back
    instead of committing, even if all queries succeed.

  Returns:

  - `:ok` on successful import or validation, or skipped import due to unchanged version.
  - `{:error, reason}` if the import or validation failed.
  """
  @spec import(Unzip.t(), String.t(), Oban.Job.t() | nil, Keyword.t()) ::
          :ok | {:error, term}
  def import(unzip, new_version, job \\ nil, opts \\ []) do
    validate_only? = Keyword.get(opts, :validate_only?, false)
    job_info = job && JobHelper.logging_params(job)

    Logger.info("GTFS import or validation job starting #{job_info}")

    current_version =
      if validate_only? do
        "doesn't matter for validation"
      else
        Arrow.Repo.one(
          from info in Arrow.Gtfs.FeedInfo, where: info.id == "mbta-ma-us", select: info.version
        )
      end

    with :ok <- validate_required_files(unzip),
         :ok <- validate_version_change(new_version, current_version) do
      case import_transaction(unzip, validate_only?) do
        {:ok, _} ->
          Logger.info("GTFS import success #{job_info}")
          :ok

        {:error, :validation_success} ->
          Logger.info("GTFS validation success #{job_info}")
          :ok

        {:error, reason} = error ->
          Logger.warning("GTFS import or validation failed reason=#{inspect(reason)} #{job_info}")

          error
      end
    else
      :unchanged ->
        Logger.info("GTFS import skipped due to unchanged version #{job_info}")

        :ok

      {:error, reason} = error ->
        Logger.warning("GTFS import or validation failed reason=#{inspect(reason)} #{job_info}")

        error
    end
  end

  defp import_transaction(unzip, validate_only?) do
    transaction = fn ->
      external_fkeys = get_external_fkeys()
      drop_external_fkeys(external_fkeys)

      truncate_all()
      import_all(unzip)

      add_external_fkeys(external_fkeys)

      if validate_only? do
        # Set any deferred constraints to run now, instead of on transaction commit,
        # since we don't actually commit the transaction in this case.
        _ = Repo.query!("SET CONSTRAINTS ALL IMMEDIATE")
        Repo.rollback(:validation_success)
      end
    end

    {elapsed_ms, result} =
      fn -> Repo.transaction(transaction, timeout: @import_timeout_ms) end
      |> :timer.tc(:millisecond)

    action = if validate_only?, do: "validation", else: "import"
    Logger.info("GTFS archive #{action} transaction completed elapsed_ms=#{elapsed_ms}")

    result
  end

  @spec truncate_all() :: :ok
  defp truncate_all do
    tables = Enum.map_join(importable_schemas(), ", ", & &1.__schema__(:source))
    _ = Repo.query!("TRUNCATE #{tables}")
    :ok
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

  defp get_external_fkeys do
    importable_schemas()
    |> Enum.map(& &1.__schema__(:source))
    |> ForeignKeyConstraint.external_constraints_referencing_tables()
  end

  @spec drop_external_fkeys(list(ForeignKeyConstraint.t())) :: :ok
  defp drop_external_fkeys(external_fkeys) do
    # To allow all GTFS tables to be truncated, we first need to
    # temporarily drop all foreign key constraints referencing them
    # from non-GTFS tables.
    fkey_names = Enum.map_join(external_fkeys, ",", & &1.name)

    Logger.info(
      "temporarily dropping external foreign keys referencing GTFS tables fkey_names=#{fkey_names}"
    )

    Enum.each(external_fkeys, &ForeignKeyConstraint.drop/1)

    Logger.info("finished dropping external foreign keys referencing GTFS tables")

    :ok
  end

  @spec add_external_fkeys(list(ForeignKeyConstraint.t())) :: :ok
  defp add_external_fkeys(external_fkeys) do
    fkey_names = Enum.map_join(external_fkeys, ",", & &1.name)

    Logger.info(
      "re-adding external foreign keys referencing GTFS tables fkey_names=#{fkey_names}"
    )

    Enum.each(external_fkeys, fn fkey ->
      Logger.info("re-adding foreign key fkey_name=#{fkey.name}")
      ForeignKeyConstraint.add(fkey)
    end)

    Logger.info("finished re-adding external foreign keys referencing GTFS tables")

    :ok
  end
end
