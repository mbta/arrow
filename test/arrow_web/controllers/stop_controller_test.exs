defmodule ArrowWeb.StopControllerTest do
  use ArrowWeb.ConnCase, async: true

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

  describe "index" do
    @tag :authenticated
    test "lists all stops", %{conn: conn} do
      conn = get(conn, ~p"/stops")
      assert html_response(conn, 200) =~ "Listing Stops"
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
      invalid_attrs = Enum.reject(@create_attrs, fn {k, _v} -> k == :stop_id end)
      conn = post(conn, ~p"/stops", stop: invalid_attrs)
      assert redirected_to(conn) == ~p"/stops/new"

      assert get_flash(conn, :errors) ==
               {"Error creating stop, please try again", ["Stop id can\'t be blank"]}
    end
  end
end
