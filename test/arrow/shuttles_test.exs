defmodule Arrow.ShuttlesTest do
  use Arrow.DataCase

  import Arrow.Factory
  alias Arrow.Shuttles
  alias Arrow.Shuttles.Shape
  import Arrow.ShuttlesFixtures
  import Arrow.StopsFixtures
  import Test.Support.Helpers

  describe "shapes with s3 functionality enabled (mocked)" do
    @valid_shape %{
      name: "some name-S",
      coordinates: "-71.14163,42.39551 -71.14163,42.39551 -71.14163,42.39551"
    }

    test "create_shape/1 with valid data creates a shape when shape storage is enabled" do
      reassign_env(:shape_storage_enabled?, true)
      reassign_env(:shape_storage_prefix, "prefix/#{Ecto.UUID.generate()}/")

      assert {:ok, %Shape{} = shape} = Shuttles.create_shape(@valid_shape)
      assert shape.name == "some name-S"
      Application.put_env(:arrow, :shape_storage_enabled?, false)
    end

    test "create_shape/1 with name that does not end in -S adds it" do
      Application.put_env(:arrow, :shape_storage_enabled?, true)
      Application.put_env(:arrow, :shape_storage_prefix, "prefix/#{Ecto.UUID.generate()}/")

      assert {:ok, %Shape{} = shape} =
               Shuttles.create_shape(%{name: "some name", coordinates: coords()})

      assert shape.name == "some name-S"
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
      assert %Ecto.Changeset{valid?: true} = Shuttles.get_shapes_upload(shape)
    end
  end

  describe "shapes" do
    @valid_attrs %{name: "some name-S", coordinates: coords()}
    @invalid_attrs %{name: "", coordinates: nil}

    test "list_shapes/0 returns all shapes" do
      shape = shape_fixture()
      assert Shuttles.list_shapes() == [shape]
    end

    test "get_shape!/1 returns the shape with given id" do
      shape = shape_fixture()
      assert Shuttles.get_shape!(shape.id) == shape
    end

    test "create_shapes/1 with valid data creates a shape" do
      assert {:ok, [{:ok, %Shape{} = shape}]} = Shuttles.create_shapes([@valid_attrs])
      assert shape.name == "some name-S"
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
      update_attrs = %{status: :draft, shuttle_name: "some updated shuttle_name"}

      assert {:ok, %Shuttle{} = shuttle} = Shuttles.update_shuttle(shuttle, update_attrs)
      assert shuttle.status == :draft
      assert shuttle.shuttle_name == "some updated shuttle_name"
    end

    test "update_shuttle/2 with valid route data updates the shuttle route" do
      shuttle = shuttle_fixture()
      [route1, route2] = shuttle.routes
      destination = unique_shuttle_route_destination()
      updated_route1 = Map.merge(route1, %{destination: destination})

      update_attrs =
        Map.from_struct(%Shuttle{
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
      updated_route1 = Map.merge(List.first(routes), %{shape_id: new_shape.id})
      existing_route2 = Enum.at(routes, 1)

      update_attrs =
        Map.from_struct(%Shuttle{
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

      assert %Arrow.Shuttles.Stop{stop_id: ^stop_id} =
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

      assert %Arrow.Shuttles.Stop{stop_id: ^stop_id} =
               Shuttles.stop_or_gtfs_stop_for_stop_id(stop_id)
    end

    test "returns nil if no stops are found" do
      assert is_nil(Shuttles.stop_or_gtfs_stop_for_stop_id("nonexistent-stop"))
    end
  end
end
