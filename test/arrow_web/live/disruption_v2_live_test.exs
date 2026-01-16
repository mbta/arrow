defmodule ArrowWeb.DisruptionV2LiveTest do
  use ArrowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Arrow.{DisruptionsFixtures, LimitsFixtures, ShuttlesFixtures}

  alias Arrow.Disruptions.DisruptionV2

  @create_attrs %{
    title: "the great molasses disruption of 2025",
    mode: "subway",
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
    mode: "subway",
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

  defp create_disruption_v2_with_replacement_service(context) do
    %{disruption_v2: disruption_v2} = create_disruption_v2(context)
    rs = replacement_service_fixture(%{disruption_id: disruption_v2.id})

    %{
      disruption_v2: %{disruption_v2 | replacement_services: [rs]}
    }
  end

  describe "Changing Disruptions" do
    @tag :authenticated_admin
    test "saves new disruption_v2", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/disruptions/new")

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
    test "saves new disruption_v2 for Commuter Rail", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/disruptions/new")

      assert index_live
             |> form("#disruption_v2-form",
               disruption_v2: %{@create_attrs | mode: "commuter_rail"}
             )
             |> render_submit()

      html = render(index_live)
      assert html =~ "Disruption created successfully"
      refute html =~ "Limits"
      assert html =~ "Trainsformer Service Schedules"
      refute html =~ "Replacement Service"
    end

    @tag :authenticated_admin
    test "Does not show additional sections when creating new disruption", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/disruptions/new")

      refute html =~ "Replacement Service"
      refute html =~ "HASTUS Service Schedules"
      refute html =~ "Limits"
    end

    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "updates disruption_v2", %{conn: conn, disruption_v2: disruption_v2} do
      {:ok, index_live, _html} = live(conn, ~p"/disruptions/#{disruption_v2.id}/edit")

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#disruption_v2-form", disruption_v2: @update_attrs)
             |> render_submit()

      html = render(index_live)
      assert html =~ "Disruption updated successfully"
    end

    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "shows additional sections when editing disruption", %{
      conn: conn,
      disruption_v2: disruption_v2
    } do
      {:ok, _index_live, html} = live(conn, ~p"/disruptions/#{disruption_v2.id}/edit")

      assert html =~ "Replacement Service"
      assert html =~ "HASTUS Service Schedules"
      assert html =~ "Limits"
    end
  end

  describe "Replacement Service" do
    @tag :authenticated_admin
    setup [:create_disruption_v2]

    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "can activate add replacement service flow", %{conn: conn, disruption_v2: disruption_v2} do
      {:ok, live, _html} = live(conn, ~p"/disruptions/#{disruption_v2.id}")

      assert live |> element("#add_replacement_service") |> render_click() =~
               "add new replacement service component"

      shuttle = shuttle_fixture()

      stop_map_container =
        live
        |> form("#replacement_service-form")
        |> render_change(%{
          replacement_service: %{shuttle_id: shuttle.id, disruption_id: disruption_v2.id}
        })
        |> LazyHTML.from_fragment()
        |> LazyHTML.query("#shuttle-view-map-disruptionsv2-container")
        |> LazyHTML.to_tree()

      assert [
               {"div", [{"id", "shuttle-view-map-disruptionsv2-container"}, _], _}
             ] = stop_map_container
    end

    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "can deactivate add replacement service flow", %{
      conn: conn,
      disruption_v2: disruption_v2
    } do
      {:ok, live, _html} = live(conn, ~p"/disruptions/#{disruption_v2.id}")

      live |> element("#add_replacement_service") |> render_click()

      refute live |> element("#cancel_add_replacement_service_button") |> render_click() =~
               "add new replacement service component"
    end

    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "can add and save a replacement service", %{
      conn: conn,
      disruption_v2: disruption_v2
    } do
      {:ok, live, _html} = live(conn, ~p"/disruptions/#{disruption_v2.id}")

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
        |> LazyHTML.from_fragment()

      replacement_service_workbook_filename =
        replacement_service_form
        |> LazyHTML.query("#display_replacement_service_source_workbook_filename")
        |> LazyHTML.attribute("value")

      replacement_service_workbook_data =
        replacement_service_form
        |> LazyHTML.query("#replacement_service_source_workbook_data")
        |> LazyHTML.attribute("value")

      assert ["some source_workbook_filename"] = replacement_service_workbook_filename
      assert [^data] = replacement_service_workbook_data

      assert live
             |> form("#replacement_service-form")
             |> render_submit(%{replacement_service: valid_attrs})

      html = render(live)
      assert html =~ "Replacement service created successfully"
    end

    @tag :authenticated_admin

    setup [:create_disruption_v2_with_replacement_service]

    test "can change shuttle when editing replacement service", %{
      conn: conn,
      disruption_v2: disruption_v2
    } do
      {:ok, live, _html} = live(conn, ~p"/disruptions/#{disruption_v2.id}")

      replacement_service = List.first(disruption_v2.replacement_services)

      replacement_service_shuttle_id_input = "#replacement_service_shuttle_id"
      replacement_service_shuttle_id_text_input = "#replacement_service_shuttle_id_text_input"

      assert live
             |> element("#edit_replacement_service-#{replacement_service.id}")
             |> render_click() =~
               "select shuttle route"

      html =
        live
        |> render()
        |> LazyHTML.from_fragment()

      assert html
             |> LazyHTML.query(replacement_service_shuttle_id_input)
             |> LazyHTML.attribute("value")
             |> List.first() =~ "#{replacement_service.shuttle.id}"

      assert html
             |> LazyHTML.query(replacement_service_shuttle_id_text_input)
             |> LazyHTML.attribute("value")
             |> List.first() =~ "#{replacement_service.shuttle.shuttle_name}"

      new_shuttle = shuttle_fixture()
      refute new_shuttle.id == replacement_service.shuttle.id

      updated_shuttle_input_html =
        live
        |> form("#replacement_service-form")
        |> render_change(%{
          replacement_service: %{shuttle_id: new_shuttle.id, disruption_id: disruption_v2.id}
        })
        |> LazyHTML.from_fragment()

      assert updated_shuttle_input_html
             |> LazyHTML.query(replacement_service_shuttle_id_input)
             |> LazyHTML.attribute("value")
             |> List.first() =~ "#{new_shuttle.id}"

      assert updated_shuttle_input_html
             |> LazyHTML.query(replacement_service_shuttle_id_text_input)
             |> LazyHTML.attribute("value")
             |> List.first() =~ "#{new_shuttle.shuttle_name}"
    end

    @tag :authenticated_admin
    setup [:create_disruption_v2_with_replacement_service]

    test "shuttle input handles form updates when editing replacement service", %{
      conn: conn,
      disruption_v2: disruption_v2
    } do
      {:ok, live, _html} = live(conn, ~p"/disruptions/#{disruption_v2.id}")

      replacement_service = List.first(disruption_v2.replacement_services)
      shuttle = replacement_service.shuttle

      replacement_service_shuttle_id_input = "#replacement_service_shuttle_id"
      replacement_service_shuttle_id_text_input = "#replacement_service_shuttle_id_text_input"

      assert live
             |> element("#edit_replacement_service-#{replacement_service.id}")
             |> render_click() =~
               "select shuttle route"

      html =
        live
        |> render()
        |> LazyHTML.from_fragment()

      assert html
             |> LazyHTML.query(replacement_service_shuttle_id_input)
             |> LazyHTML.attribute("value")
             |> List.first() =~ "#{shuttle.id}"

      assert html
             |> LazyHTML.query(replacement_service_shuttle_id_text_input)
             |> LazyHTML.attribute("value")
             |> List.first() =~ "#{shuttle.shuttle_name}"

      updated_shuttle_input_html =
        live
        |> form("#replacement_service-form")
        |> render_change(%{
          replacement_service: %{
            shuttle_id: shuttle.id,
            disruption_id: disruption_v2.id
          }
        })
        |> LazyHTML.from_fragment()

      assert updated_shuttle_input_html
             |> LazyHTML.query(replacement_service_shuttle_id_input)
             |> LazyHTML.attribute("value")
             |> List.first() =~ "#{shuttle.id}"

      assert updated_shuttle_input_html
             |> LazyHTML.query(replacement_service_shuttle_id_text_input)
             |> LazyHTML.attribute("value")
             |> List.first() =~ "#{shuttle.shuttle_name}"
    end
  end

  describe "Limit" do
    @tag :authenticated_admin
    setup [:create_disruption_v2]

    test "can duplicate a limit", %{
      conn: conn,
      disruption_v2: %DisruptionV2{limits: [limit]} = disruption
    } do
      {:ok, live, _html} = live(conn, ~p"/disruptions/#{disruption.id}")

      html =
        live
        |> element("#duplicate-limit-#{limit.id}")
        |> render_click()
        |> LazyHTML.from_fragment()

      assert LazyHTML.text(html) =~ "add new disruption limit"

      assert html
             |> LazyHTML.query("#limit_start_date")
             |> LazyHTML.attribute("value")
             |> List.first() ==
               "#{limit.start_date}"

      assert html
             |> LazyHTML.query("#limit_end_date")
             |> LazyHTML.attribute("value")
             |> List.first() ==
               "#{limit.end_date}"
    end
  end
end
