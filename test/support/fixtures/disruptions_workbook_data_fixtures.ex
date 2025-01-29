defmodule Arrow.DisruptionFixtures.WorkbookDataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  workbook data for the `Arrow.Disruptions` context.
  """
  def workbook_data do
    %{
      "WKDY headways and runtimes" => [
        %{
          "end_time" => "06:00",
          "headway" => 3,
          "running_time_0" => 40,
          "running_time_1" => 28,
          "start_time" => "05:00"
        },
        %{
          "end_time" => "07:00",
          "headway" => 2,
          "running_time_0" => 45,
          "running_time_1" => 35,
          "start_time" => "06:00"
        },
        %{
          "end_time" => "08:00",
          "headway" => 2,
          "running_time_0" => 60,
          "running_time_1" => 35,
          "start_time" => "07:00"
        },
        %{
          "end_time" => "09:00",
          "headway" => 2,
          "running_time_0" => 70,
          "running_time_1" => 40,
          "start_time" => "08:00"
        },
        %{
          "end_time" => "10:00",
          "headway" => 2,
          "running_time_0" => 60,
          "running_time_1" => 40,
          "start_time" => "09:00"
        },
        %{
          "end_time" => "11:00",
          "headway" => 2,
          "running_time_0" => 55,
          "running_time_1" => 40,
          "start_time" => "10:00"
        },
        %{
          "end_time" => "12:00",
          "headway" => 3,
          "running_time_0" => 55,
          "running_time_1" => 40,
          "start_time" => "11:00"
        },
        %{
          "end_time" => "13:00",
          "headway" => 3,
          "running_time_0" => 55,
          "running_time_1" => 45,
          "start_time" => "12:00"
        },
        %{
          "end_time" => "14:00",
          "headway" => 3,
          "running_time_0" => 55,
          "running_time_1" => 45,
          "start_time" => "13:00"
        },
        %{
          "end_time" => "15:00",
          "headway" => 3,
          "running_time_0" => 60,
          "running_time_1" => 50,
          "start_time" => "14:00"
        },
        %{
          "end_time" => "16:00",
          "headway" => 2,
          "running_time_0" => 60,
          "running_time_1" => 45,
          "start_time" => "15:00"
        },
        %{
          "end_time" => "17:00",
          "headway" => 2,
          "running_time_0" => 60,
          "running_time_1" => 50,
          "start_time" => "16:00"
        },
        %{
          "end_time" => "18:00",
          "headway" => 2,
          "running_time_0" => 60,
          "running_time_1" => 55,
          "start_time" => "17:00"
        },
        %{
          "end_time" => "19:00",
          "headway" => 2,
          "running_time_0" => 60,
          "running_time_1" => 50,
          "start_time" => "18:00"
        },
        %{
          "end_time" => "20:00",
          "headway" => 2,
          "running_time_0" => 50,
          "running_time_1" => 45,
          "start_time" => "19:00"
        },
        %{
          "end_time" => "21:00",
          "headway" => 4,
          "running_time_0" => 50,
          "running_time_1" => 40,
          "start_time" => "20:00"
        },
        %{
          "end_time" => "22:00",
          "headway" => 4,
          "running_time_0" => 50,
          "running_time_1" => 40,
          "start_time" => "21:00"
        },
        %{
          "end_time" => "23:00",
          "headway" => 4,
          "running_time_0" => 45,
          "running_time_1" => 40,
          "start_time" => "22:00"
        },
        %{
          "end_time" => "24:00",
          "headway" => 5,
          "running_time_0" => 45,
          "running_time_1" => 35,
          "start_time" => "23:00"
        },
        %{
          "end_time" => "26:00",
          "headway" => 4,
          "running_time_0" => 40,
          "running_time_1" => 30,
          "start_time" => "24:00"
        },
        %{"first_trip_0" => "05:00", "first_trip_1" => "05:40"},
        %{"last_trip_0" => "24:30", "last_trip_1" => "25:00"}
      ]
    }
  end
end
