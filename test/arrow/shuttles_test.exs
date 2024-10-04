defmodule Arrow.ShuttlesTest do
  use Arrow.DataCase

  alias Arrow.Shuttles

  describe "shuttles" do
    alias Arrow.Shuttles.Shuttle

    import Arrow.ShuttlesFixtures

    @invalid_attrs %{status: nil, shuttle_name: nil}

    test "list_shuttles/0 returns all shuttles" do
      shuttle = shuttle_fixture()
      assert Shuttles.list_shuttles() == [shuttle]
    end

    test "get_shuttle!/1 returns the shuttle with given id" do
      shuttle = shuttle_fixture()
      assert Shuttles.get_shuttle!(shuttle.id) == shuttle
    end

    test "create_shuttle/1 with valid data creates a shuttle" do
      valid_attrs = %{status: :draft, shuttle_name: "some shuttle_name"}

      assert {:ok, %Shuttle{} = shuttle} = Shuttles.create_shuttle(valid_attrs)
      assert shuttle.status == :draft
      assert shuttle.shuttle_name == "some shuttle_name"
    end

    test "create_shuttle/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shuttles.create_shuttle(@invalid_attrs)
    end

    test "update_shuttle/2 with valid data updates the shuttle" do
      shuttle = shuttle_fixture()
      update_attrs = %{status: :active, shuttle_name: "some updated shuttle_name"}

      assert {:ok, %Shuttle{} = shuttle} = Shuttles.update_shuttle(shuttle, update_attrs)
      assert shuttle.status == :active
      assert shuttle.shuttle_name == "some updated shuttle_name"
    end

    test "update_shuttle/2 with invalid data returns error changeset" do
      shuttle = shuttle_fixture()
      assert {:error, %Ecto.Changeset{}} = Shuttles.update_shuttle(shuttle, @invalid_attrs)
      assert shuttle == Shuttles.get_shuttle!(shuttle.id)
    end

    test "delete_shuttle/1 deletes the shuttle" do
      shuttle = shuttle_fixture()
      assert {:ok, %Shuttle{}} = Shuttles.delete_shuttle(shuttle)
      assert_raise Ecto.NoResultsError, fn -> Shuttles.get_shuttle!(shuttle.id) end
    end

    test "change_shuttle/1 returns a shuttle changeset" do
      shuttle = shuttle_fixture()
      assert %Ecto.Changeset{} = Shuttles.change_shuttle(shuttle)
    end
  end

  describe "shuttle_routes" do
    alias Arrow.Shuttles.ShuttleRoute

    import Arrow.ShuttlesFixtures

    @invalid_attrs %{
      suffix: nil,
      destination: nil,
      direction_id: nil,
      direction_desc: nil,
      waypoint: nil
    }

    test "list_shuttle_routes/0 returns all shuttle_routes" do
      shuttle_route = shuttle_route_fixture()
      assert Shuttles.list_shuttle_routes() == [shuttle_route]
    end

    test "get_shuttle_route!/1 returns the shuttle_route with given id" do
      shuttle_route = shuttle_route_fixture()
      assert Shuttles.get_shuttle_route!(shuttle_route.id) == shuttle_route
    end

    test "create_shuttle_route/1 with valid data creates a shuttle_route" do
      valid_attrs = %{
        suffix: "some suffix",
        destination: "some destination",
        direction_id: :"0",
        direction_desc: "some direction_desc",
        waypoint: "some waypoint"
      }

      assert {:ok, %ShuttleRoute{} = shuttle_route} = Shuttles.create_shuttle_route(valid_attrs)
      assert shuttle_route.suffix == "some suffix"
      assert shuttle_route.destination == "some destination"
      assert shuttle_route.direction_id == :"0"
      assert shuttle_route.direction_desc == "some direction_desc"
      assert shuttle_route.waypoint == "some waypoint"
    end

    test "create_shuttle_route/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shuttles.create_shuttle_route(@invalid_attrs)
    end

    test "update_shuttle_route/2 with valid data updates the shuttle_route" do
      shuttle_route = shuttle_route_fixture()

      update_attrs = %{
        suffix: "some updated suffix",
        destination: "some updated destination",
        direction_id: :"1",
        direction_desc: "some updated direction_desc",
        waypoint: "some updated waypoint"
      }

      assert {:ok, %ShuttleRoute{} = shuttle_route} =
               Shuttles.update_shuttle_route(shuttle_route, update_attrs)

      assert shuttle_route.suffix == "some updated suffix"
      assert shuttle_route.destination == "some updated destination"
      assert shuttle_route.direction_id == :"1"
      assert shuttle_route.direction_desc == "some updated direction_desc"
      assert shuttle_route.waypoint == "some updated waypoint"
    end

    test "update_shuttle_route/2 with invalid data returns error changeset" do
      shuttle_route = shuttle_route_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Shuttles.update_shuttle_route(shuttle_route, @invalid_attrs)

      assert shuttle_route == Shuttles.get_shuttle_route!(shuttle_route.id)
    end

    test "delete_shuttle_route/1 deletes the shuttle_route" do
      shuttle_route = shuttle_route_fixture()
      assert {:ok, %ShuttleRoute{}} = Shuttles.delete_shuttle_route(shuttle_route)
      assert_raise Ecto.NoResultsError, fn -> Shuttles.get_shuttle_route!(shuttle_route.id) end
    end

    test "change_shuttle_route/1 returns a shuttle_route changeset" do
      shuttle_route = shuttle_route_fixture()
      assert %Ecto.Changeset{} = Shuttles.change_shuttle_route(shuttle_route)
    end
  end

  describe "shuttle_route_stops" do
    alias Arrow.Shuttles.ShuttleRouteStops

    import Arrow.ShuttlesFixtures

    @invalid_attrs %{direction_id: nil, stop_id: nil, stop_sequence: nil, time_to_next_stop: nil}

    test "list_shuttle_route_stops/0 returns all shuttle_route_stops" do
      shuttle_route_stops = shuttle_route_stops_fixture()
      assert Shuttles.list_shuttle_route_stops() == [shuttle_route_stops]
    end

    test "get_shuttle_route_stops!/1 returns the shuttle_route_stops with given id" do
      shuttle_route_stops = shuttle_route_stops_fixture()
      assert Shuttles.get_shuttle_route_stops!(shuttle_route_stops.id) == shuttle_route_stops
    end

    test "create_shuttle_route_stops/1 with valid data creates a shuttle_route_stops" do
      valid_attrs = %{
        direction_id: :"0",
        stop_id: "some stop_id",
        stop_sequence: 42,
        time_to_next_stop: "120.5"
      }

      assert {:ok, %ShuttleRouteStops{} = shuttle_route_stops} =
               Shuttles.create_shuttle_route_stops(valid_attrs)

      assert shuttle_route_stops.direction_id == :"0"
      assert shuttle_route_stops.stop_id == "some stop_id"
      assert shuttle_route_stops.stop_sequence == 42
      assert shuttle_route_stops.time_to_next_stop == Decimal.new("120.5")
    end

    test "create_shuttle_route_stops/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shuttles.create_shuttle_route_stops(@invalid_attrs)
    end

    test "update_shuttle_route_stops/2 with valid data updates the shuttle_route_stops" do
      shuttle_route_stops = shuttle_route_stops_fixture()

      update_attrs = %{
        direction_id: :"1",
        stop_id: "some updated stop_id",
        stop_sequence: 43,
        time_to_next_stop: "456.7"
      }

      assert {:ok, %ShuttleRouteStops{} = shuttle_route_stops} =
               Shuttles.update_shuttle_route_stops(shuttle_route_stops, update_attrs)

      assert shuttle_route_stops.direction_id == :"1"
      assert shuttle_route_stops.stop_id == "some updated stop_id"
      assert shuttle_route_stops.stop_sequence == 43
      assert shuttle_route_stops.time_to_next_stop == Decimal.new("456.7")
    end

    test "update_shuttle_route_stops/2 with invalid data returns error changeset" do
      shuttle_route_stops = shuttle_route_stops_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Shuttles.update_shuttle_route_stops(shuttle_route_stops, @invalid_attrs)

      assert shuttle_route_stops == Shuttles.get_shuttle_route_stops!(shuttle_route_stops.id)
    end

    test "delete_shuttle_route_stops/1 deletes the shuttle_route_stops" do
      shuttle_route_stops = shuttle_route_stops_fixture()

      assert {:ok, %ShuttleRouteStops{}} =
               Shuttles.delete_shuttle_route_stops(shuttle_route_stops)

      assert_raise Ecto.NoResultsError, fn ->
        Shuttles.get_shuttle_route_stops!(shuttle_route_stops.id)
      end
    end

    test "change_shuttle_route_stops/1 returns a shuttle_route_stops changeset" do
      shuttle_route_stops = shuttle_route_stops_fixture()
      assert %Ecto.Changeset{} = Shuttles.change_shuttle_route_stops(shuttle_route_stops)
    end
  end
end
