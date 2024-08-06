defmodule ArrowWeb.StopControllerTest do
  use ArrowWeb.ConnCase, async: true

  describe "index" do
    @tag :authenticated
    test "lists all stops", %{conn: conn} do
      conn = get(conn, ~p"/stops")
      assert html_response(conn, 200) =~ "Listing Stops"
    end
  end
end
