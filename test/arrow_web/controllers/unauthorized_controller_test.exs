defmodule ArrowWeb.UnauthorizedControllerTest do
  use ArrowWeb.ConnCase

  describe "index/2" do
    @tag :authenticated_not_in_group
    test "renders response", %{conn: conn} do
      conn = get(conn, Routes.unauthorized_path(conn, :index))

      assert html_response(conn, 403) =~ "not authorized"
    end
  end
end
