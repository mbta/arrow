defmodule ArrowWeb.EditControllerTest do
  use ArrowWeb.ConnCase

  @tag :authenticated
  test "GET /edit", %{conn: conn} do
    conn = get(conn, "/edit")
    assert html_response(conn, 200)
  end

  @tag :authenticated
  test "GET /edit/:id", %{conn: conn} do
    conn = get(conn, "/edit/1")
    assert html_response(conn, 200)
  end
end
