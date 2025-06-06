defmodule Arrow.Hastus.ExportUploadTest do
  @moduledoc false
  use Arrow.DataCase

  import Arrow.Factory

  alias Arrow.Hastus.ExportUpload

  @export_dir "test/support/fixtures/hastus"

  describe "extract_data_from_upload/2" do
    @tag export: "valid_export.zip"
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

      expected_services = [
        %{
          name: "RTL12025-hmb15016-Saturday-01",
          service_dates: [%{start_date: ~D[2025-03-22], end_date: ~D[2025-03-22]}]
        },
        %{
          name: "RTL12025-hmb15017-Sunday-01",
          service_dates: [%{start_date: ~D[2025-03-23], end_date: ~D[2025-03-23]}]
        },
        %{
          name: "RTL12025-hmb15mo1-Weekday-01",
          service_dates: []
        },
        %{
          name: "RTL12025-hmb15wg1-Weekday-01",
          service_dates: [
            %{start_date: ~D[2025-03-21], end_date: ~D[2025-03-21]},
            %{start_date: ~D[2025-03-24], end_date: ~D[2025-03-25]},
            %{start_date: ~D[2025-03-27], end_date: ~D[2025-04-01]},
            %{start_date: ~D[2025-04-04], end_date: ~D[2025-04-04]}
          ]
        }
      ]

      assert {:ok,
              {:ok,
               %ExportUpload{
                 services: ^expected_services,
                 line_id: "line-Blue",
                 trip_route_directions: [],
                 dup_service_ids_amended?: false
               }}} = data
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
               %ExportUpload{
                 services: [%{name: "LRV12025-hlb15016-Saturday-01"}],
                 line_id: "line-Green",
                 trip_route_directions: [
                   %{
                     route_id: "Green-B",
                     hastus_route_id: "800-1428",
                     via_variant: "B",
                     avi_code: "812"
                   }
                 ],
                 dup_service_ids_amended?: false
               }}} = data
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
        stop: insert(:gtfs_stop, id: "70145")
      )

      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:ok,
               %ExportUpload{
                 services: [%{name: "LRV12025-hlb15016-Saturday-01"}],
                 line_id: "line-Green",
                 trip_route_directions: [
                   %{
                     route_id: "Green-E",
                     avi_code: "812",
                     hastus_route_id: "800-1428",
                     via_variant: "F"
                   }
                 ],
                 dup_service_ids_amended?: false
               }}} = data
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
               [
                 "Unable to infer the Green Line branch for 800-1448, East, , 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1448, West, T, 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1448, West, U, 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1455, East, , 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1455, West, T, 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1455, West, U, 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1464, East, , 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1464, West, BE, 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1464, West, CE, 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1464, West, DE, 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1464, East, T, 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1464, East, U, 800. Please request the via_variant be updated to the branch name and provide an updated export",
                 "Unable to infer the Green Line branch for 800-1464, West, U, 800. Please request the via_variant be updated to the branch name and provide an updated export"
               ]}} =
               data
    end

    @tag export: "empty_all_calendar.zip"
    test "exports services even when all_calendar.txt is empty", %{export: export} do
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

      expected_services = [
        %{name: "RTL12025-hmb15016-Saturday-01", service_dates: []},
        %{name: "RTL12025-hmb15017-Sunday-01", service_dates: []},
        %{name: "RTL12025-hmb15mo1-Weekday-01", service_dates: []},
        %{name: "RTL12025-hmb15wg1-Weekday-01", service_dates: []}
      ]

      assert {:ok,
              {:ok,
               %ExportUpload{
                 services: ^expected_services,
                 line_id: "line-Blue",
                 trip_route_directions: [],
                 dup_service_ids_amended?: false
               }}} =
               ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")
    end

    @tag export: "valid_export.zip"
    test "amends duplicate service IDs", %{export: export} do
      # GTFS reference data
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

      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:ok,
               %ExportUpload{
                 services: [
                   %{
                     name: ^service_id1 <> "-1",
                     service_dates: [%{end_date: ~D[2025-03-22], start_date: ~D[2025-03-22]}]
                   },
                   %{
                     name: ^service_id2 <> "-1",
                     service_dates: [%{end_date: ~D[2025-03-23], start_date: ~D[2025-03-23]}]
                   },
                   %{name: "RTL12025-hmb15mo1-Weekday-01", service_dates: []},
                   %{
                     name: "RTL12025-hmb15wg1-Weekday-01",
                     service_dates: [
                       %{start_date: ~D[2025-03-21], end_date: ~D[2025-03-21]},
                       %{start_date: ~D[2025-03-24], end_date: ~D[2025-03-25]},
                       %{start_date: ~D[2025-03-27], end_date: ~D[2025-04-01]},
                       %{start_date: ~D[2025-04-04], end_date: ~D[2025-04-04]}
                     ]
                   }
                 ],
                 line_id: "line-Blue",
                 trip_route_directions: [],
                 dup_service_ids_amended?: true
               }}} = data
    end
  end
end
