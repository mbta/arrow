defmodule ArrowWeb.MyTokenControllerTest do
  use ArrowWeb.ConnCase

  @tag :authenticated
  test "GET /mytoken", %{conn: conn} do
    conn = get(conn, Routes.my_token_path(conn, :show))
    assert html_response(conn, 200) =~ "Your token is"
  end
end
