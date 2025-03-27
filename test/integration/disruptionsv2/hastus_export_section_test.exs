defmodule Arrow.Integration.Disruptionsv2.HastusExportSectionTest do
  use ExUnit.Case
  use Wallaby.Feature
  import Wallaby.Browser, except: [text: 1]
  import Wallaby.Query
  import Arrow.{DisruptionsFixtures, HastusFixtures}
  import Arrow.Factory

  @moduletag :integration

  feature "can upload a HASTUS export", %{session: session} do
    disruption = disruption_v2_fixture()
    line = insert(:gtfs_line, id: "line-Blue")
    route = insert(:gtfs_route, id: "Blue", line_id: line.id)

    direction = insert(:gtfs_direction, direction_id: 0, route_id: route.id, route: route)

    route_pattern =
      insert(:gtfs_route_pattern,
        route_id: route.id,
        route: route,
        representative_trip_id: "Test",
        direction_id: 0
      )

    insert(:gtfs_stop_time,
      trip:
        insert(:gtfs_trip,
          id: "Test",
          route: route,
          route_pattern_id: route_pattern.id,
          directions: [direction]
        ),
      stop: insert(:gtfs_stop, id: "70054")
    )

    session
    |> visit("/disruptionsv2/#{disruption.id}/edit")
    |> scroll_down()
    |> click(text("upload HASTUS export"))
    |> assert_text("add a new service schedule")
    |> attach_file(file_field("hastus_export", visible: false),
      path: "test/support/fixtures/hastus/valid_export.zip"
    )
    |> assert_text("Successfully imported export valid_export.zip!")
    |> click(Query.css("#save-export-button"))
    |> assert_text("RTL12025-hmb15wg1-Weekday-01")
    |> assert_text("RTL12025-hmb15016-Saturday-01")
    |> assert_text("RTL12025-hmb15017-Sunday-01")
  end

  feature "shows validation error for bad exports", %{session: session} do
    disruption = disruption_v2_fixture()

    session
    |> visit("/disruptionsv2/#{disruption.id}/edit")
    |> scroll_down()
    |> click(text("upload HASTUS export"))
    |> assert_text("add a new service schedule")
    |> attach_file(file_field("hastus_export", visible: false),
      path: "test/support/fixtures/hastus/trips_no_shapes.zip"
    )
    |> assert_text("Export does not contain any valid routes")
  end

  feature "shows form errors for invalid HASTUS export", %{session: session} do
    disruption = disruption_v2_fixture()
    line = insert(:gtfs_line, id: "line-Blue")
    export = export_fixture(line_id: line.id, disruption_id: disruption.id)

    session
    |> visit("/disruptionsv2/#{disruption.id}/edit")
    |> scroll_down()
    |> assert_text("some-Weekday-service")
    |> click(Query.css("#edit-export-button-#{export.id}"))
    |> assert_text("edit service schedule")
    |> scroll_down()
    |> click(Query.css("#import-checkbox-0"))
    |> click(Query.css("#save-export-button"))
    |> assert_text("You must import at least one service")
  end

  feature "edits existing export", %{session: session} do
    disruption = disruption_v2_fixture()
    line = insert(:gtfs_line, id: "line-Blue")

    export =
      export_fixture(
        line_id: line.id,
        disruption_id: disruption.id,
        services: [
          %{
            name: "some-Weekday-service",
            service_dates: [%{start_date: ~D[2025-01-01], end_date: ~D[2025-01-10]}],
            import?: true
          },
          %{
            name: "some-Saturday-service",
            service_dates: [%{start_date: ~D[2025-02-01], end_date: ~D[2025-02-10]}],
            import?: true
          }
        ]
      )

    session
    |> visit("/disruptionsv2/#{disruption.id}/edit")
    |> scroll_down()
    |> assert_text("some-Weekday-service")
    |> click(Query.css("#edit-export-button-#{export.id}"))
    |> assert_text("edit service schedule")
    |> scroll_down()
    |> click(Query.css("#import-checkbox-0"))
    |> click(Query.css("#save-export-button"))
    |> assert_text("some-Saturday-service")
    |> refute_has(Query.text("some-Weekday-service"))
  end

  feature "deletes existing export", %{session: session} do
    disruption = disruption_v2_fixture()
    line = insert(:gtfs_line, id: "line-Blue")
    export = export_fixture(line_id: line.id, disruption_id: disruption.id)

    session
    |> visit("/disruptionsv2/#{disruption.id}/edit")
    |> scroll_down()
    |> assert_text("some-Weekday-service")
    |> click(Query.css("#delete-export-button-#{export.id}"))
    |> refute_has(Query.css("#export-table-#{export.id}"))
  end

  defp scroll_down(parent) do
    execute_script(parent, "window.scrollBy(0, window.innerHeight)")
  end
end
