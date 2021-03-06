defmodule ArrowWeb.PageControllerTest do
  use ArrowWeb.ConnCase

  @tag :authenticated
  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200)
  end

  @tag :authenticated
  test "GET /disruptions/new", %{conn: conn} do
    conn = get(conn, "/disruptions/new")
    assert html_response(conn, 200)
  end

  @tag :authenticated
  test "GET /disruptions/id", %{conn: conn} do
    conn = get(conn, "/disruptions/id")
    assert html_response(conn, 200)
  end

  @tag :authenticated
  test "GET /disruptions/id/edit", %{conn: conn} do
    conn = get(conn, "/disruptions/id/edit")
    assert html_response(conn, 200)
  end

  @tag :authenticated
  test "GET / with HTTP redirects to HTTPS", %{conn: conn} do
    conn = conn |> Plug.Conn.put_req_header("x-forwarded-proto", "http") |> get("/")

    location_header = Enum.find(conn.resp_headers, fn {key, _value} -> key == "location" end)
    {"location", url} = location_header
    assert url =~ "https"

    assert response(conn, 301)
  end
end
