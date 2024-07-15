defmodule Arrow.ShuttleTest do
  use Arrow.DataCase

  alias Arrow.Shuttle

  describe "shapes with s3 functionality enabled (mocked)" do
    alias Arrow.Shuttle.Shape

    @valid_shape %{
      name: "some name",
      coordinates: "-71.14163,42.39551 -71.14163,42.39551 -71.14163,42.39551"
    }

    import Arrow.ShuttleFixtures

    setup do
      Application.put_env(:arrow, :shape_storage_enabled?, true)
      on_exit(fn -> Application.put_env(:arrow, :shape_storage_enabled?, false) end)
    end

    test "create_shape/1 with valid data creates a shape when shape storage is enabled" do
      Application.put_env(:arrow, :shape_storage_enabled?, true)
      Application.put_env(:arrow, :shape_storage_prefix, "prefix/#{Ecto.UUID.generate()}/")

      assert {:ok, %Shape{} = shape} = Shuttle.create_shape(@valid_shape)
      assert shape.name == "some name"
      Application.put_env(:arrow, :shape_storage_enabled?, false)
    end

    test "delete_shape/1 deletes the shape" do
      Application.put_env(:arrow, :shape_storage_enabled?, true)

      assert {:ok, %Shape{} = shape} = Shuttle.create_shape(@valid_shape)
      assert {:ok, %Shape{}} = Shuttle.delete_shape(shape)
      assert_raise Ecto.NoResultsError, fn -> Shuttle.get_shape!(shape.id) end
      Application.put_env(:arrow, :shape_storage_enabled?, false)
    end
  end

  describe "shapes" do
    alias Arrow.Shuttle.Shape

    import Arrow.ShuttleFixtures
    @valid_attrs %{name: "some name", coordinates: coords()}
    @invalid_attrs %{name: "", coordinates: nil}

    test "list_shapes/0 returns all shapes" do
      shape = shape_fixture()
      assert Shuttle.list_shapes() == [shape]
    end

    test "get_shape!/1 returns the shape with given id" do
      shape = shape_fixture()
      assert Shuttle.get_shape!(shape.id) == shape
    end

    test "create_shapes/1 with valid data creates a shape" do
      assert {:ok, [{:ok, %Shape{} = shape}]} = Shuttle.create_shapes([@valid_attrs])
      assert shape.name == "some name"
    end

    test "create_shapes/1 with invalid data returns error changeset" do
      assert {:error, {"Failed to upload some shapes", changeset}} =
               Shuttle.create_shapes([@invalid_attrs])

      assert ["Name can't be blank "] = changeset
    end

    test "create_shapes/1 creates valid and returns errors for invalid" do
      name = @valid_attrs.name
      refute Repo.get_by(Arrow.Shuttle.Shape, name: name)

      assert {:error, {"Failed to upload some shapes", changeset}} =
               Shuttle.create_shapes([@valid_attrs, @invalid_attrs])

      assert ["Name can't be blank "] = changeset
      assert %Shape{name: ^name} = Repo.get_by(Arrow.Shuttle.Shape, name: name)
    end

    test "create_shape/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shuttle.create_shape(@invalid_attrs)
    end

    test "create_shape/1 with existing name returns an error" do
      assert {:ok, %Shape{}} = Shuttle.create_shape(@valid_attrs)
      # Trying to create a second time throws an error
      assert {:error, message} = Shuttle.create_shape(@valid_attrs)
      assert message =~ "already exists"
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
