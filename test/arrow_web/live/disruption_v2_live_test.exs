defmodule ArrowWeb.DisruptionV2LiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.{DisruptionsFixtures, LimitsFixtures, ShuttlesFixtures}

  alias Arrow.Disruptions.DisruptionV2

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
    limit = limit_fixture(disruption_id: disruption_v2.id)
    day_of_week = limit_day_of_week_fixture(limit_id: limit.id)

    %{
      disruption_v2:
        struct(disruption_v2, limits: [struct(limit, limit_day_of_weeks: [day_of_week])])
    }
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
      assert html =~ "Disruption created successfully"
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
      assert html =~ "Disruption updated successfully"
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

      stop_map_container =
        live
        |> form("#disruption_v2-form")
        |> render_change(%{"disruption_v2[new_shuttle_id]" => shuttle.id})
        |> Floki.find("#shuttle-view-map-disruptionsv2-container")

      # make sure the shuttle map container is displayed when we have entered a new shuttle
      assert [_shuttle_map_div] = stop_map_container
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

  describe "Limit" do
    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "can duplicate a limit", %{
      conn: conn,
      disruption_v2: %DisruptionV2{limits: [limit]} = disruption
    } do
      {:ok, live, _html} = live(conn, ~p"/disruptionsv2/#{disruption.id}/edit")

      html = live |> element("button#duplicate-limit-#{limit.id}") |> render_click()

      assert html =~ "add new disruption limit"

      assert html |> Floki.attribute("#limit_start_date", "value") |> List.first() ==
               "#{limit.start_date}"

      assert html |> Floki.attribute("#limit_end_date", "value") |> List.first() ==
               "#{limit.end_date}"
    end
  end
end
