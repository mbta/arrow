defmodule ArrowWeb.ShuttleControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.ShuttlesFixtures

  describe "index" do
    @tag :authenticated
    test "lists all shuttles", %{conn: conn} do
      conn = get(conn, ~p"/shuttles")
      assert html_response(conn, 200) =~ "shuttles"
    end
  end

  describe "show" do
    setup [:create_shuttle]

    @tag :authenticated
    test "shows a shuttle", %{conn: conn, shuttle: shuttle} do
      conn = get(conn, ~p"/shuttles/#{shuttle}")
      assert html_response(conn, 200) =~ "shuttle"
    end
  end

  defp create_shuttle(_) do
    shuttle = shuttle_fixture()
    %{shuttle: shuttle}
  end
end
