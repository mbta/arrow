defmodule ArrowWeb.API.ShuttleView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:status, :shuttle_name, :disrupted_route_id])
end
