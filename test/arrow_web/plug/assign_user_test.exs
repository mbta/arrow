defmodule ArrowWeb.Plug.AssignUserTest do
  use ArrowWeb.ConnCase
  alias Arrow.Accounts.User
  alias ArrowWeb.Plug.AssignUser

  describe "init/1" do
    test "passes options through unchanged" do
      assert AssignUser.init([]) == []
    end
  end

  describe "call/2" do
    @tag :authenticated_admin
    test "loads an admin user into the connection", %{conn: conn} do
      assert AssignUser.call(conn, []).assigns == %{
               current_user: %User{id: "test_user", groups: MapSet.new([:admin])}
             }
    end

    @tag :authenticated
    test "loads a non-admin into the connection when user has no groups", %{conn: conn} do
      assert AssignUser.call(conn, []).assigns == %{
               current_user: %User{id: "test_user", groups: MapSet.new()}
             }
    end
  end
end
