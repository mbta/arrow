defmodule ArrowWeb.ShuttleControllerTest do
  use ArrowWeb.ConnCase

  describe "index" do
    @tag :authenticated
    test "lists all shuttles", %{conn: conn} do
      conn = get(conn, ~p"/shuttles")
      assert html_response(conn, 200) =~ "shuttles"
    end
  end
end
