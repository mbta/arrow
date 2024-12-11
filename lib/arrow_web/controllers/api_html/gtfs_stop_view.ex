defmodule ArrowWeb.API.GtfsStopView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:lat, :lon, :name])

end
