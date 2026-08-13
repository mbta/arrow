defmodule ArrowWeb.API.ShuttleRouteView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:destination, :direction_id, :direction_desc, :waypoint, :shape_id])

  has_many :route_stops,
    serializer: ArrowWeb.API.ShuttleRouteStopView,
    include: true

  def shape_id(route, _conn) do
    route.shape.path |> String.split("/") |> List.last("") |> String.replace(".kml", "")
  end
end
