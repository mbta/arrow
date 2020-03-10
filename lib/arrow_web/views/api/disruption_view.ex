defmodule ArrowWeb.API.DisruptionView do
  use ArrowWeb, :view
  use JaSerializer.PhoenixView

  attributes([:id, :start_date, :end_date])

  has_many :adjustments,
    serializer: ArrowWeb.API.AdjustmentView,
    include: true

  has_many :days_of_week,
    serializer: ArrowWeb.API.DaysOfWeekView,
    include: true

  has_many :exceptions,
    serializer: ArrowWeb.API.ExceptionView,
    include: true

  has_many :trip_short_names,
    serializer: ArrowWeb.API.TripShortNameView,
    include: true
end
