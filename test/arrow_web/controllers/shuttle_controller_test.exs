defmodule ArrowWeb.ShuttleControllerTest do
  use ArrowWeb.ConnCase

  import Arrow.ShuttlesFixtures

  @create_attrs %{status: :draft, shuttle_name: "some shuttle_name"}
  @update_attrs %{status: :inactive, shuttle_name: "some updated shuttle_name"}
  @invalid_attrs %{status: nil, shuttle_name: nil}

  describe "index" do
    @tag :authenticated
    test "lists all shuttles", %{conn: conn} do
      conn = get(conn, ~p"/shuttles")
      assert html_response(conn, 200) =~ "shuttles"
    end
  end

  describe "new shuttle" do
    @tag :authenticated_admin
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/shuttles/new")
      assert html_response(conn, 200) =~ "new shuttle"
    end
  end

  describe "create shuttle" do
    @tag :authenticated_admin
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/shuttles", shuttle: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/shuttles/#{id}"
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/shuttles", shuttle: @invalid_attrs)
      assert html_response(conn, 200) =~ "new shuttle"
    end
  end

  describe "edit shuttle" do
    setup [:create_shuttle]

    @tag :authenticated_admin
    test "renders form for editing chosen shuttle", %{conn: conn, shuttle: shuttle} do
      conn = get(conn, ~p"/shuttles/#{shuttle}/edit")
      assert html_response(conn, 200) =~ "edit shuttle"
    end
  end

  describe "update shuttle" do
    setup [:create_shuttle]

    @tag :authenticated_admin
    test "redirects when data is valid", %{conn: conn, shuttle: shuttle} do
      redirected = put(conn, ~p"/shuttles/#{shuttle}", shuttle: @update_attrs)
      assert redirected_to(redirected) == ~p"/shuttles/#{shuttle}"

      conn = get(conn, ~p"/shuttles/#{shuttle}")
      assert html_response(conn, 200) =~ "some updated shuttle_name"
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn, shuttle: shuttle} do
      conn = put(conn, ~p"/shuttles/#{shuttle}", shuttle: @invalid_attrs)
      assert html_response(conn, 200) =~ "edit shuttle"
    end
  end

  defp create_shuttle(_) do
    shuttle = shuttle_fixture()
    %{shuttle: shuttle}
  end
end
