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
end
