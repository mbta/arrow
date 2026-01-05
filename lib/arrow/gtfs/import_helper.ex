defmodule Arrow.Gtfs.ImportHelper do
  @moduledoc """
  Helper functions for casting GTFS feed data to Ecto-defined structs.
  """

  @type csv_row :: %{String.t() => String.t()}

  @doc """
  Removes the table name prefix commonly included on GTFS field names.

      iex> attrs = %{"stop_id" => "70027", "platform_name" => "Oak Grove", "stop_url" => "https://www.mbta.com/stops/place-north"}
      iex> remove_table_prefix(attrs, "stop")
      %{"id" => "70027", "platform_name" => "Oak Grove", "url" => "https://www.mbta.com/stops/place-north"}

  Pass an `:except` opt with a string or list of strings to preserve specific keys.

      iex> attrs = %{"stop_id" => "70027", "platform_name" => "Oak Grove", "stop_url" => "https://www.mbta.com/stops/place-north"}
      iex> remove_table_prefix(attrs, "stop", except: ["stop_id"])
      %{"stop_id" => "70027", "platform_name" => "Oak Grove", "url" => "https://www.mbta.com/stops/place-north"}

  Careful: This function does not check if it will produce duplicate keys,
  i.e., don't do this:

      remove_table_prefix(%{"x_id" => ..., "id" => ...}, "x")
  """
  @spec remove_table_prefix(map, String.t(), Keyword.t()) :: map
  def remove_table_prefix(attrs, prefix, opts \\ []) when is_map(attrs) do
    except = List.wrap(opts[:except])
    prefix = if String.ends_with?(prefix, "_"), do: prefix, else: "#{prefix}_"

    Map.new(attrs, fn {k, v} ->
      {de_prefix_key(k, prefix, except), v}
    end)
  end

  defp de_prefix_key(k, prefix, except) do
    if k in except do
      k
    else
      case k do
        <<^prefix::binary-size(byte_size(prefix)), k::binary>> -> k
        _ -> k
      end
    end
  end

  @doc """
  Renames the given `old_key` in `map` to `new_key`, if it exists.

  Otherwise, returns the map unchanged.

      iex> rename_key(%{foo: 5}, :foo, :bar)
      %{bar: 5}

      iex> rename_key(%{baz: 6}, :foo, :bar)
      %{baz: 6}
  """
  @spec rename_key(map, term, term) :: map
  def rename_key(map, old_key, new_key) do
    case Map.pop(map, old_key) do
      {nil, map} -> map
      {value, map} -> Map.put(map, new_key, value)
    end
  end

  @doc """
  Calls `String.to_integer/1` on the values of `keys` in `map`.

  This is useful for preprocessing CSV fields corresponding to `Ecto.Enum`-typed schema fields--
  `Ecto.Enum.cast/2` expects either integer or (textual) string values, but the
  values for these CSV fields come in as numeric strings.

      iex> values_to_int(%{"route_type" => "1", "other" => "value"}, ["route_type"])
      %{"route_type" => 1, "other" => "value"}

      iex> values_to_int(%{"route_type" => "1", "other" => "value"}, ["route_type", "exception_type"])
      %{"route_type" => 1, "other" => "value"}

      iex> values_to_int(%{"maybe_empty" => ""}, ["maybe_empty"])
      %{"maybe_empty" => ""}
  """
  @spec values_to_int(map, Enumerable.t(term)) :: map
  def values_to_int(map, keys) do
    Enum.reduce(keys, map, fn k, m ->
      Map.replace_lazy(m, k, fn
        k when byte_size(k) > 0 -> String.to_integer(k)
        "" -> ""
      end)
    end)
  end

  @doc """
  Edits the GTFS-datestamp values under `keys` in `map` to be ISO8601-compliant.

  This is useful for preprocessing CSV fields corresponding to `:date`-typed schema fields--
  Ecto's date type expects incoming strings to be in ISO8601 format.

      iex> map = %{"start_date" => "20240925", "end_date" => "20240926", "blind_date" => "", "other" => "value"}
      iex> values_to_iso8601_datestamp(map, ~w[start_date end_date blind_date double_date])
      %{"start_date" => "2024-09-25", "end_date" => "2024-09-26", "blind_date" => "", "other" => "value"}
  """
  @spec values_to_iso8601_datestamp(map, Enumerable.t(term)) :: map
  def values_to_iso8601_datestamp(map, keys) do
    Enum.reduce(keys, map, fn k, m ->
      Map.replace_lazy(m, k, fn
        <<y::binary-size(4), m::binary-size(2), d::binary-size(2)>> ->
          <<y::binary, ?-, m::binary, ?-, d::binary>>

        "" ->
          ""
      end)
    end)
  end

  @doc """
  Strips metadata and association fields from an Ecto.Schema-defined struct, so
  that it contains only the fields corresponding to its source table's columns.

  (Useful for converting a schema struct to a plain map for use with
  `Repo.insert_all`)

      iex> direction = %Arrow.Gtfs.Direction{
      ...>   __meta__: :meta_stuff_to_be_removed,
      ...>   route: :association_stuff_to_be_removed,
      ...>   route_id: "Orange",
      ...>   direction_id: 0,
      ...>   desc: "South",
      ...>   destination: "Forest Hills"
      ...> }
      iex> schema_struct_to_map(direction)
      %{
        route_id: "Orange",
        direction_id: 0,
        desc: "South",
        destination: "Forest Hills",
      }
  """
  def schema_struct_to_map(%mod{} = schema_struct) do
    Map.take(schema_struct, mod.__schema__(:fields))
  end

  # Maximum number of params supported by Postgres for one statement.
  @max_query_params 65_535
  defp max_query_params, do: @max_query_params

  @doc """
  Chunks a list of maps such that the following holds for each chunk:

      Enum.sum(Enum.map(chunk, &map_size/1)) <= @max_query_params

  Assumes that all maps in the list are the same size as the first one.

  Example / doctest:

      # div(@max_query_params, 26) = 2_520
      iex> row = Map.new(?a..?z, &{<<&1>>, &1})
      iex> values = List.duplicate(row, 6_000)
      iex> chunked = chunk_values(values)
      iex> Enum.count(chunked)
      3
      iex> length(Enum.at(chunked, 0))
      2520
  """
  @spec chunk_values(Enumerable.t(map)) :: list(list(map))
  def chunk_values(values) do
    if Enum.empty?(values) do
      [[]]
    else
      params_per_row = map_size(Enum.at(values, 0))
      rows_per_chunk = div(max_query_params(), params_per_row)
      Stream.chunk_every(values, rows_per_chunk)
    end
  end

  @spec stream_csv_rows(Unzip.t(), String.t()) :: Enumerable.t(csv_row)
  def stream_csv_rows(unzip, filename) do
    unzip
    |> Unzip.file_stream!(filename)
    # Flatten iodata for compatibility with CSV.decode
    |> Stream.flat_map(&flatten_if_list/1)
    |> CSV.decode!(headers: true, validate_row_length: true)
  end

  defp flatten_if_list(list) when is_list(list) do
    List.flatten(list)
  end

  defp flatten_if_list(non_list) do
    [non_list]
  end
end
