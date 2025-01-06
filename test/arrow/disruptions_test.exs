defmodule Arrow.DisruptionsTest do
  use Arrow.DataCase

  alias Arrow.Disruptions

  describe "disruptionsv2" do
    alias Arrow.Disruptions.DisruptionV2

    import Arrow.DisruptionsFixtures

    @invalid_attrs %{title: "foobar", description: "barfoo", mode: nil, is_active: true}

    test "list_disruptionsv2/0 returns all disruptionsv2" do
      disruption_v2 = disruption_v2_fixture()
      assert Disruptions.list_disruptionsv2() == [disruption_v2]
    end

    test "get_disruption_v2!/1 returns the disruption_v2 with given id" do
      disruption_v2 = disruption_v2_fixture()
      assert Disruptions.get_disruption_v2!(disruption_v2.id) == disruption_v2
    end

    test "create_disruption_v2/1 with valid data creates a disruption_v2" do
      valid_attrs = %{
        title: "the great molasses disruption of 2025",
        mode: "commuter_rail",
        is_active: true,
        description: "Run for the hills"
      }

      assert {:ok, %DisruptionV2{} = disruption_v2} =
               Disruptions.create_disruption_v2(valid_attrs)

      assert disruption_v2.title == valid_attrs.title
      assert disruption_v2.mode == valid_attrs.mode
      assert disruption_v2.is_active == valid_attrs.is_active
      assert disruption_v2.description == valid_attrs.description
    end

    test "create_disruption_v2/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Disruptions.create_disruption_v2(@invalid_attrs)
    end

    test "update_disruption_v2/2 with valid data updates the disruption_v2" do
      disruption_v2 = disruption_v2_fixture()

      update_attrs = %{
        title: "some updated name",
        is_active: true,
        description: "bar",
        mode: "subway"
      }

      assert {:ok, %DisruptionV2{} = disruption_v2} =
               Disruptions.update_disruption_v2(disruption_v2, update_attrs)

      assert disruption_v2.title == update_attrs.title
      assert disruption_v2.mode == update_attrs.mode
      assert disruption_v2.is_active == update_attrs.is_active
      assert disruption_v2.description == update_attrs.description
    end

    test "update_disruption_v2/2 with invalid data returns error changeset" do
      disruption_v2 = disruption_v2_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Disruptions.update_disruption_v2(disruption_v2, @invalid_attrs)

      assert disruption_v2 == Disruptions.get_disruption_v2!(disruption_v2.id)
    end

    test "delete_disruption_v2/1 deletes the disruption_v2" do
      disruption_v2 = disruption_v2_fixture()
      assert {:ok, %DisruptionV2{}} = Disruptions.delete_disruption_v2(disruption_v2)
      assert_raise Ecto.NoResultsError, fn -> Disruptions.get_disruption_v2!(disruption_v2.id) end
    end

    test "change_disruption_v2/1 returns a disruption_v2 changeset" do
      disruption_v2 = disruption_v2_fixture()
      assert %Ecto.Changeset{} = Disruptions.change_disruption_v2(disruption_v2)
    end
  end
end
