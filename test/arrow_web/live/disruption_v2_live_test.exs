defmodule ArrowWeb.DisruptionV2LiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.DisruptionsFixtures
  import Arrow.ShuttlesFixtures

  @create_attrs %{
    title: "the great molasses disruption of 2025",
    mode: "commuter_rail",
    is_active: true,
    description: nil
  }
  @update_attrs %{
    title: "the second great molasses disruption",
    mode: "subway",
    is_active: false,
    description: "there is more"
  }
  @invalid_attrs %{
    title: nil,
    mode: "silver_line",
    is_active: true,
    description: "foobar"
  }

  defp create_disruption_v2(_) do
    disruption_v2 = disruption_v2_fixture()
    %{disruption_v2: disruption_v2}
  end

  describe "Changing Disruptions" do
    @tag :authenticated_admin
    test "saves new disruption_v2", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/disruptionsv2/new")

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @create_attrs)
             |> render_submit()

      html = render(index_live)
      assert html =~ "Disruption saved successfully"
    end

    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "updates disruption_v2", %{conn: conn, disruption_v2: disruption_v2} do
      {:ok, index_live, _html} = live(conn, ~p"/disruptionsv2/#{disruption_v2.id}/edit")

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @update_attrs)
             |> render_submit()

      html = render(index_live)
      assert html =~ "Disruption saved successfully"
    end
  end

  describe "Replacement Service" do
    @tag :authenticated_admin
    setup [:create_disruption_v2]

    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "can activate add replacement service flow", %{conn: conn, disruption_v2: disruption_v2} do
      {:ok, live, _html} = live(conn, ~p"/disruptionsv2/#{disruption_v2.id}/edit")

      assert live |> element("button#add_new_replacement_service_button") |> render_click() =~
               "add new replacement service component"

      shuttle = shuttle_fixture()

      live_component_selector = ~s{[id="shuttle[routes][0]_shape_id_live_select_component"]}

      stop_map_container =
        live
        |> form("#disruption_v2-form")
        |> render_change(%{"disruption_v2[new_shuttle_id]" => shuttle.id})
        |> Floki.find("#shuttle-view-map-disruptionsv2-container")

      # make sure the shuttle map container is displayed when we have entered a new shuttle
      assert !Enum.empty?(stop_map_container)
    end

    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "can deactivate add replacement service flow", %{
      conn: conn,
      disruption_v2: disruption_v2
    } do
      {:ok, live, _html} = live(conn, ~p"/disruptionsv2/#{disruption_v2.id}/edit")

      live |> element("button#add_new_replacement_service_button") |> render_click()

      refute live |> element("button#cancel_add_new_replacement_service_button") |> render_click() =~
               "add new replacement service component"
    end
  end
end
