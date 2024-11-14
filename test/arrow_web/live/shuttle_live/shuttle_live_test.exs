defmodule ArrowWeb.ShuttleLiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.Factory
  import Arrow.ShuttlesFixtures

  @create_attrs %{
    disrupted_route_id: "",
    routes: %{
      "0" => %{
        :_persistent_id => "0",
        destination: "Broadway",
        direction_desc: "Southbound",
        direction_id: "0",
        shape_id: "",
        suffix: "",
        waypoint: ""
      },
      "1" => %{
        :_persistent_id => "1",
        destination: "Harvard",
        direction_desc: "Northbound",
        direction_id: "1",
        shape_id: "",
        suffix: "",
        waypoint: ""
      }
    },
    shuttle_name: "Blah",
    status: "draft"
  }

  @update_attrs %{
    disrupted_route_id: "",
    routes: %{
      "0" => %{
        :_persistent_id => "0",
        destination: "Broadway",
        direction_desc: "Southbound",
        direction_id: "0",
        shape_id: "",
        suffix: "",
        waypoint: ""
      },
      "1" => %{
        :_persistent_id => "1",
        destination: "Harvard",
        direction_desc: "Northbound",
        direction_id: "1",
        shape_id: "",
        suffix: "",
        waypoint: ""
      }
    },
    shuttle_name: "Meh",
    status: "draft"
  }

  @invalid_attrs %{
    disrupted_route_id: "",
    shuttle_name: nil,
    status: "draft"
  }

  describe "new shuttle" do
    @tag :authenticated_admin
    test "renders form", %{conn: conn} do
      {:ok, _new_live, html} = live(conn, ~p"/shuttles/new")
      assert html =~ "create new replacement service shuttle"
    end
  end

  describe "create shuttle" do
    @tag :authenticated_admin
    test "redirects to new shuttle when data is valid", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      {:ok, conn} =
        new_live
        |> form("#shuttle-form", shuttle: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle created successfully/i

      assert %{"id" => _id} = conn.params
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/new")

      assert new_live |> form("#shuttle-form", shuttle: @invalid_attrs) |> render_submit() =~
               "can&#39;t be blank"
    end
  end

  describe "edit shuttle" do
    setup [:create_shuttle]

    @tag :authenticated_admin
    test "redirects to updated shuttle when data is valid", %{conn: conn, shuttle: shuttle} do
      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      {:ok, conn} =
        edit_live
        |> form("#shuttle-form", shuttle: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle updated successfully/i
    end

    @tag :authenticated_admin
    test "can edit a stop ID", %{conn: conn, shuttle: shuttle} do
      direction_0_route = Enum.find(shuttle.routes, fn route -> route.direction_id == :"0" end)
      gtfs_stop = insert(:gtfs_stop)
      new_gtfs_stop = insert(:gtfs_stop)

      direction_0_route
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => gtfs_stop.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      {:ok, conn} =
        edit_live
        |> form("#shuttle-form",
          shuttle: @update_attrs,
          routes_with_stops: %{
            "0" => %{route_stops: %{"0" => %{display_stop_id: new_gtfs_stop.id}}}
          }
        )
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle updated successfully/i
    end

    @tag :authenticated_admin
    test "can remove a stop", %{conn: conn, shuttle: shuttle} do
      direction_0_route = Enum.find(shuttle.routes, fn route -> route.direction_id == :"0" end)
      gtfs_stop = insert(:gtfs_stop)

      direction_0_route
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => gtfs_stop.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      edit_live
      |> element("#shuttle-form")
      |> render_change(%{
        routes_with_stops: %{"0" => %{"route_stops_drop" => ["0"]}}
      })

      {:ok, conn} =
        edit_live
        |> element("#shuttle-form")
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle updated successfully/i

      updated_shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      assert Enum.all?(updated_shuttle.routes, fn route -> route.route_stops == [] end)
    end

    @tag :authenticated_admin
    test "can add a stop", %{conn: conn, shuttle: shuttle} do
      gtfs_stop = insert(:gtfs_stop)
      stop_id = gtfs_stop.id

      {:ok, edit_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      edit_live
      |> element("#shuttle-form > button[value=\"0\"]")
      |> render_click()

      {:ok, conn} =
        edit_live
        |> form("#shuttle-form",
          shuttle: @update_attrs,
          routes_with_stops: %{
            "0" => %{route_stops: %{"0" => %{display_stop_id: stop_id}}}
          }
        )
        |> render_submit()
        |> follow_redirect(conn)

      assert html_response(conn, 200) =~ ~r/shuttle updated successfully/i

      updated_shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      direction_0_route =
        Enum.find(updated_shuttle.routes, fn route -> route.direction_id == :"0" end)

      assert [%{gtfs_stop_id: ^stop_id}] = direction_0_route.route_stops
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn, shuttle: shuttle} do
      {:ok, new_live, _html} = live(conn, ~p"/shuttles/#{shuttle}/edit")

      assert new_live |> form("#shuttle-form", shuttle: @invalid_attrs) |> render_submit() =~
               "can&#39;t be blank"
    end
  end

  defp create_shuttle(_) do
    shuttle = shuttle_fixture()
    %{shuttle: shuttle}
  end
end
