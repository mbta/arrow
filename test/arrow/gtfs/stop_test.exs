defmodule Arrow.Gtfs.StopTest do
  use Arrow.DataCase

  import Arrow.Factory

  alias Arrow.Gtfs.Stop

  test "get_stops_within_mile/2 returns stops roughly within one mile of a stop" do
    harvard_lat = 42.3744
    harvard_lon = -71.1182
    harvard_stop_id = "harvard-or-whatever"
    near_harvard_stop_id = "near-harvard"
    _stop_harvard = insert(:gtfs_stop, %{id: harvard_stop_id, lat: harvard_lat, lon: harvard_lon})

    _stop_close_to_harvard =
      insert(:gtfs_stop, %{id: near_harvard_stop_id, lat: 42.3741, lon: -71.1181})

    _stop_stony_brook = insert(:gtfs_stop, %{id: "jp!!", lat: 42.3172, lon: -71.1043})

    res = Stop.get_stops_within_mile(harvard_stop_id, {harvard_lat, harvard_lon})

    # only the stop near harvard should be returned
    assert length(res) == 1
    [stop] = res
    assert stop.id == near_harvard_stop_id
  end

  test "get_stops_within_mile/2 works when nil stop ID passed" do
    harvard_lat = 42.3744
    harvard_lon = -71.1182
    near_harvard_stop_id = "near-harvard"

    _stop_close_to_harvard =
      insert(:gtfs_stop, %{id: near_harvard_stop_id, lat: 42.3741, lon: -71.1181})

    _stop_stony_brook = insert(:gtfs_stop, %{id: "jp!!", lat: 42.3172, lon: -71.1043})

    res = Stop.get_stops_within_mile(nil, {harvard_lat, harvard_lon})

    assert length(res) == 1
    [stop] = res
    assert stop.id == near_harvard_stop_id
  end
end
