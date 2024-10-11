defmodule ArrowWeb.ShuttleControllerTest do
  use ArrowWeb.ConnCase
  alias Arrow.Shuttles.Shuttle

  describe "index" do
    @tag :authenticated
    test "lists all shuttles", %{conn: conn} do
      conn = get(conn, ~p"/shuttles")
      assert html_response(conn, 200) =~ "Listing Shuttles"
    end
  end

  describe "new shuttle" do
    @tag :authenticated
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/shuttles/new")
      assert html_response(conn, 200) =~ "New Shuttle"
    end
  end

  describe "edit shuttle" do
    setup [:create_shuttle]

    @tag :authenticated
    test "renders successfully", %{conn: conn, shuttle: shuttle} do
      conn = get(conn, ~p"/shuttles/#{shuttle}/edit")
      assert html_response(conn, 200) =~ "Edit Shuttle"
    end
  end

  defp create_shuttle(_) do
    %{shuttle: %Shuttle{id: 1, shuttle_name: "test", status: :draft}}
  end
end
