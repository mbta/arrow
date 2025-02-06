defmodule Arrow.Disruptions.ReplacementServiceTest do
  use Arrow.DataCase
  import Arrow.Factory

  alias Arrow.Disruptions.ReplacementService

  describe "trips_with_times/2" do
    test "generates trip times" do
      shuttle = Arrow.ShuttlesFixtures.shuttle_fixture(%{}, true, true)
      replacement_service = build(:replacement_service, %{shuttle: shuttle})

      result = ReplacementService.trips_with_times(replacement_service, "WKDY")

      assert %{"0" => direction_0_trips, "1" => direction_1_trips} = result
      assert length(direction_0_trips) == 8
      assert length(direction_1_trips) == 8

      assert Enum.each(direction_0_trips, fn %{stop_times: stop_times} ->
               length(stop_times) == 4
             end)

      assert Enum.each(direction_1_trips, fn %{stop_times: stop_times} ->
               length(stop_times) == 4
             end)

      assert direction_0_trips
             |> Enum.filter(
               &match?(
                 %{
                   stop_times: [
                     %{stop_id: _, stop_time: "05:10"},
                     %{stop_id: _, stop_time: "05:14"},
                     %{stop_id: _, stop_time: "05:22"},
                     %{stop_id: _, stop_time: "05:35"}
                   ]
                 },
                 &1
               )
             )
             |> length() == 1

      assert direction_0_trips
             |> Enum.filter(
               &match?(
                 %{
                   stop_times: [
                     %{stop_id: _, stop_time: "06:30"},
                     %{stop_id: _, stop_time: "06:35"},
                     %{stop_id: _, stop_time: "06:45"},
                     %{stop_id: _, stop_time: "07:00"}
                   ]
                 },
                 &1
               )
             )
             |> length() == 1

      assert direction_1_trips
             |> Enum.filter(
               &match?(
                 %{
                   stop_times: [
                     %{stop_id: _, stop_time: "05:10"},
                     %{stop_id: _, stop_time: "05:13"},
                     %{stop_id: _, stop_time: "05:18"},
                     %{stop_id: _, stop_time: "05:26"}
                   ]
                 },
                 &1
               )
             )
             |> length() == 1

      assert direction_1_trips
             |> Enum.filter(
               &match?(
                 %{
                   stop_times: [
                     %{stop_id: _, stop_time: "06:30"},
                     %{stop_id: _, stop_time: "06:33"},
                     %{stop_id: _, stop_time: "06:40"},
                     %{stop_id: _, stop_time: "06:50"}
                   ]
                 },
                 &1
               )
             )
             |> length() == 1
    end
  end
end
