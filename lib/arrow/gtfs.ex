defmodule Arrow.Gtfs do
  @moduledoc """
  Loads a GTFS archive into Arrow's gtfs_* DB tables,
  replacing the previous archive's data.
  """

  alias Arrow.Repo

  def import(zip_path) do
    zip_file = Unzip.LocalFile.open(zip_path)

    {:ok, unzip} = Unzip.new(zip_file)

    validate_required_files!(unzip)

    Repo.transaction(fn ->
      truncate_all()
      import_all(unzip)
    end)
  end

  defp truncate_all do
    tables =
      table_to_importer()
      |> Enum.flat_map(fn
        {_, {mods, _import_fn}} -> mods
        {_, mod} -> [mod]
      end)
      |> Enum.map_join(", ", & &1.__schema__(:source))

    Repo.query!("TRUNCATE #{tables}")
  end

  defp import_all(unzip) do
    Enum.each(table_to_importer(), &do_import(unzip, &1))
  end

  defp do_import(unzip, {table, {_mods, import_fn}}) when is_function(import_fn, 1) do
    unzip
    |> stream_csv_rows(table)
    |> import_fn.()
  end

  defp do_import(unzip, {table, schema_mod}) when is_atom(schema_mod) do
    unzip
    |> stream_csv_rows(table)
    # Is this the correct way to create a new record?
    # (Make a changeset starting from a default struct)
    # Instructions
    |> Stream.map(&schema_mod.changeset(struct(schema_mod), &1))
    # TODO: Remove once we figure out what to do about the bad direction rows
    # (See direction.ex for details)
    |> Stream.reject(&(&1.action == :ignore_bad_row))
    |> Enum.each(&Repo.insert!/1)
  end

  defp stream_csv_rows(unzip, table) do
    unzip
    |> Unzip.file_stream!(table)
    # Flatten iodata for compatibility with CSV.decode
    |> Stream.flat_map(&List.flatten/1)
    |> CSV.decode!(headers: true)
  end

  defp validate_required_files!(unzip) do
    files =
      unzip
      |> Unzip.list_entries()
      |> MapSet.new(& &1.file_name)

    required = MapSet.new(required_files())

    unless MapSet.subset?(required, files) do
      missing =
        MapSet.difference(required, files)
        |> Enum.sort()
        |> Enum.join(", ")

      raise "GTFS archive is missing required file(s): #{missing}"
    end
  end

  defp table_to_importer do
    # Listed in the order in which they should be imported.
    [
      feed_info: Arrow.Gtfs.FeedInfo,
      agency: Arrow.Gtfs.Agency,
      checkpoints: Arrow.Gtfs.Checkpoint,
      levels: Arrow.Gtfs.Level,
      lines: Arrow.Gtfs.Line,
      calendar: Arrow.Gtfs.Service,
      calendar_dates: Arrow.Gtfs.ServiceDate,
      stops: Arrow.Gtfs.Stop,
      shapes: {[Arrow.Gtfs.Shape, Arrow.Gtfs.ShapePoint], &import_shapes/1},
      routes: Arrow.Gtfs.Route,
      directions: Arrow.Gtfs.Direction,
      route_patterns: Arrow.Gtfs.RoutePattern,
      trips: Arrow.Gtfs.Trip,
      # stop_times is huge, need to find another way to import it.
      stop_times: Arrow.Gtfs.StopTime
    ]
    |> Enum.map(fn {table, importer} -> {"#{table}.txt", importer} end)
  end

  defp required_files do
    Enum.map(table_to_importer(), fn {path, _} -> path end)
  end

  defp import_shapes(shape_rows) do
    shape_rows
    |> Enum.group_by(& &1["shape_id"])
    |> Enum.each(fn {shape_id, points} ->
      %Arrow.Gtfs.Shape{}
      |> Arrow.Gtfs.Shape.changeset(%{"shape_id" => shape_id})
      |> Repo.insert!()

      ####################################################
      # TODO: Importing points takes too long and causes #
      #       the transaction to time out.               #
      #                                                  #
      #       Is the COPY command a good idea here?      #
      #       Can it be used alongside other statements  #
      #       inside a txn?                              #
      #                                                  #
      #       Is there a way to increase the timeout?    #
      ####################################################

      Enum.each(points, fn point ->
        %Arrow.Gtfs.ShapePoint{}
        |> Arrow.Gtfs.ShapePoint.changeset(point)
        |> Repo.insert!()
      end)
    end)
  end
end
