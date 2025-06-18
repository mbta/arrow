defmodule Arrow.ShuttlesTest do
  use Arrow.DataCase

  import Arrow.Factory
  import Arrow.ShuttlesFixtures
  import Arrow.StopsFixtures
  import Mox
  import Test.Support.Helpers

  alias Arrow.OpenRouteServiceAPI.DirectionsRequest
  alias Arrow.OpenRouteServiceAPI.MockClient
  alias Arrow.Shuttles
  alias Arrow.Shuttles.Shape
  alias Arrow.Shuttles.Stop

  setup :verify_on_exit!

  describe "shapes with s3 functionality enabled (mocked)" do
    @valid_shape %{
      name: "FromPlaceAToPlaceBViaC-S",
      coordinates: "-71.14163,42.39551 -71.14163,42.39551 -71.14163,42.39551"
    }

    test "create_shape/1 with valid data creates a shape when shape storage is enabled" do
      reassign_env(:shape_storage_enabled?, true)
      reassign_env(:shape_storage_prefix, "prefix/#{Ecto.UUID.generate()}/")

      assert {:ok, %Shape{} = shape} = Shuttles.create_shape(@valid_shape)
      assert shape.name == "FromPlaceAToPlaceBViaC-S"
      Application.put_env(:arrow, :shape_storage_enabled?, false)
    end

    test "create_shape/1 with name that does not end in -S adds it" do
      reassign_env(:shape_storage_enabled?, true)
      Application.put_env(:arrow, :shape_storage_prefix, "prefix/#{Ecto.UUID.generate()}/")

      assert {:ok, %Shape{} = shape} =
               Shuttles.create_shape(%{name: "SomePlaceToPlace", coordinates: coords()})

      assert shape.name == "SomePlaceToPlace-S"
    end

    test "delete_shape/1 deletes the shape" do
      reassign_env(:shape_storage_enabled?, true)

      assert {:ok, %Shape{} = shape} = Shuttles.create_shape(@valid_shape)
      assert {:ok, %Shape{}} = Shuttles.delete_shape(shape)
      assert_raise Ecto.NoResultsError, fn -> Shuttles.get_shape!(shape.id) end
    end

    test "get_shapes_upload/1 returns a ShapesUpload changeset" do
      reassign_env(:shape_storage_enabled?, true)

      new_shape = s3_mocked_shape_fixture()
      shape = Shuttles.get_shape!(new_shape.id)
      assert {:ok, %Ecto.Changeset{valid?: true}} = Shuttles.get_shapes_upload(shape)
    end
  end

  describe "shapes" do
    @valid_attrs %{name: "GoingFromAToB-S", coordinates: coords()}
    @invalid_attrs %{name: "", coordinates: nil}

    test "list_shapes/0 returns all shapes" do
      shape = shape_fixture()
      assert Shuttles.list_shapes() == [shape]
    end

    test "get_shape!/1 returns the shape with given id" do
      shape = shape_fixture()
      assert Shuttles.get_shape!(shape.id) == shape
    end

    test "get_shapes returns all shapes with matching ids" do
      shapes = [shape_fixture(), shape_fixture()]
      shape_ids = Enum.map(shapes, fn shape -> shape.id end)
      assert MapSet.new(Shuttles.get_shapes(shape_ids)) == MapSet.new(shapes)
    end

    test "get_shapes returns empty list when no shapes match" do
      shape_ids = [1, 2, 3]
      assert [] == Shuttles.get_shapes(shape_ids)
    end

    test "create_shapes/1 with valid data creates a shape" do
      assert {:ok, [{:ok, %Shape{} = shape}]} = Shuttles.create_shapes([@valid_attrs])
      assert shape.name == "GoingFromAToB-S"
    end

    test "create_shapes/1 with invalid data returns error changeset" do
      assert {:error, {"Failed to upload some shapes", changeset}} =
               Shuttles.create_shapes([@invalid_attrs])

      assert ["Name can't be blank "] = changeset
    end

    test "create_shapes/1 creates valid and returns errors for invalid" do
      name = @valid_attrs.name
      refute Repo.get_by(Arrow.Shuttles.Shape, name: name)

      assert {:error, {"Failed to upload some shapes", changeset}} =
               Shuttles.create_shapes([@valid_attrs, @invalid_attrs])

      assert ["Name can't be blank "] = changeset
      assert %Shape{name: ^name} = Repo.get_by(Arrow.Shuttles.Shape, name: name)
    end

    test "create_shape/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shuttles.create_shape(@invalid_attrs)
    end

    test "create_shape/1 with existing name returns an error" do
      assert {:ok, %Shape{}} = Shuttles.create_shape(@valid_attrs)
      # Trying to create a second time throws an error
      assert {:error, message} = Shuttles.create_shape(@valid_attrs)
      assert message =~ "already exists"
    end

    test "delete_shape/1 deletes the shape" do
      shape = shape_fixture()
      assert {:ok, %Shape{}} = Shuttles.delete_shape(shape)
      assert_raise Ecto.NoResultsError, fn -> Shuttles.get_shape!(shape.id) end
    end

    test "change_shape/1 returns a shape changeset" do
      shape = shape_fixture()
      assert %Ecto.Changeset{} = Shuttles.change_shape(shape)
    end
  end

  describe "shuttles" do
    import Arrow.ShuttlesFixtures

    alias Arrow.Shuttles.Shuttle

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
      update_attrs = %{status: :draft, shuttle_name: "some updated shuttle_name"}

      assert {:ok, %Shuttle{} = shuttle} = Shuttles.update_shuttle(shuttle, update_attrs)
      assert shuttle.status == :draft
      assert shuttle.shuttle_name == "some updated shuttle_name"
    end

    test "update_shuttle/2 with valid route data updates the shuttle route" do
      shuttle = shuttle_fixture()
      [route1, route2] = shuttle.routes
      destination = unique_shuttle_route_destination()
      updated_route1 = Map.put(route1, :destination, destination)

      update_attrs =
        Map.from_struct(%{
          shuttle
          | routes: [Map.from_struct(updated_route1), Map.from_struct(route2)]
        })

      assert {:ok, %Shuttle{} = shuttle} = Shuttles.update_shuttle(shuttle, update_attrs)
      assert List.first(shuttle.routes).id == route1.id
      assert List.first(shuttle.routes).destination == destination
    end

    test "update_shuttle/2 with valid shape_id updates the shuttle route shape" do
      shuttle = shuttle_fixture()
      routes = shuttle.routes
      first_route = List.first(routes)
      new_shape = shape_fixture()
      # Updated shape is set by shape_id param
      updated_route1 = Map.put(List.first(routes), :shape_id, new_shape.id)
      existing_route2 = Enum.at(routes, 1)

      update_attrs =
        Map.from_struct(%{
          shuttle
          | routes: [Map.from_struct(updated_route1), Map.from_struct(existing_route2)]
        })

      assert {:ok, %Shuttle{} = updated_shuttle} = Shuttles.update_shuttle(shuttle, update_attrs)
      # Shuttle id is the same
      assert updated_shuttle.id == shuttle.id
      # Existing route is unchanged
      assert Enum.at(updated_shuttle.routes, 1) == existing_route2
      # Route definition id is the same
      updated_shuttle_route = List.first(updated_shuttle.routes)
      assert updated_shuttle_route.id == first_route.id
      # Shape reference is updated
      refute updated_shuttle_route.shape == first_route.shape
      assert updated_shuttle_route.shape.id == updated_route1.shape_id
      assert updated_shuttle_route.shape == new_shape
    end

    test "update_shuttle/2 with invalid data updates for status active returns error changeset" do
      shuttle = shuttle_fixture()
      update_attrs = %{status: :active, shuttle_name: "some updated shuttle_name"}

      assert {:error, %Ecto.Changeset{}} = Shuttles.update_shuttle(shuttle, update_attrs)
      assert shuttle == Shuttles.get_shuttle!(shuttle.id)
      refute shuttle.status == :active
    end

    test "update_shuttle/2 with invalid data returns error changeset" do
      shuttle = shuttle_fixture()
      assert {:error, %Ecto.Changeset{}} = Shuttles.update_shuttle(shuttle, @invalid_attrs)
      assert shuttle == Shuttles.get_shuttle!(shuttle.id)
    end

    test "change_shuttle/1 returns a shuttle changeset" do
      shuttle = shuttle_fixture()
      assert %Ecto.Changeset{} = Shuttles.change_shuttle(shuttle)
    end
  end

  describe "stop_or_gtfs_stop_for_stop_id/1" do
    test "fetches Arrow stop" do
      stop = stop_fixture()
      stop_id = stop.stop_id

      assert %Stop{stop_id: ^stop_id} =
               Shuttles.stop_or_gtfs_stop_for_stop_id(stop_id)
    end

    test "fetches GTFS stop" do
      gtfs_stop = insert(:gtfs_stop)
      stop_id = gtfs_stop.id

      assert %Arrow.Gtfs.Stop{id: ^stop_id} = Shuttles.stop_or_gtfs_stop_for_stop_id(stop_id)
    end

    test "prefers the Arrow stop if there are both Arrow and Gtfs stops" do
      stop = stop_fixture()
      _gtfs_stop = insert(:gtfs_stop)
      stop_id = stop.stop_id

      assert %Stop{stop_id: ^stop_id} =
               Shuttles.stop_or_gtfs_stop_for_stop_id(stop_id)
    end

    test "returns nil if no stops are found" do
      assert is_nil(Shuttles.stop_or_gtfs_stop_for_stop_id("nonexistent-stop"))
    end
  end

  describe "stop_display_name/1" do
    test "Arrow stop, description" do
      stop = build(:stop, %{stop_desc: "Test description"})

      assert Shuttles.stop_display_name(stop) == "Test description"
    end

    test "Arrow stop, name" do
      stop = build(:stop, %{stop_desc: "", stop_name: "Test name"})

      assert Shuttles.stop_display_name(stop) == "Test name"
    end

    test "GTFS stop, description" do
      gtfs_stop = build(:gtfs_stop, desc: "Test description")

      assert Shuttles.stop_display_name(gtfs_stop) == "Test description"
    end

    test "GTFS stop, name" do
      gtfs_stop = build(:gtfs_stop, desc: nil, name: "Test name")

      assert Shuttles.stop_display_name(gtfs_stop) == "Test name"
    end
  end

  describe "stops_or_gtfs_stops_by_search_string/1" do
    test "finds Arrow stop by stop ID" do
      insert(:stop, %{stop_id: "12"})

      assert [%Stop{stop_id: "12"}] =
               Shuttles.stops_or_gtfs_stops_by_search_string("1")
    end

    test "finds Arrow stop by stop description" do
      stop = insert(:stop, %{stop_desc: "Description"})
      stop_id = stop.stop_id

      assert [%Stop{stop_id: ^stop_id}] =
               Shuttles.stops_or_gtfs_stops_by_search_string("Des")
    end

    test "finds Arrow stop by stop name" do
      stop = insert(:stop, %{stop_name: "Name"})
      stop_id = stop.stop_id

      assert [%Stop{stop_id: ^stop_id}] =
               Shuttles.stops_or_gtfs_stops_by_search_string("Na")
    end

    test "finds GTFS stop by stop ID" do
      insert(:gtfs_stop, %{id: "12"})

      assert [%Arrow.Gtfs.Stop{id: "12"}] =
               Shuttles.stops_or_gtfs_stops_by_search_string("1")
    end

    test "finds GTFS stop by stop description" do
      gtfs_stop = insert(:gtfs_stop, %{desc: "Description"})
      gtfs_stop_id = gtfs_stop.id

      assert [%Arrow.Gtfs.Stop{id: ^gtfs_stop_id}] =
               Shuttles.stops_or_gtfs_stops_by_search_string("Des")
    end

    test "finds GTFS stop by stop name" do
      gtfs_stop = insert(:gtfs_stop, %{name: "Name"})
      gtfs_stop_id = gtfs_stop.id

      assert [%Arrow.Gtfs.Stop{id: ^gtfs_stop_id}] =
               Shuttles.stops_or_gtfs_stops_by_search_string("Na")
    end

    test "finds Arrow and GTFS stops when both match, with Arrow first" do
      stop = insert(:stop, %{stop_desc: "Description A"})
      stop_id = stop.stop_id

      gtfs_stop = insert(:gtfs_stop, %{desc: "Description B"})
      gtfs_stop_id = gtfs_stop.id

      assert [%Stop{stop_id: ^stop_id}, %Arrow.Gtfs.Stop{id: ^gtfs_stop_id}] =
               Shuttles.stops_or_gtfs_stops_by_search_string("Des")
    end

    test "when a stop ID is duplicated in Arrow and GTFS, returns the Arrow one" do
      insert(:stop, %{stop_id: "stop"})

      insert(:gtfs_stop, %{id: "stop"})

      assert [%Stop{stop_id: "stop"}] =
               Shuttles.stops_or_gtfs_stops_by_search_string("st")
    end
  end

  describe "get_travel_times/1" do
    test "calculates travel time between coordinates" do
      expect(
        MockClient,
        :get_directions,
        fn %DirectionsRequest{
             coordinates: [[-71.11934, 42.38758], [-71.1202, 42.373396]] = coordinates
           } ->
          {:ok,
           build(
             :ors_directions_json,
             %{
               coordinates: coordinates,
               segments: [
                 %{
                   "duration" => 100,
                   "distance" => 0.20
                 },
                 %{
                   "duration" => 100,
                   "distance" => 0.20
                 }
               ]
             }
           )}
        end
      )

      coord1 = %{"lat" => 42.38758, "lon" => -71.11934}
      coord2 = %{"lat" => 42.373396, "lon" => -71.1202}

      {:ok, [100, 100]} = Shuttles.get_travel_times([coord1, coord2])
    end

    test "handles atom keys for coordinates" do
      expect(
        MockClient,
        :get_directions,
        fn %DirectionsRequest{
             coordinates: [[-71.11934, 42.38758], [-71.1202, 42.373396]] = coordinates
           } ->
          {:ok,
           build(
             :ors_directions_json,
             %{
               coordinates: coordinates,
               segments: [
                 %{
                   "duration" => 100,
                   "distance" => 0.20
                 },
                 %{
                   "duration" => 100,
                   "distance" => 0.20
                 }
               ]
             }
           )}
        end
      )

      coord1 = %{lat: 42.38758, lon: -71.11934}
      coord2 = %{lat: 42.373396, lon: -71.1202}

      {:ok, [100, 100]} = Shuttles.get_travel_times([coord1, coord2])
    end

    test "errors if it cannot determine a route between the coordinates" do
      expect(
        MockClient,
        :get_directions,
        fn %DirectionsRequest{} -> {:error, %{"code" => 2010}} end
      )

      coord1 = %{"lat" => 42.38758, "lon" => -71.11934}
      coord2 = %{"lat" => 42.373396, "lon" => -70.1202}

      assert {:error, "Unable to retrieve estimates: no route between stops found"} =
               Shuttles.get_travel_times([coord1, coord2])
    end

    test "errors if OpenRouteService returns an unknown error" do
      expect(
        MockClient,
        :get_directions,
        fn %DirectionsRequest{} -> {:error, %{"code" => -1}} end
      )

      coord1 = %{"lat" => 42.38758, "lon" => -71.11934}
      coord2 = %{"lat" => 42.373396, "lon" => -70.1202}

      assert {:error, "Unable to retrieve estimates: unknown error"} =
               Shuttles.get_travel_times([coord1, coord2])
    end
  end

  describe "get_display_stop_id/1" do
    test "gets ID of Arrow stop" do
      route_stop = build(:route_stop, stop: build(:stop, stop_id: "test_stop_id"))

      assert Shuttles.get_display_stop_id(route_stop) == "test_stop_id"
    end

    test "gets ID of GTFS stop" do
      route_stop = build(:route_stop, gtfs_stop_id: "test_gtfs_stop_id")

      assert Shuttles.get_display_stop_id(route_stop) == "test_gtfs_stop_id"
    end
  end

  describe "get_stop_coordinates/1" do
    test "gets the stop coordinates for an Arrow stop from a RouteStop" do
      lat = 42.38758
      lon = -71.11934

      arrow_stop = stop_fixture(%{stop_lat: lat, stop_lon: lon})

      stop = %Shuttles.RouteStop{
        id: 1,
        stop: arrow_stop,
        gtfs_stop: nil,
        display_stop: nil,
        display_stop_id: arrow_stop.stop_id
      }

      coordinates = %{lat: lat, lon: lon}

      assert {:ok, ^coordinates} = Shuttles.get_stop_coordinates(stop)
    end

    test "gets the stop coordinates for an gtfs stop from a RouteStop" do
      gtfs_stop = insert(:gtfs_stop)
      coordinates = %{lat: gtfs_stop.lat, lon: gtfs_stop.lon}

      stop = %Shuttles.RouteStop{
        id: 1,
        gtfs_stop: gtfs_stop,
        stop: nil,
        display_stop: nil,
        display_stop_id: gtfs_stop.id
      }

      assert {:ok, ^coordinates} = Shuttles.get_stop_coordinates(stop)
    end

    test "gets the stop coordinates for an Arrow stop" do
      lat = 42.38758
      lon = -71.11934
      stop = stop_fixture(%{stop_lat: lat, stop_lon: lon})
      coordinates = %{lat: lat, lon: lon}

      assert {:ok, ^coordinates} = Shuttles.get_stop_coordinates(stop)
    end

    test "gets the stop coordinates for a GTFS stop" do
      gtfs_stop = insert(:gtfs_stop)
      coordinates = %{lat: gtfs_stop.lat, lon: gtfs_stop.lon}

      assert {:ok, ^coordinates} = Shuttles.get_stop_coordinates(gtfs_stop)
    end

    test "raises if a stop has missing lat/lon data" do
      stop2 =
        %{stop_lat: 42.373396, stop_lon: -70.1202}
        |> stop_fixture()
        |> Map.drop([:stop_lat, :stop_lon])

      assert {:error, error_message} = Shuttles.get_stop_coordinates(stop2)
      assert error_message =~ ~r/Missing lat\/lon/
    end
  end
end
