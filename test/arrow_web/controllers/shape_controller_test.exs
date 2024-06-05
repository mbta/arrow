defmodule ArrowWeb.ShapeControllerTest do
  use ArrowWeb.ConnCase, async: true

  import Arrow.ShuttleFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    @tag :authenticated_admin
    test "lists all shapes", %{conn: conn} do
      conn = get(conn, ~p"/shapes")
      assert html_response(conn, 200) =~ "Listing Shapes"
    end
  end

  describe "new shape" do
    @tag :authenticated_admin
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/shapes/new")
      assert html_response(conn, 200) =~ "New Shape"
    end
  end

  describe "create shape" do
    @tag :authenticated_admin
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/shapes", shape: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/shapes/#{id}"

      conn = ArrowWeb.ConnCase.authenticated_admin()
      conn = get(conn, ~p"/shapes/#{id}")
      assert html_response(conn, 200) =~ "Shape #{id}"
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/shapes", shape: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Shape"
    end
  end

  describe "edit shape" do
    setup [:create_shape]

    @tag :authenticated_admin
    test "renders form for editing chosen shape", %{conn: conn, shape: shape} do
      conn = get(conn, ~p"/shapes/#{shape}/edit")
      assert html_response(conn, 200) =~ "Edit Shape"
    end
  end

  describe "update shape" do
    setup [:create_shape]

    @tag :authenticated_admin
    test "redirects when data is valid", %{conn: conn, shape: shape} do
      conn = put(conn, ~p"/shapes/#{shape}", shape: @update_attrs)
      assert redirected_to(conn) == ~p"/shapes/#{shape}"

      conn = ArrowWeb.ConnCase.authenticated_admin()
      conn = get(conn, ~p"/shapes/#{shape}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn, shape: shape} do
      conn = put(conn, ~p"/shapes/#{shape}", shape: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Shape"
    end
  end

  describe "delete shape" do
    setup [:create_shape]

    @tag :authenticated_admin
    test "deletes chosen shape", %{conn: conn, shape: shape} do
      conn = delete(conn, ~p"/shapes/#{shape}")
      assert redirected_to(conn) == ~p"/shapes"

      conn = ArrowWeb.ConnCase.authenticated_admin()

      assert_error_sent 404, fn ->
        get(conn, ~p"/shapes/#{shape}")
      end
    end
  end

  defp create_shape(_) do
    shape = shape_fixture()
    %{shape: shape}
  end
end
