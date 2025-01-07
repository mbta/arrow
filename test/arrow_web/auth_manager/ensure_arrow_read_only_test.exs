defmodule ArrowWeb.EnsureArrowReadOnlyTest do
  use ArrowWeb.ConnCase

  describe "init/1" do
    test "passes options through unchanged" do
      assert ArrowWeb.EnsureArrowReadOnly.init([]) == []
    end
  end

  describe "call/2" do
    setup %{conn: conn} do
      %{conn: ArrowWeb.Plug.AssignUser.call(conn)}
    end

    @tag :authenticated_admin
    test "does nothing when user is an admin", %{conn: conn} do
      assert conn == ArrowWeb.EnsureArrowReadOnly.call(conn, [])
    end

    @tag :authenticated
    test "does nothing when user has read-only access", %{conn: conn} do
      assert conn == ArrowWeb.EnsureArrowReadOnly.call(conn, [])
    end

    @tag :authenticated_empty
    test "redirects to /unauthorized when user is not an admin", %{conn: conn} do
      conn = ArrowWeb.EnsureArrowReadOnly.call(conn, [])

      assert redirected_to(conn) =~ "/unauthorized"
    end
  end
end
