defmodule ArrowWeb.API.StopsControllerTest do
  use ArrowWeb.ConnCase
  import Arrow.Factory

  describe "index/2" do
    @tag :authenticated
    test "non-admin user can access the stops API", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/shuttle-stops")
    end

    @tag :authenticated_admin
    test "returns 200", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/shuttle-stops")
    end

    @tag :authenticated_admin
    test "includes all stops", %{conn: conn} do
      stop1 = insert(:stop)
      stop2 = insert(:stop)
      stop3 = insert(:stop)

      res = json_response(get(conn, "/api/shuttle-stops"), 200)

      assert %{
               "data" => data,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      assert Enum.count(data) == 3

      assert [
               %{
                 "attributes" => %{
                   "inserted_at" => DateTime.to_iso8601(stop1.inserted_at),
                   "municipality" => "Boston",
                   "stop_desc" => stop1.stop_desc,
                   "stop_id" => stop1.stop_id,
                   "stop_lat" => 72.0,
                   "stop_lon" => 43.0,
                   "stop_name" => stop1.stop_name,
                   "updated_at" => DateTime.to_iso8601(stop1.updated_at)
                 },
                 "id" => stop1.stop_id,
                 "type" => "stops"
               },
               %{
                 "attributes" => %{
                   "inserted_at" => DateTime.to_iso8601(stop2.inserted_at),
                   "municipality" => "Boston",
                   "stop_desc" => stop2.stop_desc,
                   "stop_id" => stop2.stop_id,
                   "stop_lat" => 72.0,
                   "stop_lon" => 43.0,
                   "stop_name" => stop2.stop_name,
                   "updated_at" => DateTime.to_iso8601(stop2.updated_at)
                 },
                 "id" => stop2.stop_id,
                 "type" => "stops"
               },
               %{
                 "attributes" => %{
                   "inserted_at" => DateTime.to_iso8601(stop3.inserted_at),
                   "municipality" => "Boston",
                   "stop_desc" => stop3.stop_desc,
                   "stop_id" => stop3.stop_id,
                   "stop_lat" => 72.0,
                   "stop_lon" => 43.0,
                   "stop_name" => stop3.stop_name,
                   "updated_at" => DateTime.to_iso8601(stop3.updated_at)
                 },
                 "id" => stop3.stop_id,
                 "type" => "stops"
               }
             ] == data
    end

    @tag :authenticated_admin
    test "removes nil fields entirely", %{conn: conn} do
      stop1 = insert(:stop, %{on_street: "On Street", at_street: "At Avenue"})
      stop2 = insert(:stop, %{at_street: "At Avenue"})
      stop3 = insert(:stop, %{on_street: "On Street"})

      res = json_response(get(conn, "/api/shuttle-stops"), 200)

      assert %{
               "data" => data,
               "jsonapi" => %{"version" => "1.0"}
             } = res

      assert Enum.count(data) == 3

      assert [
               %{
                 "attributes" => %{
                   "inserted_at" => DateTime.to_iso8601(stop1.inserted_at),
                   "municipality" => "Boston",
                   "stop_desc" => stop1.stop_desc,
                   "stop_id" => stop1.stop_id,
                   "stop_lat" => 72.0,
                   "stop_lon" => 43.0,
                   "stop_name" => stop1.stop_name,
                   "updated_at" => DateTime.to_iso8601(stop1.updated_at),
                   "at_street" => "At Avenue",
                   "on_street" => "On Street"
                 },
                 "id" => stop1.stop_id,
                 "type" => "stops"
               },
               %{
                 "attributes" => %{
                   "inserted_at" => DateTime.to_iso8601(stop2.inserted_at),
                   "municipality" => "Boston",
                   "stop_desc" => stop2.stop_desc,
                   "stop_id" => stop2.stop_id,
                   "stop_lat" => 72.0,
                   "stop_lon" => 43.0,
                   "stop_name" => stop2.stop_name,
                   "updated_at" => DateTime.to_iso8601(stop2.updated_at),
                   "at_street" => "At Avenue"
                 },
                 "id" => stop2.stop_id,
                 "type" => "stops"
               },
               %{
                 "attributes" => %{
                   "inserted_at" => DateTime.to_iso8601(stop3.inserted_at),
                   "municipality" => "Boston",
                   "stop_desc" => stop3.stop_desc,
                   "stop_id" => stop3.stop_id,
                   "stop_lat" => 72.0,
                   "stop_lon" => 43.0,
                   "stop_name" => stop3.stop_name,
                   "updated_at" => DateTime.to_iso8601(stop3.updated_at),
                   "on_street" => "On Street"
                 },
                 "id" => stop3.stop_id,
                 "type" => "stops"
               }
             ] == data
    end
  end
end
