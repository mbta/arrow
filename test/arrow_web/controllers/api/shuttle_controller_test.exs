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

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id
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
            "display_stop_id" => stop3.id
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop4.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      {:ok, active_shuttle} =
        Arrow.Shuttles.Shuttle.changeset(shuttle, %{status: :active})
        |> Arrow.Repo.update()

      res =
        get(conn, "/api/shuttles")
        |> json_response(200)

      assert %{
               "data" => [
                 %{
                   "id" => id,
                   "relationships" => %{
                     "routes" => %{
                       "data" => _
                     }
                   }
                 }
               ],
               "jsonapi" => _,
               "included" => _
             } = res

      assert id == to_string(active_shuttle.id)
    end
  end
end
