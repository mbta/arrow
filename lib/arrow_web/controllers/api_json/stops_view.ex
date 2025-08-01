defmodule ArrowWeb.API.StopsView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  @fields [
    :stop_id,
    :stop_name,
    :stop_desc,
    :platform_code,
    :platform_name,
    :stop_lat,
    :stop_lon,
    :stop_address,
    :zone_id,
    :level_id,
    :parent_station,
    :municipality,
    :on_street,
    :at_street,
    :inserted_at,
    :updated_at
  ]

  def attributes(stop, _) do
    stop
    |> Map.from_struct()
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()
    |> Map.take(@fields)
  end

  def id(stop, _conn), do: stop.id
end
