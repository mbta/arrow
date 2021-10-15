defmodule ArrowWeb.MyTokenControllerTest do
  use ArrowWeb.ConnCase

  @tag :authenticated_admin
  test "GET /mytoken", %{conn: conn} do
    conn = get(conn, Routes.my_token_path(conn, :show))
    assert html_response(conn, 200) =~ "Your token is"
  end

  @tag :authenticated
  test "non-admin user cannot get their API token", %{conn: conn} do
    assert conn
           |> get(Routes.my_token_path(conn, :show))
           |> redirected_to() == "/unauthorized"
  end
end
