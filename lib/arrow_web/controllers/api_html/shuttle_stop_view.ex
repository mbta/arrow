defmodule ArrowWeb.API.ShuttleStopView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:stop_name, :stop_desc, :stop_lat, :stop_lon])
end
