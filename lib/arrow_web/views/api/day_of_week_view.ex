defmodule ArrowWeb.API.DayOfWeekView do
  use ArrowWeb, :view
  use JaSerializer.PhoenixView

  attributes([
    :id,
    :start_time,
    :end_time,
    :day_name
  ])
end
