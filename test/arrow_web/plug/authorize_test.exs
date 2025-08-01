defmodule ArrowWeb.Plug.AuthorizeTest do
  use ArrowWeb.ConnCase

  alias ArrowWeb.Plug.AssignUser
  alias ArrowWeb.Plug.Authorize

  describe "init/1" do
    test "passes options through unchanged" do
      assert Authorize.init([]) == []
    end
  end

  describe "call/2" do
    @tag :authenticated
    test "prevents a non-admin from creating a disruption", %{conn: conn} do
      assert conn
             |> AssignUser.call([])
             |> Authorize.call(:create_disruption)
             |> redirected_to() == "/unauthorized"
    end

    @tag :authenticated_admin
    test "allows an admin to create a disruption", %{conn: conn} do
      conn = AssignUser.call(conn, [])
      assert Authorize.call(conn, :create_disruption) == conn
    end
  end
end
