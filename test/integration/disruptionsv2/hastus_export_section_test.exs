defmodule Arrow.Integration.Disruptionsv2.HastusExportSectionTest do
  use ExUnit.Case
  use Wallaby.Feature
  import Wallaby.Browser, except: [text: 1]
  import Wallaby.Query
  import Arrow.DisruptionsFixtures
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
      path: "test/support/fixtures/hastus/example.zip"
    )
    |> assert_text("Successfully imported export example.zip!")
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

  defp scroll_down(parent) do
    execute_script(parent, "window.scrollBy(0, 400)")
  end
end
