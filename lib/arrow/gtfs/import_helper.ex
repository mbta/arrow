defmodule Arrow.Gtfs.ImportHelper do
  @moduledoc """
  Helper functions for casting GTFS feed data to Ecto-defined structs.
  """

  @doc """
  Removes the table name prefix commonly included on GTFS field names.

      iex> attrs = %{"stop_id" => "70027", "platform_name" => "Oak Grove", "stop_url" => "https://www.mbta.com/stops/place-north"}
      iex> remove_table_prefix(attrs, "stop")
      %{"id" => "70027", "platform_name" => "Oak Grove", "url" => "https://www.mbta.com/stops/place-north"}

  Pass an `:except` opt with a string or list of strings to exclude specific keys.

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
    prefix_size = String.length(prefix)

    Map.new(attrs, fn {k, v} ->
      if k in except do
        {k, v}
      else
        case k do
          <<^prefix::binary-size(prefix_size), k::binary>> -> {k, v}
          _ -> {k, v}
        end
      end
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
end
