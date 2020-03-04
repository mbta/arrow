defmodule ArrowWeb.TripShortNameApiView do
  use ArrowWeb, :view
  use JaSerializer.PhoenixView

  attributes([:id, :trip_short_name])
end
