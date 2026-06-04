defmodule Arrow.Gtfs do
  @moduledoc """
  GTFS import and validation logic.
  """
  alias Arrow.Gtfs.Importable
  alias Arrow.Gtfs.JobHelper
  alias Arrow.Repo
  alias Arrow.Repo.ForeignKeyConstraint
  import Ecto.Query

  require Logger

  @import_timeout_ms :timer.minutes(10)

  @doc """
  Loads a GTFS archive into Arrow's gtfs_* DB tables, replacing the previous
  archive's data.

  `job` is the Oban job running this import, or `nil` if the import is being run
  directly, e.g. by `mix import_gtfs`.
  """
  @spec import(Unzip.t(), String.t(), Oban.Job.t() | nil) :: :ok | {:error, term}
  def import(unzip, new_version, job \\ nil) do
    job_info = job && JobHelper.logging_params(job)

    Logger.info("GTFS import job starting #{job_info}")

    current_version =
      Arrow.Repo.one(
        from info in Arrow.Gtfs.FeedInfo, where: info.id == "mbta-ma-us", select: info.version
      )

    with :ok <- validate_required_files(unzip),
         :ok <- validate_version_change(new_version, current_version),
         {:ok, _} <- import_transaction(unzip) do
      Logger.info("GTFS import success #{job_info}")
      :ok
    else
      :unchanged ->
        Logger.info("GTFS import skipped due to unchanged version #{job_info}")
        :ok

      {:error, reason} = error ->
        Logger.warning("GTFS import failed reason=#{inspect(reason)} #{job_info}")
        error
    end
  end

  defp import_transaction(unzip) do
    schemas = importable_schemas()

    transaction = fn ->
      re_add_external_fkeys = drop_external_fkeys()

      truncate(schemas)
      import_feed(unzip, schemas)

      re_add_external_fkeys.()
    end

    {elapsed_ms, result} =
      fn -> Repo.transaction(transaction, timeout: @import_timeout_ms) end
      |> :timer.tc(:millisecond)

    Logger.info("GTFS archive import transaction completed elapsed_ms=#{elapsed_ms}")

    result
  end

  @doc """
  Validates a GTFS feed for relational consistency with Arrow's disruption data.

  `job` is the Oban job running this validation.
  """
  @spec validate(Unzip.t(), Oban.Job.t()) :: :ok | {:error, term}
  def validate(unzip, job) do
    job_info = JobHelper.logging_params(job)

    Logger.info("GTFS validation job starting #{job_info}")

    with :ok <- validate_required_files(unzip),
         {:error, :validation_success} <- validate_transaction(unzip) do
      Logger.info("GTFS validation success #{job_info}")
      :ok
    else
      {:error, reason} = error ->
        Logger.info("GTFS validation failed reason=#{inspect(reason)} #{job_info}")
        error
    end
  end

  defp validate_transaction(unzip) do
    schemas = validation_schemas()

    transaction = fn ->
      re_add_external_fkeys = drop_external_fkeys()
      drop_internal_fkeys()

      truncate(schemas)
      import_feed(unzip, schemas)

      # Only re-add external FKs since we're not concerned with validating the internal consistency of the feed.
      re_add_external_fkeys.()

      # Set any deferred constraints to run now, instead of on transaction commit,
      # since we don't actually commit the transaction for validations.
      _ = Repo.query!("SET CONSTRAINTS ALL IMMEDIATE")
      Repo.rollback(:validation_success)
    end

    {elapsed_ms, result} =
      fn -> Repo.transaction(transaction, timeout: @import_timeout_ms) end
      |> :timer.tc(:millisecond)

    Logger.info("GTFS archive validation transaction completed elapsed_ms=#{elapsed_ms}")

    result
  end

  @spec truncate(list(module)) :: :ok
  defp truncate(schemas) do
    tables = Enum.map_join(schemas, ", ", & &1.__schema__(:source))
    _ = Repo.query!("TRUNCATE #{tables}")
    :ok
  end

  defp import_feed(unzip, schemas_to_import) do
    Enum.each(schemas_to_import, &Importable.import(&1, unzip))
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
        required_files()
        |> MapSet.difference(files)
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
    # All the Ecto schemas that represent GTFS feed tables.
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

  # For validation, only the feed tables that are referenced by FKs from
  # Arrow disruption data tables are imported.
  defp validation_schemas do
    gtfs_tables_referenced_by_external_fkeys =
      get_external_fkeys()
      |> MapSet.new(& &1.referenced_table)

    importable_schemas()
    |> Enum.filter(fn schema ->
      schema.__schema__(:source) in gtfs_tables_referenced_by_external_fkeys
    end)
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

  defp get_internal_fkeys do
    importable_schemas()
    |> Enum.map(& &1.__schema__(:source))
    |> ForeignKeyConstraint.internal_constraints()
  end

  @spec drop_external_fkeys() :: (-> :ok)
  defp drop_external_fkeys do
    # To allow GTFS tables to be truncated, we first need to
    # temporarily drop all foreign key constraints referencing them
    # from non-GTFS tables.
    external_fkeys = get_external_fkeys()

    fkey_names = Enum.map_join(external_fkeys, ",", & &1.name)

    Logger.info(
      "temporarily dropping external foreign keys referencing GTFS tables fkey_names=#{fkey_names}"
    )

    Enum.each(external_fkeys, &ForeignKeyConstraint.drop/1)

    Logger.info("finished dropping external foreign keys referencing GTFS tables")

    re_add_keys = fn ->
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

    re_add_keys
  end

  @spec drop_internal_fkeys() :: :ok
  defp drop_internal_fkeys do
    internal_fkeys = get_internal_fkeys()

    fkey_names = Enum.map_join(internal_fkeys, ",", & &1.name)
    Logger.info("temporarily dropping intra-feed internal foreign keys fkey_names=#{fkey_names}")

    Enum.each(internal_fkeys, &ForeignKeyConstraint.drop/1)
  end
end
