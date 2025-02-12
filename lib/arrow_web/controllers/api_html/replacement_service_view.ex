defmodule ArrowWeb.API.ReplacementServiceView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:start_date, :end_date, :reason, :timetable])

  has_one :shuttle,
    serializer: ArrowWeb.API.ShuttleView,
    include: true

  has_one :disruption,
    serializer: ArrowWeb.API.DisruptionV2View,
    include: true
end
