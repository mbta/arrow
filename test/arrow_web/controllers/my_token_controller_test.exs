defmodule ArrowWeb.MyTokenControllerTest do
  use ArrowWeb.ConnCase

  @tag :authenticated_admin
  test "GET /mytoken", %{conn: conn} do
    conn = get(conn, Routes.my_token_path(conn, :show))
    assert html_response(conn, 200) =~ "Your token is"
  end

  @tag :authenticated
  test "non-admin user can get their API token", %{conn: conn} do
    conn = get(conn, Routes.my_token_path(conn, :show))
    assert html_response(conn, 200) =~ "Your token is"
  end
end
