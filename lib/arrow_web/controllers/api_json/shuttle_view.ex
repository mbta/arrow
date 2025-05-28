defmodule ArrowWeb.API.ShuttleView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:status, :shuttle_name, :disrupted_route_id, :suffix])

  has_many :routes,
    serializer: ArrowWeb.API.ShuttleRouteView,
    include: true
end
