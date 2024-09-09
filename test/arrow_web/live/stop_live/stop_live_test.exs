defmodule ArrowWeb.StopLiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.StopsFixtures

  @create_attrs %{
    stop_id: "some stop_id",
    stop_name: "some stop_name",
    stop_desc: "some stop_desc",
    platform_code: "some platform_code",
    platform_name: "some platform_name",
    stop_lat: 120.5,
    stop_lon: 120.5,
    stop_address: "some stop_address",
    zone_id: "some zone_id",
    level_id: "some level_id",
    parent_station: "some parent_station",
    municipality: "some municipality",
    on_street: "some on_street",
    at_street: "some at_street"
  }
  @update_attrs %{
    stop_id: "some updated stop_id",
    stop_name: "some updated stop_name",
    stop_desc: "some updated stop_desc",
    platform_code: "some updated platform_code",
    platform_name: "some updated platform_name",
    stop_lat: 456.7,
    stop_lon: 456.7,
    stop_address: "some updated stop_address",
    zone_id: "some updated zone_id",
    level_id: "some updated level_id",
    parent_station: "some updated parent_station",
    municipality: "some updated municipality",
    on_street: "some updated on_street",
    at_street: "some updated at_street"
  }
  @invalid_attrs %{
    stop_id: nil,
    stop_name: nil,
    stop_desc: nil,
    platform_code: nil,
    platform_name: nil,
    stop_lat: nil,
    stop_lon: nil,
    stop_address: nil,
    zone_id: nil,
    level_id: nil,
    parent_station: nil,
    municipality: nil,
    on_street: nil,
    at_street: nil
  }

  describe "new stop" do
    @tag :authenticated_admin
    test "renders form", %{conn: conn} do
      {:ok, _new_live, html} = live(conn, ~p"/stops/new")
      assert html =~ "create shuttle stop"
      assert html =~ "Components.StopViewMap"
    end
  end

  describe "create stop" do
    @tag :authenticated_admin
    test "redirects to index when data is valid", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/stops/new")

      form =
        new_live
        |> form("#stop-form", stop: @create_attrs)

      assert render_submit(form) =~ ~r/phx-trigger-action/

      conn = follow_trigger_action(form, conn)
      assert conn.method == "POST"
      params = Enum.map(@create_attrs, fn {k, v} -> {"#{k}", v} end) |> Enum.into(%{})
      assert conn.params == %{"stop" => params}
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, new_live, _html} = live(conn, ~p"/stops/new")

      form =
        new_live
        |> form("#stop-form", stop: @invalid_attrs)

      refute render_submit(form) =~ ~r/phx-trigger-action/

      html = render(new_live)
      assert html =~ "create shuttle stop"
      refute html =~ "phx-trigger-action"
      assert html =~ "can&#39;t be blank"
    end
  end

  describe "edit stop" do
    setup [:create_stop]
    @tag :authenticated_admin
    test "renders form for editing chosen stop", %{conn: conn, stop: stop} do
      {:ok, _edit_live, html} = live(conn, ~p"/stops/#{stop}/edit")
      assert html =~ "edit shuttle stop"
      assert html =~ "Components.StopViewMap"
    end
  end

  describe "update stop" do
    setup [:create_stop]

    @tag :authenticated_admin
    test "redirects when data is valid", %{conn: conn, stop: stop} do
      {:ok, edit_live, _html} = live(conn, ~p"/stops/#{stop}/edit")

      assert edit_live
             |> form("#stop-form", stop: @update_attrs)
             |> render_submit()

      assert_redirect(edit_live, ~p"/stops/")
    end

    @tag :authenticated_admin
    test "renders errors when data is invalid", %{conn: conn, stop: stop} do
      {:ok, edit_live, _html} = live(conn, ~p"/stops/#{stop}/edit")

      assert edit_live
             |> form("#stop-form", stop: @invalid_attrs)
             |> render_submit()

      html = render(edit_live)
      assert html =~ "edit shuttle stop"
      assert html =~ "can&#39;t be blank"
    end
  end

  defp create_stop(_) do
    stop = stop_fixture()
    %{stop: stop}
  end
end
