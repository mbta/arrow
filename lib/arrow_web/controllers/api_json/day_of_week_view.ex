defmodule ArrowWeb.API.DayOfWeekView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([
    :start_time,
    :end_time,
    :day_name
  ])
end
