defmodule ArrowWeb.API.ShuttleRouteStopView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:direction_id, :stop_sequence, :time_to_next_stop, :display_stop_id])

  has_one :gtfs_stop,
    serializer: ArrowWeb.API.GtfsStopView,
    include: true

  has_one :stop,
    serializer: ArrowWeb.API.StopsView,
    include: true
end
