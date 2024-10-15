defmodule Arrow.StopsTest do
  @moduledoc false
  use Arrow.DataCase

  alias Arrow.Stops

  describe "stops" do
    alias Arrow.Shuttles.Stop

    import Arrow.StopsFixtures

    @invalid_attrs %{
      stop_id: nil,
      stop_name: nil,
      stop_desc: nil,
      platform_code: nil,
      platform_name: nil,
      stop_lat: nil,
      stop_lon: nil,
      stop_address: nil,
      zone_id: nil,
      level_id: nil,
      parent_station: nil,
      municipality: nil,
      on_street: nil,
      at_street: nil
    }

    test "list_stops/0 returns all stops" do
      stop = stop_fixture()
      assert Stops.list_stops() == [stop]
    end

    test "list_stops/1 returns all stops sorted by order_by param" do
      stop_a = stop_fixture(%{stop_name: "Stop A"})
      stop_z = stop_fixture(%{stop_name: "Stop Z"})
      assert Stops.list_stops(%{"order_by" => "stop_name_desc"}) == [stop_z, stop_a]
      assert Stops.list_stops(%{"order_by" => "stop_name_asc"}) == [stop_a, stop_z]
    end

    test "get_stop!/1 returns the stop with given id" do
      stop = stop_fixture()
      assert Stops.get_stop!(stop.id) == stop
    end

    test "create_stop/1 with valid data creates a stop" do
      valid_attrs = %{
        stop_id: "some stop_id",
        stop_name: "some stop_name",
        stop_desc: "some stop_desc",
        platform_code: "some platform_code",
        platform_name: "some platform_name",
        stop_lat: 120.5,
        stop_lon: 120.5,
        stop_address: "some stop_address",
        zone_id: "some zone_id",
        level_id: "some level_id",
        parent_station: "some parent_station",
        municipality: "some municipality",
        on_street: "some on_street",
        at_street: "some at_street"
      }

      assert {:ok, %Stop{} = stop} = Stops.create_stop(valid_attrs)
      assert stop.stop_id == "some stop_id"
      assert stop.stop_name == "some stop_name"
      assert stop.stop_desc == "some stop_desc"
      assert stop.platform_code == "some platform_code"
      assert stop.platform_name == "some platform_name"
      assert stop.stop_lat == 120.5
      assert stop.stop_lon == 120.5
      assert stop.stop_address == "some stop_address"
      assert stop.zone_id == "some zone_id"
      assert stop.level_id == "some level_id"
      assert stop.parent_station == "some parent_station"
      assert stop.municipality == "some municipality"
      assert stop.on_street == "some on_street"
      assert stop.at_street == "some at_street"
    end

    test "creating a stop with a duplicate stop_id returns an error" do
      stop = stop_fixture()

      assert {:error, %Ecto.Changeset{} = change} =
               Stops.create_stop(%{
                 stop_id: stop.stop_id,
                 stop_name: "some stop_name",
                 stop_desc: "some stop_desc",
                 platform_code: "some platform_code",
                 platform_name: "some platform_name",
                 stop_lat: 120.5,
                 stop_lon: 120.5,
                 stop_address: "some stop_address",
                 zone_id: "some zone_id",
                 level_id: "some level_id",
                 parent_station: "some parent_station",
                 municipality: "some municipality",
                 on_street: "some on_street",
                 at_street: "some at_street"
               })

      assert {_, error} = change.errors[:stop_id]
      assert error == [validation: :unsafe_unique, fields: [:stop_id]]
    end

    test "create_stop/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stops.create_stop(@invalid_attrs)
    end

    test "update_stop/2 with valid data updates the stop" do
      stop = stop_fixture()

      update_attrs = %{
        stop_id: "some updated stop_id",
        stop_name: "some updated stop_name",
        stop_desc: "some updated stop_desc",
        platform_code: "some updated platform_code",
        platform_name: "some updated platform_name",
        stop_lat: 456.7,
        stop_lon: 456.7,
        stop_address: "some updated stop_address",
        zone_id: "some updated zone_id",
        level_id: "some updated level_id",
        parent_station: "some updated parent_station",
        municipality: "some updated municipality",
        on_street: "some updated on_street",
        at_street: "some updated at_street"
      }

      assert {:ok, %Stop{} = stop} = Stops.update_stop(stop, update_attrs)
      assert stop.stop_id == "some updated stop_id"
      assert stop.stop_name == "some updated stop_name"
      assert stop.stop_desc == "some updated stop_desc"
      assert stop.platform_code == "some updated platform_code"
      assert stop.platform_name == "some updated platform_name"
      assert stop.stop_lat == 456.7
      assert stop.stop_lon == 456.7
      assert stop.stop_address == "some updated stop_address"
      assert stop.zone_id == "some updated zone_id"
      assert stop.level_id == "some updated level_id"
      assert stop.parent_station == "some updated parent_station"
      assert stop.municipality == "some updated municipality"
      assert stop.on_street == "some updated on_street"
      assert stop.at_street == "some updated at_street"
    end

    test "update_stop/2 with invalid data returns error changeset" do
      stop = stop_fixture()
      assert {:error, %Ecto.Changeset{}} = Stops.update_stop(stop, @invalid_attrs)
      assert stop == Stops.get_stop!(stop.id)
    end

    test "updating stop_id to existing id returns an error" do
      stop1 = stop_fixture()
      stop2 = stop_fixture()

      assert {:error, %Ecto.Changeset{} = change} =
               Stops.update_stop(stop1, %{stop_id: stop2.stop_id})

      assert {_, error} = change.errors[:stop_id]
      assert error == [validation: :unsafe_unique, fields: [:stop_id]]
    end

    test "delete_stop/1 deletes the stop" do
      stop = stop_fixture()
      assert {:ok, %Stop{}} = Stops.delete_stop(stop)
      assert_raise Ecto.NoResultsError, fn -> Stops.get_stop!(stop.id) end
    end

    test "change_stop/1 returns a stop changeset" do
      stop = stop_fixture()
      assert %Ecto.Changeset{} = Stops.change_stop(stop)
    end
  end
end
