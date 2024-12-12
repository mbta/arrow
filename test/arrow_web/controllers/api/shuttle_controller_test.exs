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
      stop_map = %{stop1.id => stop1, stop2.id => stop2, stop3.id => stop3}

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
        shuttle.id
        |> Arrow.Shuttles.get_shuttle!()

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
                       "data" => route_data
                     }
                   }
                 }
               ],
               "jsonapi" => _,
               "included" => included
             } = res

      route0_id = route0.id
      route1_id = route1.id

      assert [
               %{"id" => route0_id, "type" => "shuttle_route"},
               %{"id" => route1_id, "type" => "shuttle_route"}
             ] = route_data

      included
      |> Enum.each(fn datum ->
        case datum do
          %{"type" => "shuttle_route", "attributes" => attributes, "id" => id} ->
            assert match?(attributes, route_map[id |> String.to_integer()])

          %{"type" => "gtfs_stop", "attributes" => attributes, "id" => id} ->
            assert match?(attributes, stop_map[id])
        end
      end)

      assert id == to_string(active_shuttle.id)
    end
  end
end
