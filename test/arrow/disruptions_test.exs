defmodule Arrow.DisruptionsTest do
  alias Arrow.DisruptionsFixtures
  alias Arrow.ShuttlesFixtures
  use Arrow.DataCase

  alias Arrow.Disruptions

  describe "disruptionsv2" do
    alias Arrow.Disruptions.DisruptionV2

    import Arrow.DisruptionsFixtures

    @invalid_attrs %{title: "foobar", description: "barfoo", mode: nil, status: :approved}

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
        status: :approved,
        description: "Run for the hills"
      }

      assert {:ok, %DisruptionV2{} = disruption_v2} =
               Disruptions.create_disruption_v2(valid_attrs)

      assert disruption_v2.title == valid_attrs.title
      assert to_string(disruption_v2.mode) == valid_attrs.mode
      assert disruption_v2.status == valid_attrs.status
      assert disruption_v2.description == valid_attrs.description
    end

    test "create_disruption_v2/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Disruptions.create_disruption_v2(@invalid_attrs)
    end

    test "update_disruption_v2/2 with valid data updates the disruption_v2" do
      disruption_v2 = disruption_v2_fixture()

      update_attrs = %{
        title: "some updated name",
        status: :approved,
        description: "bar",
        mode: "subway"
      }

      assert {:ok, %DisruptionV2{} = disruption_v2} =
               Disruptions.update_disruption_v2(disruption_v2, update_attrs)

      assert disruption_v2.title == update_attrs.title
      assert to_string(disruption_v2.mode) == update_attrs.mode
      assert disruption_v2.status == update_attrs.status
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

    test "get_replacement_service!/1 returns the replacement_service with given id" do
      replacement_service = replacement_service_fixture()
      assert Disruptions.get_replacement_service!(replacement_service.id) == replacement_service
    end

    test "create_replacement_service/1 with valid data creates a replacement_service" do
      disruption = DisruptionsFixtures.disruption_v2_fixture()
      shuttle = ShuttlesFixtures.shuttle_fixture()

      valid_attrs = %{
        reason: "some reason",
        start_date: ~D[2025-01-21],
        end_date: ~D[2025-01-22],
        source_workbook_data: %{},
        source_workbook_filename: "some source_workbook_filename",
        shuttle_id: shuttle.id,
        disruption_id: disruption.id
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

  describe "replacement_service_trips_with_times/2" do
    test "generates trip times" do
      shuttle = Arrow.ShuttlesFixtures.shuttle_fixture(%{}, true, true)
      replacement_service = build(:replacement_service, %{shuttle: shuttle})

      result = Disruptions.replacement_service_trips_with_times(replacement_service, "WKDY")

      assert %{"0" => direction_0_trips, "1" => direction_1_trips} = result
      assert length(direction_0_trips) == 8
      assert length(direction_1_trips) == 8

      assert Enum.each(direction_0_trips, fn %{stop_times: stop_times} ->
               length(stop_times) == 4
             end)

      assert Enum.each(direction_1_trips, fn %{stop_times: stop_times} ->
               length(stop_times) == 4
             end)

      assert direction_0_trips
             |> Enum.filter(
               &match?(
                 %{
                   stop_times: [
                     %{stop_id: _, stop_time: "05:10"},
                     %{stop_id: _, stop_time: "05:14"},
                     %{stop_id: _, stop_time: "05:22"},
                     %{stop_id: _, stop_time: "05:35"}
                   ]
                 },
                 &1
               )
             )
             |> length() == 1

      assert direction_0_trips
             |> Enum.filter(
               &match?(
                 %{
                   stop_times: [
                     %{stop_id: _, stop_time: "06:30"},
                     %{stop_id: _, stop_time: "06:35"},
                     %{stop_id: _, stop_time: "06:45"},
                     %{stop_id: _, stop_time: "07:00"}
                   ]
                 },
                 &1
               )
             )
             |> length() == 1

      assert direction_1_trips
             |> Enum.filter(
               &match?(
                 %{
                   stop_times: [
                     %{stop_id: _, stop_time: "05:10"},
                     %{stop_id: _, stop_time: "05:13"},
                     %{stop_id: _, stop_time: "05:18"},
                     %{stop_id: _, stop_time: "05:26"}
                   ]
                 },
                 &1
               )
             )
             |> length() == 1

      assert direction_1_trips
             |> Enum.filter(
               &match?(
                 %{
                   stop_times: [
                     %{stop_id: _, stop_time: "06:30"},
                     %{stop_id: _, stop_time: "06:33"},
                     %{stop_id: _, stop_time: "06:40"},
                     %{stop_id: _, stop_time: "06:50"}
                   ]
                 },
                 &1
               )
             )
             |> length() == 1
    end
  end
end
