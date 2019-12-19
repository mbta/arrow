defmodule ArrowWeb.UnauthorizedControllerTest do
  use ArrowWeb.ConnCase
  import ArrowWeb.Router.Helpers

  describe "index/2" do
    test "renders response", %{conn: conn} do
      conn = get(conn, unauthorized_path(conn, :index))

      assert html_response(conn, 403) =~ "not authorized"
    end
  end
end
