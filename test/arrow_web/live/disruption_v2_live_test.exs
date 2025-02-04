defmodule ArrowWeb.DisruptionV2LiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.{DisruptionsFixtures, LimitsFixtures, ShuttlesFixtures}

  alias Arrow.Disruptions.DisruptionV2
  import Arrow.Factory

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

      assert live |> element("#add_replacement_service") |> render_click() =~
               "add new replacement service component"

      shuttle = shuttle_fixture()

      stop_map_container =
        live
        |> form("#replacement_service-form")
        |> render_change(%{
          replacement_service: %{shuttle_id: shuttle.id, disruption_id: disruption_v2.id}
        })
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

      live |> element("#add_replacement_service") |> render_click()

      refute live |> element("button#cancel_add_replacement_service_button") |> render_click() =~
               "add new replacement service component"
    end

    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "can add and save a replacement service", %{
      conn: conn,
      disruption_v2: disruption_v2
    } do
      {:ok, live, _html} = live(conn, ~p"/disruptionsv2/#{disruption_v2.id}/edit")

      assert live |> element("#add_replacement_service") |> render_click() =~
               "add new replacement service component"

      shuttle = shuttle_fixture()

      data = Jason.encode!(workbook_data())

      valid_attrs = %{
        end_date: ~D[2025-01-22],
        reason: "some reason",
        source_workbook_data: data,
        source_workbook_filename: "some source_workbook_filename",
        start_date: ~D[2025-01-21],
        shuttle_id: shuttle.id,
        disruption_id: disruption_v2.id
      }

      replacement_service_form =
        live
        |> form("#replacement_service-form")
        |> render_change(%{replacement_service: valid_attrs})

      replacement_service_workbook_filename =
        replacement_service_form
        |> Floki.attribute("#display_replacement_service_source_workbook_filename", "value")

      replacement_service_workbook_data =
        replacement_service_form
        |> Floki.attribute("#replacement_service_source_workbook_data", "value")

      assert ["some source_workbook_filename"] = replacement_service_workbook_filename
      assert [^data] = replacement_service_workbook_data

      assert live
             |> form("#replacement_service-form")
             |> render_submit(%{replacement_service: valid_attrs})

      html = render(live)
      assert html =~ "Replacement service created successfully"
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

    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "can add a limit", %{
      conn: conn,
      disruption_v2: %DisruptionV2{} = disruption
    } do
      {:ok, live, _html} = live(conn, ~p"/disruptionsv2/#{disruption.id}/edit")

      route = insert(:gtfs_route)
      start_stop = insert(:gtfs_stop)
      end_stop = insert(:gtfs_stop)

      valid_attrs = %{
        start_date: ~D[2025-01-08],
        end_date: ~D[2025-01-09],
        start_stop_id: start_stop.id,
        end_stop_id: end_stop.id,
        route_id: route.id
      }

      html =
        live
        |> element("#add-limit-component")
        |> render_click()

      assert html =~ "add new disruption limit"

      live
      |> form("#limit-form", limit: %{route_id: valid_attrs.route_id})
      |> render_change()

      submitted_html =
        live
        |> form("#limit-form", limit: valid_attrs)
        |> render_submit()

      refute submitted_html =~ "add new disruption limit"
    end
  end
end
