defmodule ArrowWeb.API.TripShortNameView do
  use ArrowWeb, :view
  use JaSerializer.PhoenixView

  attributes([:trip_short_name])
end
