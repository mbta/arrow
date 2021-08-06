defmodule ArrowWeb.DisruptionView.DaysOfWeekTest do
  use ExUnit.Case, async: true

  alias Arrow.Disruption.DayOfWeek
  alias ArrowWeb.DisruptionView.DaysOfWeek

  test "describes a single day" do
    days = [%DayOfWeek{day_name: "monday"}]
    assert DaysOfWeek.describe(days) == [["Mon", "Start of service – End of service"]]
  end

  test "describes multiple days with times" do
    days = [
      %DayOfWeek{day_name: "tuesday", start_time: ~T[09:30:00]},
      %DayOfWeek{day_name: "thursday", end_time: ~T[21:45:00]}
    ]

    assert DaysOfWeek.describe(days) == [
             ["Tue", "9:30AM – End of service"],
             ["Thu", "Start of service – 9:45PM"]
           ]
  end

  test "combines consecutive days with the same times" do
    days = [
      %DayOfWeek{day_name: "wednesday", start_time: ~T[11:30:00], end_time: ~T[20:45:00]},
      %DayOfWeek{day_name: "thursday", start_time: ~T[11:30:00], end_time: ~T[20:45:00]},
      %DayOfWeek{day_name: "friday", start_time: ~T[11:30:00], end_time: ~T[20:45:00]}
    ]

    assert DaysOfWeek.describe(days) == [["Wed – Fri", "11:30AM – 8:45PM"]]
  end

  test "combines consecutive days with contiguous time spans" do
    days = [
      %DayOfWeek{day_name: "friday", start_time: ~T[20:45:00]},
      %DayOfWeek{day_name: "saturday"},
      %DayOfWeek{day_name: "sunday", end_time: ~T[23:30:00]}
    ]

    assert DaysOfWeek.describe(days) == [["Fri 8:45PM – Sun 11:30PM"]]
  end

  test "prefers the same-times format over the contiguous-times format" do
    days = [%DayOfWeek{day_name: "saturday"}, %DayOfWeek{day_name: "sunday"}]
    assert DaysOfWeek.describe(days) == [["Sat – Sun", "Start of service – End of service"]]
  end
end
