defmodule ArrowWeb.API.ShuttleControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.ShuttlesFixtures


  defp create_shuttles(_) do
    active_shuttle = shuttle_fixture(status: :active)
    inactive_shuttle = shuttle_fixture(status: :active)
    %{active_shuttle: active_shuttle, inactive_shuttle: inactive_shuttle}
  end

  describe "index/2" do
    setup [:create_shuttles]
    @tag :authenticated

    test "non-admin user can access the shuttle API", %{conn: conn} do
      assert %{status: 200} = get(conn, "/api/shuttle")
    end
    
    test "shuttle API only shows active shuttles", %{conn: conn} do
      shuttles = get(conn, "/api/shuttle")
      dbg()

    end
  end
end
