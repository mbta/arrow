defmodule Arrow.Hastus.ExportUploadTest do
  @moduledoc false
  use Arrow.DataCase

  import Arrow.Factory

  alias Arrow.Hastus.ExportUpload

  @export_dir "test/support/fixtures/hastus"

  describe "extract_data_from_upload/2" do
    @tag export: "example.zip"
    test "extracts data from export", %{export: export} do
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

      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:ok,
               [
                 %{name: "RTL12025-hmb15wg1-Weekday-01"},
                 %{name: "RTL12025-hmb15016-Saturday-01"},
                 %{name: "RTL12025-hmb15017-Sunday-01"},
                 %{name: "RTL12025-hmb15mo1-Weekday-01"}
               ], "line-Blue", _}} = data
    end

    @tag export: "trips_no_shapes.zip"
    test "gives validation errors for invalid exports", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok, {:error, "Export does not contain any valid routes"}} = data
    end

    @tag export: "gl_known_variant.zip"
    test "handles a GL export with a known variant", %{export: export} do
      line = insert(:gtfs_line, id: "line-Green")
      route = insert(:gtfs_route, id: "Green-E", line_id: line.id)

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
            service: insert(:gtfs_service, id: "canonical"),
            route: route,
            route_pattern_id: route_pattern.id,
            directions: [direction]
          ),
        stop: insert(:gtfs_stop, id: "70202")
      )

      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:ok,
               [
                 %{name: "LRV12025-hlb15016-Saturday-01"}
               ], "line-Green", _}} = data
    end

    @tag export: "gl_unambiguous_branch.zip"
    test "handles a GL export with unknown variant but unambiguous branch", %{export: export} do
      line = insert(:gtfs_line, id: "line-Green")
      route = insert(:gtfs_route, id: "Green-E", line_id: line.id)

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
            service: insert(:gtfs_service, id: "canonical"),
            route: route,
            route_pattern_id: route_pattern.id,
            directions: [direction]
          ),
        stop: insert(:gtfs_stop, id: "70202")
      )

      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:ok,
               [
                 %{name: "LRV12025-hlb15016-Saturday-01"}
               ], "line-Green", _}} = data
    end

    @tag export: "gl_trips_ambiguous_branch.zip"
    test "gives validation errors for GL export with ambiguous branches", %{export: export} do
      line = insert(:gtfs_line, id: "line-Green")
      route = insert(:gtfs_route, id: "Green-E", line_id: line.id)

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
        stop: insert(:gtfs_stop, id: "70504")
      )

      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:error,
               "Unable to infer the Green Line branch for 800-1428, West, U, 800. Please request the via_variant be updated to the branch name and provide an updated export"}} =
               data
    end
  end
end
