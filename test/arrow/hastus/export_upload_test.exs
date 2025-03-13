defmodule Arrow.Hastus.ExportUploadTest do
  @moduledoc false
  use Arrow.DataCase

  import Arrow.Factory

  alias Arrow.Hastus.{ExportUpload, Service}

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
                 %Service{service_id: "RTL12025-hmb15wg1-Weekday-01"},
                 %Service{service_id: "RTL12025-hmb15016-Saturday-01"},
                 %Service{service_id: "RTL12025-hmb15017-Sunday-01"},
                 %Service{service_id: "RTL12025-hmb15mo1-Weekday-01"}
               ], "line-Blue"}} = data
    end

    @tag export: "trips_no_shapes.zip"
    test "gives validation errors for invalid exports", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok, {:error, "Trips found with invalid shapes"}} = data
    end
  end
end
