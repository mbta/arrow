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
      assert to_string(disruption_v2.mode) == valid_attrs.mode
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
      assert to_string(disruption_v2.mode) == update_attrs.mode
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

  describe "replacement_services" do
    alias Arrow.Disruptions.ReplacementService

    import Arrow.DisruptionsFixtures

    @invalid_attrs %{
      reason: nil,
      start_date: nil,
      end_date: nil,
      source_workbook_data: nil,
      source_workbook_filename: nil
    }

    test "list_replacement_services/0 returns all replacement_services" do
      replacement_service = replacement_service_fixture()
      assert Disruptions.list_replacement_services() == [replacement_service]
    end

    test "get_replacement_service!/1 returns the replacement_service with given id" do
      replacement_service = replacement_service_fixture()
      assert Disruptions.get_replacement_service!(replacement_service.id) == replacement_service
    end

    test "create_replacement_service/1 with valid data creates a replacement_service" do
      valid_attrs = %{
        reason: "some reason",
        start_date: ~D[2025-01-21],
        end_date: ~D[2025-01-22],
        source_workbook_data: %{},
        source_workbook_filename: "some source_workbook_filename"
      }

      assert {:ok, %ReplacementService{} = replacement_service} =
               Disruptions.create_replacement_service(valid_attrs)

      assert replacement_service.reason == "some reason"
      assert replacement_service.start_date == ~D[2025-01-21]
      assert replacement_service.end_date == ~D[2025-01-22]
      assert replacement_service.source_workbook_data == %{}
      assert replacement_service.source_workbook_filename == "some source_workbook_filename"
    end

    test "create_replacement_service/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Disruptions.create_replacement_service(@invalid_attrs)
    end

    test "update_replacement_service/2 with valid data updates the replacement_service" do
      replacement_service = replacement_service_fixture()

      update_attrs = %{
        reason: "some updated reason",
        start_date: ~D[2025-01-22],
        end_date: ~D[2025-01-23],
        source_workbook_data: %{},
        source_workbook_filename: "some updated source_workbook_filename"
      }

      assert {:ok, %ReplacementService{} = replacement_service} =
               Disruptions.update_replacement_service(replacement_service, update_attrs)

      assert replacement_service.reason == "some updated reason"
      assert replacement_service.start_date == ~D[2025-01-22]
      assert replacement_service.end_date == ~D[2025-01-23]
      assert replacement_service.source_workbook_data == %{}

      assert replacement_service.source_workbook_filename ==
               "some updated source_workbook_filename"
    end

    test "update_replacement_service/2 with invalid data returns error changeset" do
      replacement_service = replacement_service_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Disruptions.update_replacement_service(replacement_service, @invalid_attrs)

      assert replacement_service == Disruptions.get_replacement_service!(replacement_service.id)
    end

    test "delete_replacement_service/1 deletes the replacement_service" do
      replacement_service = replacement_service_fixture()

      assert {:ok, %ReplacementService{}} =
               Disruptions.delete_replacement_service(replacement_service)

      assert_raise Ecto.NoResultsError, fn ->
        Disruptions.get_replacement_service!(replacement_service.id)
      end
    end

    test "change_replacement_service/1 returns a replacement_service changeset" do
      replacement_service = replacement_service_fixture()
      assert %Ecto.Changeset{} = Disruptions.change_replacement_service(replacement_service)
    end
  end
end
