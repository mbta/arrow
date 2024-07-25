defmodule ArrowWeb.StopControllerTest do
  use ArrowWeb.ConnCase, async: true

  import Arrow.StopsFixtures

  @create_attrs %{
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
  @update_attrs %{
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

  describe "index" do
    @tag :authenticated
    test "lists all stops", %{conn: conn} do
      conn = get(conn, ~p"/stops")
      assert html_response(conn, 200) =~ "Listing Stops"
    end
  end

  describe "new stop" do
    @tag :authenticated_admin
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/stops/new")
      assert html_response(conn, 200) =~ "create shuttle stop"
    end
  end

  describe "create stop" do
    @tag :authenticated_admin
    test "redirects to index when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/stops", stop: @create_attrs)

      assert redirected_to(conn) == ~p"/stops"
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/stops", stop: @invalid_attrs)
      assert html_response(conn, 200) =~ "create shuttle stop"
    end
  end

  describe "edit stop" do
    setup [:create_stop]
    @tag :authenticated_admin
    test "renders form for editing chosen stop", %{conn: conn, stop: stop} do
      conn = get(conn, ~p"/stops/#{stop}/edit")
      assert html_response(conn, 200) =~ "edit shuttle stop"
    end
  end

  describe "update stop" do
    setup [:create_stop]

    @tag :authenticated_admin
    test "redirects when data is valid", %{conn: conn, stop: stop} do
      conn = put(conn, ~p"/stops/#{stop}", stop: @update_attrs)
      assert redirected_to(conn) == ~p"/stops"
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn, stop: stop} do
      conn = put(conn, ~p"/stops/#{stop}", stop: @invalid_attrs)
      assert html_response(conn, 200) =~ "edit shuttle stop"
    end
  end

  defp create_stop(_) do
    stop = stop_fixture()
    %{stop: stop}
  end
end
