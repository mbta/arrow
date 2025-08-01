defmodule Arrow.Shuttles.RouteStopTest do
  use Arrow.DataCase

  import Arrow.Factory

  alias Arrow.Shuttles.RouteStop

  describe "changeset/2" do
    test "handles GTFS stop" do
      gtfs_stop = insert(:gtfs_stop)

      gtfs_stop_id = gtfs_stop.id

      route_stop = insert(:route_stop)

      changeset = RouteStop.changeset(route_stop, %{"display_stop_id" => gtfs_stop_id})

      assert %Ecto.Changeset{
               valid?: true,
               changes: %{display_stop_id: ^gtfs_stop_id, gtfs_stop_id: ^gtfs_stop_id}
             } = changeset
    end

    test "handles Arrow stop" do
      stop = insert(:stop)

      display_stop_id = stop.stop_id
      stop_id = stop.id

      route_stop = insert(:route_stop)

      changeset = RouteStop.changeset(route_stop, %{"display_stop_id" => display_stop_id})

      assert %Ecto.Changeset{
               valid?: true,
               changes: %{display_stop_id: ^display_stop_id, stop_id: ^stop_id}
             } = changeset
    end

    test "gives an error when stop ID is invalid" do
      route_stop = insert(:route_stop)

      changeset = RouteStop.changeset(route_stop, %{"display_stop_id" => "invalid_id"})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 display_stop_id: {"not a valid stop ID '%{display_stop_id}'", [display_stop_id: "invalid_id"]}
               ]
             } = changeset
    end

    test "can update other fields" do
      route_stop = insert(:route_stop)

      changeset = RouteStop.changeset(route_stop, %{"time_to_next_stop" => 10})

      time_to_next_stop_change_value = Decimal.new("10")

      assert %Ecto.Changeset{
               valid?: true,
               changes: %{time_to_next_stop: ^time_to_next_stop_change_value}
             } = changeset
    end
  end
end
