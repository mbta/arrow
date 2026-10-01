defmodule ArrowWeb.API.CSV.StopsControllerTest do
  use ArrowWeb.ConnCase
  import Arrow.Factory

  describe "index/2" do
    @tag :authenticated
    test "non-admin user can access the stops API", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/csv/shuttle-stops")
    end

    @tag :authenticated_admin
    test "returns 200", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/csv/shuttle-stops")
    end

    @tag :authenticated_admin
    test "includes all stops", %{conn: conn} do
      stop1 = insert(:stop)
      stop2 = insert(:stop)
      stop3 = insert(:stop)

      resp = get(conn, "/api/csv/shuttle-stops")
      _ = response_content_type(resp, :csv)

      data = [response(resp, 200)] |> CSV.decode!(headers: true) |> Enum.to_list()

      assert [
               %{
                 "municipality" => "Boston",
                 "stop_desc" => stop1.stop_desc,
                 "stop_id" => stop1.stop_id,
                 "stop_lat" => to_string(stop1.stop_lat),
                 "stop_lon" => to_string(stop1.stop_lon),
                 "stop_name" => stop1.stop_name,
                 "at_street" => "",
                 "level_id" => "",
                 "location_type" => "",
                 "on_street" => "",
                 "parent_station" => "",
                 "platform_code" => "",
                 "platform_name" => "",
                 "stop_address" => "",
                 "stop_code" => "",
                 "stop_url" => "",
                 "vehicle_type" => "",
                 "wheelchair_boarding" => "",
                 "zone_id" => ""
               },
               %{
                 "municipality" => "Boston",
                 "stop_desc" => stop2.stop_desc,
                 "stop_id" => stop2.stop_id,
                 "stop_lat" => to_string(stop2.stop_lat),
                 "stop_lon" => to_string(stop2.stop_lon),
                 "stop_name" => stop2.stop_name,
                 "at_street" => "",
                 "level_id" => "",
                 "location_type" => "",
                 "on_street" => "",
                 "parent_station" => "",
                 "platform_code" => "",
                 "platform_name" => "",
                 "stop_address" => "",
                 "stop_code" => "",
                 "stop_url" => "",
                 "vehicle_type" => "",
                 "wheelchair_boarding" => "",
                 "zone_id" => ""
               },
               %{
                 "municipality" => "Boston",
                 "stop_desc" => stop3.stop_desc,
                 "stop_id" => stop3.stop_id,
                 "stop_lat" => to_string(stop3.stop_lat),
                 "stop_lon" => to_string(stop3.stop_lon),
                 "stop_name" => stop3.stop_name,
                 "at_street" => "",
                 "level_id" => "",
                 "location_type" => "",
                 "on_street" => "",
                 "parent_station" => "",
                 "platform_code" => "",
                 "platform_name" => "",
                 "stop_address" => "",
                 "stop_code" => "",
                 "stop_url" => "",
                 "vehicle_type" => "",
                 "wheelchair_boarding" => "",
                 "zone_id" => ""
               }
             ] == data
    end
  end
end
