defmodule Arrow.Disruptions.ReplacementServiceTest do
  use Arrow.DataCase
  import Arrow.Factory

  alias Arrow.Disruptions.ReplacementService

  describe "trips_with_times/2" do
    test "generates trip times" do
      shuttle = Arrow.ShuttlesFixtures.shuttle_fixture(%{}, true)
      replacement_service = build(:replacement_service, %{shuttle: shuttle})

      result = ReplacementService.trips_with_times(replacement_service, "WKDY")

      assert %{"0" => direction_0_trips, "1" => direction_1_trips} = result
      assert length(direction_0_trips) == 8
      assert length(direction_1_trips) == 8

      %{stop_times: stop_times} = Enum.at(direction_0_trips, 0)
      assert length(stop_times) == 4
    end
  end
end
