defmodule Arrow.Gtfs do
  @moduledoc """
  Loads a GTFS archive into Arrow's gtfs_* DB tables,
  replacing the previous archive's data.
  """

  require Logger
  alias Arrow.Gtfs.ImportHelper
  alias Ecto.Changeset
  alias Arrow.Repo

  def import(zip_path, current_version) do
    zip_file = Unzip.LocalFile.open(zip_path)

    result =
      with {:ok, unzip} <- Unzip.new(zip_file),
           :ok <- validate_required_files(unzip),
           :ok <- validate_version_change(unzip, current_version) do
        try do
          Repo.transaction(fn ->
            # TODO: Deferring constraints may slow the import down.
            #       If so, remove this line.
            Repo.query!("SET CONSTRAINTS ALL DEFERRED")

            truncate_all()
            import_all(unzip)

            Logger.info("Checking deferred constraints")
            Repo.query!("SET CONSTRAINTS ALL IMMEDIATE")
          end)

          :ok
        rescue
          error ->
            Logger.warn("GTFS import transaction failed message=#{Exception.message(error)}")
            :error
        end
      end

    Unzip.LocalFile.close(zip_file)
    result
  end

  defp truncate_all do
    tables =
      Enum.map_join(table_to_importer(), ", ", fn {_, settings} ->
        schema_mod = Keyword.fetch!(settings, :schema)
        schema_mod.__schema__(:source)
      end)

    Repo.query!("TRUNCATE #{tables}")
  end

  defp import_all(unzip) do
    Enum.each(table_to_importer(), &import_table(&1, unzip))
  end

  defp import_table({table, settings}, unzip) do
    schema_mod = Keyword.fetch!(settings, :schema)
    preprocess_rows = Keyword.get(settings, :preprocess, &Function.identity/1)

    unzip
    |> stream_csv_rows(table)
    |> preprocess_rows.()
    # Pass each row through a changeset so we can cast & validate it,
    # then convert back to a plain map for compatibility with Repo.insert_all.
    |> Stream.map(fn row ->
      struct(schema_mod)
      |> schema_mod.changeset(row)
      |> then(fn
        %{action: :ignore_bad_row} ->
          nil

        cs ->
          cs
          |> Changeset.apply_action!(:insert)
          |> ImportHelper.schema_struct_to_map()
      end)
    end)
    |> Stream.reject(&is_nil/1)
    |> ImportHelper.chunk_values()
    |> Enum.each(&Repo.insert_all(schema_mod, &1))
  end

  defp stream_csv_rows(unzip, table) do
    unzip
    |> Unzip.file_stream!(table)
    # Flatten iodata for compatibility with CSV.decode
    |> Stream.flat_map(&List.flatten/1)
    |> CSV.decode!(headers: true)
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

  defp validate_version_change(unzip, current_version) do
    unzip
    |> stream_csv_rows("feed_info.txt")
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

  defp table_to_importer do
    # Listed in the order in which they should be imported.
    [
      feed_info: [schema: Arrow.Gtfs.FeedInfo],
      agency: [schema: Arrow.Gtfs.Agency],
      checkpoints: [schema: Arrow.Gtfs.Checkpoint],
      levels: [schema: Arrow.Gtfs.Level],
      lines: [schema: Arrow.Gtfs.Line],
      calendar: [schema: Arrow.Gtfs.Service],
      calendar_dates: [schema: Arrow.Gtfs.ServiceDate],
      stops: [schema: Arrow.Gtfs.Stop],
      # shapes.txt is imported into gtfs_shapes AND gtfs_shape_points,
      # to properly model the 1:* shape:points relationship.
      # (All fields except shape_id are ignored when importing into gtfs_shapes.)
      shapes: [
        schema: Arrow.Gtfs.Shape,
        preprocess: fn rows -> Stream.uniq_by(rows, & &1["shape_id"]) end
      ],
      shapes: [schema: Arrow.Gtfs.ShapePoint],
      routes: [schema: Arrow.Gtfs.Route],
      directions: [schema: Arrow.Gtfs.Direction],
      route_patterns: [schema: Arrow.Gtfs.RoutePattern],
      trips: [schema: Arrow.Gtfs.Trip],
      stop_times: [schema: Arrow.Gtfs.StopTime]
    ]
    |> Enum.map(fn {table, settings} -> {"#{table}.txt", settings} end)
  end

  defp required_files do
    MapSet.new(table_to_importer(), fn {path, _} -> path end)
  end
end
