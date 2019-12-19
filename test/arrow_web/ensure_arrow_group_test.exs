defmodule ArrowWeb.EnsureArrowGroupTest do
  use ArrowWeb.ConnCase

  describe "init/1" do
    test "passes options through unchanged" do
      assert ArrowWeb.EnsureArrowGroup.init([]) == []
    end
  end

  describe "call/2" do
    @tag :authenticated
    test "does nothing when user is in the arrow-admin group", %{conn: conn} do
      assert conn == ArrowWeb.EnsureArrowGroup.call(conn, [])
    end

    @tag :authenticated_not_in_group
    test "redirects when user is not in the arrow-admin group", %{conn: conn} do
      conn = ArrowWeb.EnsureArrowGroup.call(conn, [])

      response = html_response(conn, 302)
      assert response =~ "/unauthorized"
    end
  end
end
