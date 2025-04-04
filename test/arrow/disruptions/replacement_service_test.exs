defmodule Arrow.Disruptions.ReplacementServiceTest do
  use Arrow.DataCase

  alias Arrow.Disruptions.ReplacementService
  alias Arrow.ShuttlesFixtures

  describe "get_replacement_services_with_timetables/2" do
    test "returns replacement services that overlap with the given date range" do
      disruption = insert(:disruption_v2, is_active: true)
      shuttle = ShuttlesFixtures.shuttle_fixture(%{status: :active}, true, true)

      in_range_service =
        insert(:replacement_service, %{
          disruption: disruption,
          shuttle: shuttle,
          start_date: ~D[2025-01-01],
          end_date: ~D[2025-01-31]
        })

      # Service that starts before and ends during the range
      overlap_start_service =
        insert(:replacement_service, %{
          disruption: disruption,
          shuttle: shuttle,
          start_date: ~D[2024-12-15],
          end_date: ~D[2025-01-10]
        })

      # Service that starts during and ends after the range
      overlap_end_service =
        insert(:replacement_service, %{
          disruption: disruption,
          shuttle: shuttle,
          start_date: ~D[2025-01-25],
          end_date: ~D[2025-02-15]
        })

      # Service completely outside the range (before)
      before_service =
        insert(:replacement_service, %{
          disruption: disruption,
          shuttle: shuttle,
          start_date: ~D[2024-11-01],
          end_date: ~D[2024-12-15]
        })

      # Service completely outside the range (after)
      after_service =
        insert(:replacement_service, %{
          disruption: disruption,
          shuttle: shuttle,
          start_date: ~D[2025-02-01],
          end_date: ~D[2025-02-28]
        })

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
        insert(:replacement_service, %{
          disruption: active_disruption,
          shuttle: shuttle,
          start_date: ~D[2025-01-01],
          end_date: ~D[2025-01-31]
        })

      _inactive_service =
        insert(:replacement_service, %{
          disruption: inactive_disruption,
          shuttle: shuttle,
          start_date: ~D[2025-01-01],
          end_date: ~D[2025-01-31]
        })

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
      insert(:replacement_service, %{
        disruption: disruption,
        shuttle: shuttle,
        start_date: ~D[2025-01-01],
        end_date: ~D[2025-01-31]
      })

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
  end
end
