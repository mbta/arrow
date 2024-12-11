defmodule ArrowWeb.API.ShuttleRouteView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:suffix, :destination, :direction_id, :direction_desc, :waypoint])

  has_many :route_stops,
    serializer: ArrowWeb.API.ShuttleStopView,
    include: true
end
