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
end
