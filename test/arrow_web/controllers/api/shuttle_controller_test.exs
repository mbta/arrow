defmodule ArrowWeb.API.ShuttleControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.ShuttlesFixtures
  import Arrow.Factory

  describe "index/2" do
    @tag :authenticated
    test "non-admin user can access the shuttle API", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/shuttles")
    end

    @tag :authenticated
    test "shuttle API only shows active shuttles", %{conn: conn} do
      shuttle_fixture(%{status: :inactive})
      shuttle_fixture()
      shuttle = shuttle_fixture()

      [route0, route1] = shuttle.routes
      route_map = %{route0.id => route0, route1.id => route1}

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)
      stop_map = %{stop1.id => stop1, stop2.id => stop2, stop3.id => stop3, stop4.id => stop4}

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ]
      })
      |> Arrow.Repo.update()

      route1
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop4.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      {:ok, active_shuttle} =
        shuttle.id
        |> Arrow.Shuttles.get_shuttle!()
        |> Arrow.Shuttles.Shuttle.changeset(%{status: :active})
        |> Arrow.Repo.update()

      res =
        conn
        |> get("/api/shuttles")
        |> json_response(200)

      route0_id = to_string(route0.id)
      route1_id = to_string(route1.id)

      assert %{
               "data" => [
                 %{
                   "id" => id,
                   "relationships" => %{
                     "routes" => %{
                       "data" => [
                         %{"id" => ^route0_id, "type" => "shuttle_route"},
                         %{"id" => ^route1_id, "type" => "shuttle_route"}
                       ]
                     }
                   }
                 }
               ],
               "jsonapi" => _,
               "included" => included
             } = res

      Enum.each(included, fn
        %{"type" => "shuttle_route", "attributes" => attributes, "id" => id} ->
          route = route_map[id |> String.to_integer()]
          assert to_string(route.destination) == attributes["destination"]
          assert to_string(route.direction_id) == attributes["direction_id"]
          assert route.shape.name == attributes["shape_id"]

        %{"type" => "gtfs_stop", "attributes" => attributes, "id" => id} ->
          stop = stop_map[id]
          assert stop.lat == attributes["lat"]
          assert stop.lon == attributes["lon"]
          assert to_string(stop.name) == attributes["name"]

        %{
          "type" => "shuttle_route_stop",
          "relationships" => %{
            "gtfs_stop" => %{"data" => %{"id" => gtfs_stop_id}}
          },
          "attributes" => %{"time_to_next_stop" => _}
        } ->
          assert Map.has_key?(stop_map, gtfs_stop_id)
      end)

      assert id == to_string(active_shuttle.id)
    end
  end

  describe "get/2" do
    @tag :authenticated
    test "get single shuttle", %{conn: conn} do
      shuttle = shuttle_fixture()
      shuttle_name = shuttle.shuttle_name
      status = to_string(shuttle.status)
      suffix = shuttle.suffix
      disrupted_route_id = shuttle.disrupted_route_id
      [route0, route1] = shuttle.routes

      [stop1, stop3] = insert_list(2, :gtfs_stop)
      [stop2, stop4] = insert_list(2, :stop)

      route0 =
        route0
        |> Arrow.Shuttles.Route.changeset(%{
          "route_stops" => [
            %{
              "direction_id" => "0",
              "stop_sequence" => "1",
              "gtfs_stop_id" => stop1.id,
              "time_to_next_stop" => 30.0
            },
            %{
              "direction_id" => "0",
              "stop_sequence" => "2",
              "stop_id" => stop2.id
            }
          ]
        })
        |> Arrow.Repo.update!()
        |> Arrow.Repo.preload(route_stops: :stop)

      route1 =
        route1
        |> Arrow.Shuttles.Route.changeset(%{
          "route_stops" => [
            %{
              "direction_id" => "1",
              "stop_sequence" => "1",
              "gtfs_stop_id" => stop3.id,
              "time_to_next_stop" => 30.0
            },
            %{
              "direction_id" => "1",
              "stop_sequence" => "2",
              "stop_id" => stop4.id
            }
          ]
        })
        |> Arrow.Repo.update!()
        |> Arrow.Repo.preload(route_stops: :stop)

      res = conn |> get("/api/shuttle/#{shuttle.id}") |> json_response(200)

      assert %{
               "shuttle_name" => ^shuttle_name,
               "status" => ^status,
               "suffix" => ^suffix,
               "disrupted_route_id" => ^disrupted_route_id,
               "routes" => [res_route0, res_route1]
             } = res

      for {route, res_route} <- [{route0, res_route0}, {route1, res_route1}] do
        destination = route.destination
        direction_id = to_string(route.direction_id)
        direction_desc = to_string(route.direction_desc)
        waypoint = route.waypoint
        shape_id = route.shape.name

        [rs1, rs2] = route.route_stops
        # TODO: should we be serializing this in json as a number?
        time_to_next_stop = to_string(rs1.time_to_next_stop)
        # we set the first stop in each route to be a GTFS stop and the second
        # to be an Arrow stop, we can just hard-code those values
        stop1 = rs1.gtfs_stop_id
        stop2 = rs2.stop.stop_id

        assert %{
                 "destination" => ^destination,
                 "direction_id" => ^direction_id,
                 "direction_desc" => ^direction_desc,
                 "waypoint" => ^waypoint,
                 "shape_id" => ^shape_id,
                 # Will always be disabled in test because we don't actually upload shape files
                 "shape_uri" => "disabled",
                 "route_stops" => [
                   %{
                     "direction_id" => ^direction_id,
                     "stop_sequence" => 1,
                     "time_to_next_stop" => ^time_to_next_stop,
                     "stop_id" => ^stop1
                   },
                   %{
                     "direction_id" => ^direction_id,
                     "stop_sequence" => 2,
                     "time_to_next_stop" => nil,
                     "stop_id" => ^stop2
                   }
                 ]
               } = res_route
      end
    end

    @tag :authenticated
    test "gives 404 for non-existing shuttle", %{conn: conn} do
      assert_error_sent 404, fn -> get(conn, "/api/shuttle/0") end
    end
  end
end
