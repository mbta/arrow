defmodule ArrowWeb.StopControllerTest do
  use ArrowWeb.ConnCase, async: true

  describe "index/2" do
    @tag :authenticated
    test "renders successfully", %{conn: conn} do
      response =
        conn
        |> get(Routes.stop_path(conn, :index))
        |> html_response(200)

      assert response =~ "stop_html/index.html.heex"
    end
  end

  describe "new/2" do
    @tag :authenticated_admin
    test "renders successfully", %{conn: conn} do
      response =
        conn
        |> get(Routes.stop_path(conn, :new))
        |> html_response(200)

      assert response =~ "stop_html/new.html.heex"
      assert response =~ "stop_html/_form.html.heex"
    end
  end

  describe "edit/2" do
    @tag :authenticated_admin
    test "renders successfully", %{conn: conn} do
      response =
        conn
        |> get(Routes.stop_path(conn, :edit, 1))
        |> html_response(200)

      assert response =~ "stop_html/edit.html.heex"
      assert response =~ "stop_html/_form.html.heex"
    end
  end
end
