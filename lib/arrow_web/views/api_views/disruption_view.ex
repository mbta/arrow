defmodule ArrowWeb.DisruptionApiView do
  use ArrowWeb, :view
  use JaSerializer.PhoenixView

  attributes([:id, :start_date, :end_date])

  has_many :adjustments,
    serializer: ArrowWeb.AdjustmentApiView,
    include: true

  has_many :days_of_week,
    serializer: ArrowWeb.DaysOfWeekApiView,
    include: true

  has_many :exceptions,
    serializer: ArrowWeb.ExceptionApiView,
    include: true

  has_many :trip_short_names,
    serializer: ArrowWeb.TripShortNameApiView,
    include: true
end
