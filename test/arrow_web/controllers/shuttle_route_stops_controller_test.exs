defmodule ArrowWeb.ShuttleRouteStopsControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.ShuttlesFixtures

  @create_attrs %{
    direction_id: :"0",
    stop_id: "some stop_id",
    stop_sequence: 42,
    time_to_next_stop: "120.5"
  }
  @update_attrs %{
    direction_id: :"1",
    stop_id: "some updated stop_id",
    stop_sequence: 43,
    time_to_next_stop: "456.7"
  }
  @invalid_attrs %{direction_id: nil, stop_id: nil, stop_sequence: nil, time_to_next_stop: nil}

  describe "index" do
    test "lists all shuttle_route_stops", %{conn: conn} do
      conn = get(conn, ~p"/shuttle_route_stops")
      assert html_response(conn, 200) =~ "Listing Shuttle route stops"
    end
  end

  describe "new shuttle_route_stops" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/shuttle_route_stops/new")
      assert html_response(conn, 200) =~ "New Shuttle route stops"
    end
  end

  describe "create shuttle_route_stops" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/shuttle_route_stops", shuttle_route_stops: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/shuttle_route_stops/#{id}"

      conn = get(conn, ~p"/shuttle_route_stops/#{id}")
      assert html_response(conn, 200) =~ "Shuttle route stops #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/shuttle_route_stops", shuttle_route_stops: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Shuttle route stops"
    end
  end

  describe "edit shuttle_route_stops" do
    setup [:create_shuttle_route_stops]

    test "renders form for editing chosen shuttle_route_stops", %{
      conn: conn,
      shuttle_route_stops: shuttle_route_stops
    } do
      conn = get(conn, ~p"/shuttle_route_stops/#{shuttle_route_stops}/edit")
      assert html_response(conn, 200) =~ "Edit Shuttle route stops"
    end
  end

  describe "update shuttle_route_stops" do
    setup [:create_shuttle_route_stops]

    test "redirects when data is valid", %{conn: conn, shuttle_route_stops: shuttle_route_stops} do
      conn =
        put(conn, ~p"/shuttle_route_stops/#{shuttle_route_stops}",
          shuttle_route_stops: @update_attrs
        )

      assert redirected_to(conn) == ~p"/shuttle_route_stops/#{shuttle_route_stops}"

      conn = get(conn, ~p"/shuttle_route_stops/#{shuttle_route_stops}")
      assert html_response(conn, 200) =~ "some updated stop_id"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      shuttle_route_stops: shuttle_route_stops
    } do
      conn =
        put(conn, ~p"/shuttle_route_stops/#{shuttle_route_stops}",
          shuttle_route_stops: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Shuttle route stops"
    end
  end

  describe "delete shuttle_route_stops" do
    setup [:create_shuttle_route_stops]

    test "deletes chosen shuttle_route_stops", %{
      conn: conn,
      shuttle_route_stops: shuttle_route_stops
    } do
      conn = delete(conn, ~p"/shuttle_route_stops/#{shuttle_route_stops}")
      assert redirected_to(conn) == ~p"/shuttle_route_stops"

      assert_error_sent 404, fn ->
        get(conn, ~p"/shuttle_route_stops/#{shuttle_route_stops}")
      end
    end
  end

  defp create_shuttle_route_stops(_) do
    shuttle_route_stops = shuttle_route_stops_fixture()
    %{shuttle_route_stops: shuttle_route_stops}
  end
end
