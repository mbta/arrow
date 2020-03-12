defmodule ArrowWeb.API.DayOfWeekView do
  use ArrowWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :id,
    :start_time,
    :end_time,
    :monday,
    :tuesday,
    :wednesday,
    :thursday,
    :friday,
    :saturday,
    :sunday
  ])
end
