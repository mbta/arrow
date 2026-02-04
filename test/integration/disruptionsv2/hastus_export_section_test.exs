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
    |> visit("/disruptions/#{disruption.id}")
    |> scroll_down()
    |> click(text("Upload HASTUS export"))
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
    |> visit("/disruptions/#{disruption.id}")
    |> scroll_down()
    |> click(text("Upload HASTUS export"))
    |> assert_text("add a new service schedule")
    |> attach_file(file_field("hastus_export", visible: false),
      path: "test/support/fixtures/hastus/trips_no_shapes.zip"
    )
    |> assert_text("Some trips have invalid or missing shapes")
  end

  feature "shows form errors for invalid HASTUS export", %{session: session} do
    disruption = disruption_v2_fixture()
    line = insert(:gtfs_line, id: "line-Blue")
    export = export_fixture(line_id: line.id, disruption_id: disruption.id)

    session
    |> visit("/disruptions/#{disruption.id}")
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
    |> visit("/disruptions/#{disruption.id}")
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
    |> visit("/disruptions/#{disruption.id}")
    |> scroll_down()
    |> assert_text("some-Weekday-service")
    |> click(Query.css("#delete-hastus-export-button-#{export.id}"))
    |> refute_has(Query.css("#export-table-hastus-#{export.id}"))
  end

  feature "warns and requests confirmation if export reuses existing service IDs known to Arrow",
          %{session: session} do
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

    # Insert 2 HASTUS services whose IDs are duplicates of those in the export
    %{name: service_id1} = insert(:hastus_service, name: "RTL12025-hmb15016-Saturday-01")
    %{name: service_id2} = insert(:hastus_service, name: "RTL12025-hmb15017-Sunday-01")

    export_path = "test/support/fixtures/hastus/valid_export.zip"

    expected_service_ids = [
      "RTL12025-hmb15wg1-Weekday-01",
      service_id1 <> "-1",
      service_id2 <> "-1"
    ]

    upload_and_assert_deduplicated_service_ids(
      session,
      disruption.id,
      export_path,
      expected_service_ids
    )
  end

  feature "detects duplicate service IDs across multiple HASTUS exports uploaded for one disruption",
          %{session: session} do
    # Arrange step is identical to that of the previous test.
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

    %{name: service_id1} = insert(:hastus_service, name: "RTL12025-hmb15016-Saturday-01")
    %{name: service_id2} = insert(:hastus_service, name: "RTL12025-hmb15017-Sunday-01")

    export_path = "test/support/fixtures/hastus/valid_export.zip"

    expected_service_ids = [
      "RTL12025-hmb15wg1-Weekday-01",
      service_id1 <> "-1",
      service_id2 <> "-1"
    ]

    upload_and_assert_deduplicated_service_ids(
      session,
      disruption.id,
      export_path,
      expected_service_ids
    )

    # Now, upload the export again. We should see new deduplicated IDs that respect the
    # previously uploaded export's deduplicated IDs.
    new_expected_ids = [
      "RTL12025-hmb15wg1-Weekday-01-1",
      service_id1 <> "-2",
      service_id2 <> "-2"
    ]

    expected_service_ids = new_expected_ids ++ expected_service_ids

    upload_and_assert_deduplicated_service_ids(
      session,
      disruption.id,
      export_path,
      expected_service_ids
    )
  end

  defp upload_and_assert_deduplicated_service_ids(
         session,
         disruption_id,
         export_path,
         assert_service_ids
       ) do
    session
    |> visit("/disruptions/#{disruption_id}")
    |> scroll_down()
    |> click(text("Upload HASTUS export"))
    |> assert_text("add a new service schedule")
    |> attach_file(file_field("hastus_export", visible: false), path: export_path)
    |> assert_text("Successfully imported export valid_export.zip!")
    # Assert that the warning and confirmation buttons are shown
    |> assert_text(
      "The HASTUS export that you uploaded includes service IDs that have been previously imported into Arrow."
    )
    |> assert_text("Are you sure you would like to continue?")
    |> assert_has(Query.css("#accept-duplicate-service-ids-button"))
    |> assert_has(Query.css("#reject-duplicate-service-ids-button"))
    |> click(Query.css("#accept-duplicate-service-ids-button"))
    # Assert that the usual save / cancel buttons are shown after accepting
    |> assert_has(Query.css("#save-export-button"))
    |> assert_has(Query.css("#cancel_add_hastus_export_button"))
    |> click(Query.css("#save-export-button"))
    # Assert that the saved service IDs include the expected IDs
    |> then(fn session ->
      for service_id <- assert_service_ids, reduce: session do
        session_acc -> assert_text(session_acc, service_id)
      end
    end)
  end

  defp scroll_down(parent) do
    execute_script(parent, "window.scrollBy(0, window.innerHeight)")
  end
end
