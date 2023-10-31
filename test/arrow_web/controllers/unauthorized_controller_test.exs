defmodule ArrowWeb.UnauthorizedControllerTest do
  use ArrowWeb.ConnCase

  describe "index/2" do
    @tag :authenticated
    test "renders response", %{conn: conn} do
      conn = get(conn, Routes.unauthorized_path(conn, :index))
      response = html_response(conn, 403)
      assert response =~ "not authorized"
      assert response =~ "calendar schedule"
    end

    @tag :authenticated_empty
    test "does not offer a calendar if the user has no roles", %{conn: conn} do
      conn = get(conn, Routes.unauthorized_path(conn, :index))
      response = html_response(conn, 403)
      assert response =~ "not authorized"
      refute response =~ "calendar schedule"
    end
  end
end
