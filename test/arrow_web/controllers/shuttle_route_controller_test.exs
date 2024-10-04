defmodule ArrowWeb.ShuttleRouteControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.ShuttlesFixtures

  @create_attrs %{
    suffix: "some suffix",
    destination: "some destination",
    direction_id: :"0",
    direction_desc: "some direction_desc",
    waypoint: "some waypoint"
  }
  @update_attrs %{
    suffix: "some updated suffix",
    destination: "some updated destination",
    direction_id: :"1",
    direction_desc: "some updated direction_desc",
    waypoint: "some updated waypoint"
  }
  @invalid_attrs %{
    suffix: nil,
    destination: nil,
    direction_id: nil,
    direction_desc: nil,
    waypoint: nil
  }

  describe "index" do
    test "lists all shuttle_routes", %{conn: conn} do
      conn = get(conn, ~p"/shuttle_routes")
      assert html_response(conn, 200) =~ "Listing Shuttle routes"
    end
  end

  describe "new shuttle_route" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/shuttle_routes/new")
      assert html_response(conn, 200) =~ "New Shuttle route"
    end
  end

  describe "create shuttle_route" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/shuttle_routes", shuttle_route: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/shuttle_routes/#{id}"

      conn = get(conn, ~p"/shuttle_routes/#{id}")
      assert html_response(conn, 200) =~ "Shuttle route #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/shuttle_routes", shuttle_route: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Shuttle route"
    end
  end

  describe "edit shuttle_route" do
    setup [:create_shuttle_route]

    test "renders form for editing chosen shuttle_route", %{
      conn: conn,
      shuttle_route: shuttle_route
    } do
      conn = get(conn, ~p"/shuttle_routes/#{shuttle_route}/edit")
      assert html_response(conn, 200) =~ "Edit Shuttle route"
    end
  end

  describe "update shuttle_route" do
    setup [:create_shuttle_route]

    test "redirects when data is valid", %{conn: conn, shuttle_route: shuttle_route} do
      conn = put(conn, ~p"/shuttle_routes/#{shuttle_route}", shuttle_route: @update_attrs)
      assert redirected_to(conn) == ~p"/shuttle_routes/#{shuttle_route}"

      conn = get(conn, ~p"/shuttle_routes/#{shuttle_route}")
      assert html_response(conn, 200) =~ "some updated suffix"
    end

    test "renders errors when data is invalid", %{conn: conn, shuttle_route: shuttle_route} do
      conn = put(conn, ~p"/shuttle_routes/#{shuttle_route}", shuttle_route: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Shuttle route"
    end
  end

  describe "delete shuttle_route" do
    setup [:create_shuttle_route]

    test "deletes chosen shuttle_route", %{conn: conn, shuttle_route: shuttle_route} do
      conn = delete(conn, ~p"/shuttle_routes/#{shuttle_route}")
      assert redirected_to(conn) == ~p"/shuttle_routes"

      assert_error_sent 404, fn ->
        get(conn, ~p"/shuttle_routes/#{shuttle_route}")
      end
    end
  end

  defp create_shuttle_route(_) do
    shuttle_route = shuttle_route_fixture()
    %{shuttle_route: shuttle_route}
  end
end
