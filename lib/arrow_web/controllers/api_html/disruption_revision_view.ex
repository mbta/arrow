defmodule ArrowWeb.API.DisruptionRevisionView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([:start_date, :end_date, :row_approved, :is_active, :inserted_at])

  has_many :adjustments,
    serializer: ArrowWeb.API.AdjustmentView,
    include: true

  has_many :days_of_week,
    serializer: ArrowWeb.API.DayOfWeekView,
    include: true

  has_many :exceptions,
    serializer: ArrowWeb.API.ExceptionView,
    include: true

  has_many :trip_short_names,
    serializer: ArrowWeb.API.TripShortNameView,
    include: true
end
