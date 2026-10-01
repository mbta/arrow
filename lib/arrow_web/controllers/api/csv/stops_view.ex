defmodule ArrowWeb.API.CSV.StopsView do
  @fields [
    :stop_id,
    :stop_code,
    :stop_name,
    :stop_desc,
    :platform_code,
    :platform_name,
    :stop_lat,
    :stop_lon,
    :stop_address,
    :zone_id,
    :stop_url,
    :level_id,
    :location_type,
    :parent_station,
    :wheelchair_boarding,
    :municipality,
    :on_street,
    :at_street,
    :vehicle_type
  ]

  def index(%{stops: data}) do
    data |> CSV.encode(headers: @fields) |> Enum.to_list()
  end
end
