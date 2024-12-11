defmodule ArrowWeb.API.ShuttleView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:status, :shuttle_name, :disrupted_route_id])

  has_many :routes,
    serializer: ArrowWeb.API.ShuttleRouteView,
    include: true

  has_many :route_stops,
    serializer: ArrowWeb.API.ShuttleStopView,
    include: true
end
