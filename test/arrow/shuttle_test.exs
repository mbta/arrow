defmodule Arrow.ShuttleTest do
  use Arrow.DataCase

  alias Arrow.Shuttle

  describe "shapes" do
    alias Arrow.Shuttle.Shape

    import Arrow.ShuttleFixtures

    @invalid_attrs %{name: nil}

    test "list_shapes/0 returns all shapes" do
      shape = shape_fixture()
      assert Shuttle.list_shapes() == [shape]
    end

    test "get_shape!/1 returns the shape with given id" do
      shape = shape_fixture()
      assert Shuttle.get_shape!(shape.id) == shape
    end

    test "create_shape/1 with valid data creates a shape" do
      valid_attrs = %{
        name: "some name",
        path: "some/path/to/file.kml",
        prefix: "some/path/to",
        bucket: "some-mbta-bucket",
        filename: %Plug.Upload{filename: "file.kml"}
      }

      assert {:ok, %Shape{} = shape} = Shuttle.create_shape(valid_attrs)
      assert shape.name == "some name"
    end

    test "create_shape/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shuttle.create_shape(@invalid_attrs)
    end

    test "update_shape/2 with valid data updates the shape" do
      shape = shape_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Shape{} = shape} = Shuttle.update_shape(shape, update_attrs)
      assert shape.name == "some updated name"
    end

    test "update_shape/2 with invalid data returns error changeset" do
      shape = shape_fixture()
      assert {:error, %Ecto.Changeset{}} = Shuttle.update_shape(shape, @invalid_attrs)
      assert shape == Shuttle.get_shape!(shape.id)
    end

    test "delete_shape/1 deletes the shape" do
      shape = shape_fixture()
      assert {:ok, %Shape{}} = Shuttle.delete_shape(shape)
      assert_raise Ecto.NoResultsError, fn -> Shuttle.get_shape!(shape.id) end
    end

    test "change_shape/1 returns a shape changeset" do
      shape = shape_fixture()
      assert %Ecto.Changeset{} = Shuttle.change_shape(shape)
    end
  end
end
