defmodule Arrow.Disruptions.ReplacementServiceTest do
  use Arrow.DataCase

  alias Arrow.Disruptions.ReplacementService
  alias Arrow.ShuttlesFixtures

  describe "get_replacement_services_with_timetables/2" do
    test "returns replacement services that overlap with the given date range" do
      disruption = insert(:disruption_v2, is_active: true)
      shuttle = ShuttlesFixtures.shuttle_fixture(%{status: :active}, true, true)

      in_range_service =
        insert(:replacement_service,
          disruption: disruption,
          shuttle: shuttle,
          start_date: ~D[2025-01-01],
          end_date: ~D[2025-01-31]
        )

      # Service that starts before and ends during the range
      overlap_start_service =
        insert(:replacement_service,
          disruption: disruption,
          shuttle: shuttle,
          start_date: ~D[2024-12-15],
          end_date: ~D[2025-01-10]
        )

      # Service that starts during and ends after the range
      overlap_end_service =
        insert(:replacement_service,
          disruption: disruption,
          shuttle: shuttle,
          start_date: ~D[2025-01-25],
          end_date: ~D[2025-02-15]
        )

      # Service completely outside the range (before)
      before_service =
        insert(:replacement_service,
          disruption: disruption,
          shuttle: shuttle,
          start_date: ~D[2024-11-01],
          end_date: ~D[2024-12-15]
        )

      # Service completely outside the range (after)
      after_service =
        insert(:replacement_service,
          disruption: disruption,
          shuttle: shuttle,
          start_date: ~D[2025-02-01],
          end_date: ~D[2025-02-28]
        )

      result =
        ReplacementService.get_replacement_services_with_timetables(
          ~D[2025-01-01],
          ~D[2025-01-31]
        )

      # Should include in_range_service, overlap_start_service, and overlap_end_service
      service_ids = Enum.map(result, & &1.id)
      assert length(result) == 3
      assert in_range_service.id in service_ids
      assert overlap_start_service.id in service_ids
      assert overlap_end_service.id in service_ids
      refute before_service.id in service_ids
      refute after_service.id in service_ids

      Enum.each(result, fn service ->
        assert Map.has_key?(service, :timetable)
      end)
    end

    test "only returns services for active disruptions" do
      shuttle = ShuttlesFixtures.shuttle_fixture(%{status: :active}, true, true)

      active_disruption = insert(:disruption_v2, is_active: true)
      inactive_disruption = insert(:disruption_v2, is_active: false)

      active_service =
        insert(:replacement_service,
          disruption: active_disruption,
          shuttle: shuttle,
          start_date: ~D[2025-01-01],
          end_date: ~D[2025-01-31]
        )

      _inactive_service =
        insert(:replacement_service,
          disruption: inactive_disruption,
          shuttle: shuttle,
          start_date: ~D[2025-01-01],
          end_date: ~D[2025-01-31]
        )

      result =
        ReplacementService.get_replacement_services_with_timetables(
          ~D[2025-01-01],
          ~D[2025-01-31]
        )

      assert length(result) == 1
      assert hd(result).id == active_service.id
    end

    test "builds timetables based on workbook data" do
      disruption = insert(:disruption_v2, is_active: true)

      shuttle = ShuttlesFixtures.shuttle_fixture(%{status: :active}, true, true)

      # Our fixture here generates a replacement service based on a workbook with Weekday and Saturday data
      insert(:replacement_service,
        disruption: disruption,
        shuttle: shuttle,
        start_date: ~D[2025-01-01],
        end_date: ~D[2025-01-31]
      )

      [result] =
        ReplacementService.get_replacement_services_with_timetables(
          ~D[2025-01-01],
          ~D[2025-01-31]
        )

      # Validate we have timetable data for weekday, saturday, but not sunday
      assert result.timetable.weekday != nil
      assert result.timetable.saturday != nil
      assert result.timetable.sunday == nil

      weekday = result.timetable.weekday
      assert Map.has_key?(weekday, "0")
      assert Map.has_key?(weekday, "1")

      assert is_list(weekday["0"])
      assert is_list(weekday["1"])

      direction = List.first(weekday["0"])

      Enum.each(direction, fn stop_time ->
        assert Map.has_key?(stop_time, :stop_id)
        assert Map.has_key?(stop_time, :stop_time)
      end)
    end

    test "in timetables, always includes the last trips specified in workbook data" do
      # ...even if they don't line up exactly with the specified headway cadence.
      disruption = insert(:disruption_v2, is_active: true)

      shuttle = ShuttlesFixtures.shuttle_fixture(%{status: :active}, true, true)

      insert(:replacement_service,
        disruption: disruption,
        shuttle: shuttle,
        start_date: ~D[2025-01-01],
        end_date: ~D[2025-01-31],
        source_workbook_data: %{
          "WKDY headways and runtimes" => [
            # The first hour of runtimes ends cleanly on 06:00.
            %{
              "start_time" => "05:00",
              "end_time" => "06:00",
              "headway" => 10,
              "running_time_0" => 25,
              "running_time_1" => 15
            },
            # The second hour of runtimes does not include a trip that starts at the
            # last_trip_0 value. We expect that trip to be added to the timetable nonetheless.
            %{
              "start_time" => "06:00",
              "end_time" => "07:00",
              "headway" => 15,
              "running_time_0" => 30,
              "running_time_1" => 20
            },
            %{"first_trip_0" => "05:10", "first_trip_1" => "05:10"},
            %{"last_trip_0" => _out_of_cadence = "06:31", "last_trip_1" => "06:30"}
          ],
          "SAT headways and runtimes" => [
            # The first hour of runtimes ends cleanly on 06:00.
            %{
              "end_time" => "06:00",
              "headway" => 10,
              "running_time_0" => 25,
              "running_time_1" => 15,
              "start_time" => "05:00"
            },
            # The second hour of runtimes does not include a trip that starts at the
            # last_trip_1 value. We expect that trip to be added to the timetable nonetheless.
            %{
              "end_time" => "07:00",
              "headway" => 15,
              "running_time_0" => 30,
              "running_time_1" => 20,
              "start_time" => "06:00"
            },
            %{"first_trip_0" => "05:10", "first_trip_1" => "05:10"},
            %{"last_trip_0" => "06:30", "last_trip_1" => _out_of_cadence = "06:27"}
          ]
        }
      )

      [result] =
        ReplacementService.get_replacement_services_with_timetables(
          ~D[2025-01-01],
          ~D[2025-01-31]
        )

      first_last_trips = ReplacementService.first_last_trip_times(result)

      last_weekday_0 = first_last_trips.weekday.last_trips[0]
      last_weekday_1 = first_last_trips.weekday.last_trips[1]

      last_saturday_0 = first_last_trips.saturday.last_trips[0]
      last_saturday_1 = first_last_trips.saturday.last_trips[1]

      assert last_weekday_0 == "06:31"
      assert first_stop_time_of_last_trip(result, :weekday, "0") == last_weekday_0

      assert last_weekday_1 == "06:30"
      assert first_stop_time_of_last_trip(result, :weekday, "1") == last_weekday_1

      assert last_saturday_0 == "06:30"
      assert first_stop_time_of_last_trip(result, :saturday, "0") == last_saturday_0

      assert last_saturday_1 == "06:27"
      assert first_stop_time_of_last_trip(result, :saturday, "1") == last_saturday_1
    end
  end

  defp first_stop_time_of_last_trip(replacement_service, schedule_service_type, direction_id) do
    replacement_service.timetable
    |> get_in([
      schedule_service_type,
      direction_id,
      Access.at(-1),
      Access.at(0),
      :stop_time
    ])
    # stop times in the timetable include seconds, we don't care about those here
    |> String.slice(0..4//1)
  end
end
