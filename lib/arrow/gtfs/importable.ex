defmodule Arrow.Gtfs.Importable do
  @moduledoc """
  Logic for populating a GTFS table from CSV.

  Callback modules are assumed to also be Ecto schemas.
  """

  alias Arrow.Gtfs.ImportHelper
  alias Arrow.Repo
  alias Ecto.Changeset

  @doc "CSV filename to import from."
  @callback filename :: String.t()

  @doc "How to import this table's data."
  @callback import(Unzip.t()) :: term

  @optional_callbacks import: 1

  #####
  #####
  #####

  @type csv_row :: %{String.t() => String.t()}

  @doc """
  Imports data for the given schema into the DB from a GTFS archive.
  """
  @spec import(module, Unzip.t()) :: term
  def import(importable, unzip) do
    Code.ensure_loaded!(importable)

    if function_exported?(importable, :import, 1) do
      importable.import(unzip)
    else
      default_import(importable, unzip)
    end
  end

  @doc """
  Default import implementation, used if the callback module does not define `import/1`.
  """
  @spec default_import(module, Unzip.t()) :: term
  def default_import(importable, unzip) do
    unzip
    |> ImportHelper.stream_csv_rows(importable.filename())
    |> cast_and_insert(importable)
  end

  @spec cast_and_insert(Enumerable.t(csv_row()), module) :: :ok
  def cast_and_insert(csv_maps, schema_mod) do
    csv_maps
    |> Stream.map(&cast_to_insertable(&1, schema_mod))
    |> ImportHelper.chunk_values()
    |> Enum.each(&Repo.insert_all(schema_mod, &1))
  end

  @doc """
  A more efficient import method that bypasses Ecto schemas and has Postgres
  parse the CSV directly, using the `COPY` command.

  Useful for large files like stop_times.txt.

  Use `:header_mappings` and `:header_order` opts to convert CSV header names to
  DB column names and specify the expected order of the CSV columns, respectively.

  The CSV file's values must all be directly castable to their respective DB
  types.

  Options:

  - `:header_mappings` - A `%{string => string}` map used to replace certain CSV
    headers before they get streamed to Postgres. Only the headers that have
    matching keys in the map will be changed--others will be left alone.
  - `:header_order` - A list of strings specifying the order of the CSV's
    columns. The strings should match, and include all of, the destination
    table's column names. If provided, this will be used to create a column list
    argument for the COPY command. If not provided, no column list will be
    included and CSV column order must match that of the destination table.
  """
  @spec import_using_copy(module, Unzip.t(), Keyword.t()) :: term
  def import_using_copy(importable_schema, unzip, opts \\ []) do
    csv_stream = Unzip.file_stream!(unzip, importable_schema.filename())

    csv_stream =
      case Keyword.fetch(opts, :header_mappings) do
        {:ok, mappings} -> replace_headers(csv_stream, mappings)
        :error -> csv_stream
      end

    column_list =
      case Keyword.fetch(opts, :header_order) do
        {:ok, list} -> "(#{Enum.join(list, ", ")})"
        :error -> ""
      end

    table = importable_schema.__schema__(:source)

    copy_query = """
    COPY "#{table}" #{column_list}
      FROM STDIN
      WITH (FORMAT csv, HEADER MATCH)
    """

    Repo.transaction(fn ->
      db_stream = Ecto.Adapters.SQL.stream(Repo, copy_query)
      Enum.into(csv_stream, db_stream)
    end)
  end

  @spec cast_to_insertable(csv_row(), module) :: %{atom => term}
  defp cast_to_insertable(row, schema) do
    struct(schema)
    |> schema.changeset(row)
    |> Changeset.apply_action!(:insert)
    |> ImportHelper.schema_struct_to_map()
  end

  defp replace_headers(csv_stream, mappings) do
    blob_with_headers = Enum.at(csv_stream, 0) |> to_string()
    adjusted = Regex.replace(~r/[^,\n]+/f, blob_with_headers, &Map.get(mappings, &1, &1))

    Stream.concat([adjusted], Stream.drop(csv_stream, 1))
  end
end
