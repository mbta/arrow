defmodule ArrowWeb.API.ShuttleRouteView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:destination, :direction_id, :direction_desc, :waypoint, :shape_id, :shape_uri])

  has_many :route_stops,
    serializer: ArrowWeb.API.ShuttleRouteStopView,
    include: true

  def shape_id(route, _conn), do: route.shape.name

  def shape_uri(route, _conn), do: "s3://#{route.shape.bucket}/#{route.shape.path}"
end
