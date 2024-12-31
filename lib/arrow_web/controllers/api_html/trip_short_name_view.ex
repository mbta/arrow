defmodule ArrowWeb.API.TripShortNameView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:trip_short_name])
end
