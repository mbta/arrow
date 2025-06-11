defmodule Arrow.StopsTest do
  @moduledoc false
  use Arrow.DataCase

  alias Arrow.Stops

  describe "stops" do
    import Arrow.StopsFixtures

    alias Arrow.Shuttles.Stop

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

    test "get_stop_by_stop_id/1 returns stop when found" do
      stop = stop_fixture()
      assert Stops.get_stop_by_stop_id(stop.stop_id) == stop
    end

    test "get_stop_by_stop_id/1 returns nil when stop not found" do
      assert Stops.get_stop_by_stop_id("nonexistent") == nil
    end

    test "get_stops_within_mile/2 returns stops roughly within one mile of a stop" do
      harvard_lat = 42.3744
      harvard_lon = -71.1182
      harvard_stop_id = "harvard-or-whatever"
      near_harvard_stop_id = "near-harvard"

      _stop_harvard =
        stop_fixture(%{stop_id: harvard_stop_id, stop_lat: harvard_lat, stop_lon: harvard_lon})

      _stop_close_to_harvard =
        stop_fixture(%{stop_id: near_harvard_stop_id, stop_lat: 42.3741, stop_lon: -71.1181})

      _stop_stony_brook = stop_fixture(%{stop_id: "jp!!", stop_lat: 42.3172, stop_lon: -71.1043})

      res = Stops.get_stops_within_mile(harvard_stop_id, {harvard_lat, harvard_lon})

      # only the stop near harvard should be returned
      assert length(res) == 1
      [stop] = res
      assert stop.stop_id == near_harvard_stop_id
    end

    test "get_stops_within_mile/2 returns stops when nil stop_id is passed" do
      harvard_lat = 42.3744
      harvard_lon = -71.1182
      near_harvard_stop_id = "near-harvard"

      _stop_close_to_harvard =
        stop_fixture(%{stop_id: near_harvard_stop_id, stop_lat: 42.3741, stop_lon: -71.1181})

      _stop_stony_brook = stop_fixture(%{stop_id: "jp!!", stop_lat: 42.3172, stop_lon: -71.1043})

      res = Stops.get_stops_within_mile(nil, {harvard_lat, harvard_lon})

      assert length(res) == 1
      [stop] = res
      assert stop.stop_id == near_harvard_stop_id
    end
  end
end
