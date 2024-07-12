defmodule Arrow.ShuttleTest do
  use Arrow.DataCase

  alias Arrow.Shuttle

  describe "shapes with s3 functionality enabled (mocked)" do
    alias Arrow.Shuttle.Shape

    import Arrow.ShuttleFixtures

    setup do
      Application.put_env(:arrow, :shape_storage_enabled?, true)
      on_exit(fn -> Application.put_env(:arrow, :shape_storage_enabled?, false) end)
    end

    test "create_shape/1 with valid data creates a shape when shape storage is enabled" do
      Application.put_env(:arrow, :shape_storage_enabled?, true)
      Application.put_env(:arrow, :shape_storage_prefix, "prefix/#{Ecto.UUID.generate()}/")

      valid_shape = %{
        name: "some name",
        coordinates: "-71.14163,42.39551 -71.14163,42.39551 -71.14163,42.39551"
      }

      assert {:ok, %Shape{} = shape} = Shuttle.create_shape(valid_shape)
      assert shape.name == "some name"
      Application.put_env(:arrow, :shape_storage_enabled?, false)
    end
  end

  describe "shapes" do
    alias Arrow.Shuttle.Shape

    import Arrow.ShuttleFixtures
    @invalid_attrs %{name: "", coordinates: nil}

    test "list_shapes/0 returns all shapes" do
      shape = shape_fixture()
      assert Shuttle.list_shapes() == [shape]
    end

    test "get_shape!/1 returns the shape with given id" do
      shape = shape_fixture()
      assert Shuttle.get_shape!(shape.id) == shape
    end

    test "create_shape/1 with valid data creates a shape" do
      valid_attrs = [%{name: "some name", coordinates: coords()}]

      assert {:ok, [{:ok, %Shape{} = shape}]} = Shuttle.create_shapes(valid_attrs)
      assert shape.name == "some name"
    end

    test "create_shape/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shuttle.create_shape(@invalid_attrs)
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
