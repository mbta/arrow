defmodule Arrow.Hastus.ExportUploadTest do
  @moduledoc false
  use Arrow.DataCase, async: true

  alias Arrow.Hastus.ExportUpload

  @export_dir "test/support/fixtures/hastus"

  describe "extract_data_from_upload/2" do
    setup {Test.Support.GtfsHelper, :insert_subway_line}

    @tag subway_line: "line-Blue"
    @tag export: "valid_export.zip"
    test "extracts data from export", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      expected_services = [
        %{
          name: "RTL12025-hmb15016-Saturday-01",
          service_dates: [%{start_date: ~D[2025-03-22], end_date: ~D[2025-03-22]}],
          derived_limits: []
        },
        %{
          name: "RTL12025-hmb15017-Sunday-01",
          service_dates: [%{start_date: ~D[2025-03-23], end_date: ~D[2025-03-23]}],
          derived_limits: []
        },
        %{
          name: "RTL12025-hmb15mo1-Weekday-01",
          service_dates: [],
          derived_limits: []
        },
        %{
          name: "RTL12025-hmb15wg1-Weekday-01",
          service_dates: [
            %{start_date: ~D[2025-03-21], end_date: ~D[2025-03-21]},
            %{start_date: ~D[2025-03-24], end_date: ~D[2025-03-25]},
            %{start_date: ~D[2025-03-27], end_date: ~D[2025-04-01]},
            %{start_date: ~D[2025-04-04], end_date: ~D[2025-04-04]}
          ],
          derived_limits: [%{start_stop_id: "70039", end_stop_id: "70838"}]
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

    @tag :skip_insert_subway_line
    @tag export: "trips_no_shapes.zip"
    test "gives validation errors for invalid exports", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:error, {:trips_with_invalid_shapes, ["67307092-LRV42024-hlb44uf1-Weekday-01"]}}} =
               data
    end

    @tag export: "gl_known_variant.zip"
    @tag subway_line: "line-Green"
    test "handles a GL export with a known variant", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:ok,
               %ExportUpload{
                 services: [
                   %{
                     name: "LRV12025-hlb15016-Saturday-01",
                     service_dates: [%{start_date: ~D[2025-03-08], end_date: ~D[2025-03-08]}],
                     derived_limits: []
                   }
                 ],
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
    @tag subway_line: "line-Green"
    test "handles a GL export with unknown variant but unambiguous branch", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:ok,
               %ExportUpload{
                 services: [%{name: "LRV12025-hlb15016-Saturday-01"}],
                 line_id: "line-Green",
                 trip_route_directions: [
                   %{
                     route_id: "Green-B",
                     avi_code: "812",
                     hastus_route_id: "800-1428",
                     via_variant: "F"
                   }
                 ],
                 dup_service_ids_amended?: false
               }}} = data
    end

    @tag export: "gl_trips_ambiguous_branch.zip"
    @tag subway_line: "line-Green"
    test "gives validation errors for GL export with ambiguous branches", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:error,
               "Unable to infer the Green Line branch for 800-1428, West, U, 800. Please request the via_variant be updated to the branch name and provide an updated export"}} =
               data
    end

    @tag skip_insert_subway_line: true
    @tag export: "gl_trips_ambiguous_branch_real_world.zip"
    test "handles GL export with variant suffixes (e.g. BE, CE, DE)", %{export: export} do
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

      assert {:ok, {:error, errors}} = data

      # These are variants that can't be inferred via patterns, but are known by the via_variant
      refute errors =~ "West, BE, 800"
      refute errors =~ "West, CE, 800"
      refute errors =~ "West, DE, 800"

      # These are variants that just can't be inferred
      assert errors =~ "West, T, 800"
      assert errors =~ "West, U, 800"
      assert errors =~ "East, , 800"
    end

    @tag export: "empty_all_calendar.zip"
    @tag subway_line: "line-Blue"
    test "exports services even when all_calendar.txt is empty", %{export: export} do
      expected_services = [
        %{name: "RTL12025-hmb15016-Saturday-01", service_dates: [], derived_limits: []},
        %{name: "RTL12025-hmb15017-Sunday-01", service_dates: [], derived_limits: []},
        %{name: "RTL12025-hmb15mo1-Weekday-01", service_dates: [], derived_limits: []},
        %{name: "RTL12025-hmb15wg1-Weekday-01", service_dates: [], derived_limits: []}
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
    @tag subway_line: "line-Blue"
    test "amends duplicate service IDs", %{export: export} do
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

    @tag export: "BowdoinClosureTest.zip"
    @tag subway_line: "line-Blue"
    test "extracts multiple derived limits when exported service implies multiple limits", %{
      export: export
    } do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      expected_services = [
        %{
          name: "RTL12025-hmb15016-Saturday-01-4",
          service_dates: [%{start_date: ~D[2025-03-22], end_date: ~D[2025-03-22]}],
          derived_limits: []
        },
        %{
          name: "RTL12025-hmb15017-Sunday-01-4",
          service_dates: [%{start_date: ~D[2025-03-23], end_date: ~D[2025-03-23]}],
          derived_limits: []
        },
        %{
          name: "RTL12025-hmb15mo1-Weekday-01-3",
          service_dates: [%{start_date: ~D[2025-03-24], end_date: ~D[2025-03-24]}],
          derived_limits: [%{start_stop_id: "70039", end_stop_id: "70838"}]
        },
        %{
          name: "RTL12025-hmb15wg1-Weekday-01-4",
          service_dates: [%{start_date: ~D[2025-03-21], end_date: ~D[2025-03-21]}],
          derived_limits: [%{start_stop_id: "70039", end_stop_id: "70838"}]
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

    @tag export: "2025-Spring-vehicle-OLNorthStationOakGrove-v3.zip"
    @tag subway_line: "line-Orange"
    test "OL export", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      expected_services = [
        %{
          name: "RTL22025-hmo25ea1-Weekday-01",
          service_dates: [%{start_date: ~D[2025-05-09], end_date: ~D[2025-05-09]}],
          derived_limits: [%{start_stop_id: "70036", end_stop_id: "70026"}]
        },
        %{
          name: "RTL22025-hmo25on1-Weekday-01",
          service_dates: [%{start_date: ~D[2025-05-12], end_date: ~D[2025-05-16]}],
          derived_limits: [%{start_stop_id: "70036", end_stop_id: "70026"}]
        },
        %{
          name: "RTL22025-hmo25on6-Saturday-01",
          service_dates: [
            %{start_date: ~D[2025-05-10], end_date: ~D[2025-05-10]},
            %{start_date: ~D[2025-05-17], end_date: ~D[2025-05-17]}
          ],
          derived_limits: [%{start_stop_id: "70036", end_stop_id: "70026"}]
        },
        %{
          name: "RTL22025-hmo25on7-Sunday-01",
          service_dates: [
            %{start_date: ~D[2025-05-11], end_date: ~D[2025-05-11]},
            %{start_date: ~D[2025-05-18], end_date: ~D[2025-05-18]}
          ],
          derived_limits: [%{start_stop_id: "70036", end_stop_id: "70026"}]
        }
      ]

      assert {:ok,
              {:ok,
               %ExportUpload{
                 services: ^expected_services,
                 line_id: "line-Orange",
                 trip_route_directions: [],
                 dup_service_ids_amended?: false
               }}} = data
    end

    @tag export: "2025-AprilGLX-vehicle-v1.zip"
    @tag subway_line: "line-Green"
    test "a complex GL export", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      expected_services = [
        %{
          name: "LRV22025-hlb25gv6-Saturday-01-1",
          service_dates: [%{start_date: ~D[2025-04-26], end_date: ~D[2025-04-26]}],
          derived_limits: [
            %{start_stop_id: "70504", end_stop_id: "70202"},
            %{start_stop_id: "70512", end_stop_id: "70202"}
          ]
        },
        %{
          name: "LRV22025-hlb25gv7-Sunday-01-1",
          service_dates: [%{start_date: ~D[2025-04-27], end_date: ~D[2025-04-27]}],
          derived_limits: [
            %{start_stop_id: "70504", end_stop_id: "70202"},
            %{start_stop_id: "70512", end_stop_id: "70202"}
          ]
        }
      ]

      assert {:ok,
              {:ok,
               %ExportUpload{
                 services: ^expected_services,
                 line_id: "line-Green",
                 trip_route_directions: [
                   %{
                     route_id: "Green-B",
                     hastus_route_id: "800-1440",
                     via_variant: "B",
                     avi_code: "813"
                   },
                   %{
                     route_id: "Green-C",
                     hastus_route_id: "800-1440",
                     via_variant: "C",
                     avi_code: "833"
                   },
                   %{
                     route_id: "Green-D",
                     hastus_route_id: "800-1440",
                     via_variant: "D",
                     avi_code: "842"
                   },
                   %{
                     route_id: "Green-D",
                     hastus_route_id: "800-1440",
                     via_variant: "D",
                     avi_code: "852"
                   },
                   %{
                     route_id: "Green-E",
                     hastus_route_id: "800-1440",
                     via_variant: "E",
                     avi_code: "872"
                   },
                   %{
                     route_id: "Green-E",
                     hastus_route_id: "800-1440",
                     via_variant: "E",
                     avi_code: "882"
                   }
                 ],
                 dup_service_ids_amended?: false
               }}} = data
    end

    @tag export: "2025-spring-GLBabcockNorthStation-v2.zip"
    @tag subway_line: "line-Green"
    test "an especially complex GL export", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      expected_services = [
        %{
          name: "LRV22025-hlb25ge1-Weekday-01",
          service_dates: [%{start_date: ~D[2025-06-04], end_date: ~D[2025-06-04]}],
          # These limits are technically correct as they "sum up" to the limits
          # we expect, but there's a lot of overlap.
          # We'll try to make some followup tweaks to improve this, but it's
          # acceptable for now.
          derived_limits: [
            # North Station to Gov Ctr - from ?
            %{start_stop_id: "70206", end_stop_id: "70202"},
            # Gov Ctr to Boylston - from ?
            %{start_stop_id: "70202", end_stop_id: "70159"},
            # Copley to Heath St - from Green-E
            %{start_stop_id: "70155", end_stop_id: "70260"},
            # Gov Ctr to Babcock - from Green-B
            %{start_stop_id: "70202", end_stop_id: "170137"},
            # Gov Ctr to Kenmore - from Green-C
            %{start_stop_id: "70202", end_stop_id: "70151"},
            # North Station to Kenmore - from Green-D
            %{start_stop_id: "70206", end_stop_id: "70151"},
            # North Station to Heath St - from Green-E
            %{start_stop_id: "70206", end_stop_id: "70260"}
          ]
        },
        %{
          name: "LRV22025-hlb25gn6-Saturday-01",
          service_dates: [%{start_date: ~D[2025-06-07], end_date: ~D[2025-06-07]}],
          derived_limits: [
            # Gov Ctr to Babcock - from Green-B
            %{start_stop_id: "70202", end_stop_id: "170137"},
            # Gov Ctr to Kenmore - from Green-C
            %{start_stop_id: "70202", end_stop_id: "70151"},
            # North Station to Kenmore - from Green-D
            %{start_stop_id: "70206", end_stop_id: "70151"},
            # North Station to Heath St - from Green-E
            %{start_stop_id: "70206", end_stop_id: "70260"}
          ]
        },
        %{
          name: "LRV22025-hlb25gn7-Sunday-01",
          service_dates: [%{start_date: ~D[2025-06-08], end_date: ~D[2025-06-08]}],
          derived_limits: [
            %{start_stop_id: "70202", end_stop_id: "170137"},
            %{start_stop_id: "70202", end_stop_id: "70151"},
            %{start_stop_id: "70206", end_stop_id: "70151"},
            %{start_stop_id: "70206", end_stop_id: "70260"}
          ]
        },
        %{
          name: "LRV22025-hlb35gn1-Weekday-01",
          service_dates: [%{start_date: ~D[2025-06-05], end_date: ~D[2025-06-06]}],
          derived_limits: [
            %{start_stop_id: "70202", end_stop_id: "170137"},
            %{start_stop_id: "70202", end_stop_id: "70151"},
            %{start_stop_id: "70206", end_stop_id: "70151"},
            %{start_stop_id: "70206", end_stop_id: "70260"}
          ]
        }
      ]

      expected_trip_route_directions = [
        %{route_id: "Green-E", hastus_route_id: "800-1448", via_variant: "", avi_code: "86"},
        %{route_id: "Green-B", hastus_route_id: "800-1448", via_variant: "B", avi_code: "81"},
        %{route_id: "Green-C", hastus_route_id: "800-1448", via_variant: "C", avi_code: "834"},
        %{route_id: "Green-D", hastus_route_id: "800-1448", via_variant: "D", avi_code: "854"},
        %{route_id: "Green-E", hastus_route_id: "800-1448", via_variant: "T", avi_code: "86"},
        %{route_id: "Green-D", hastus_route_id: "800-1448", via_variant: "U", avi_code: "85"},
        %{route_id: "Green-E", hastus_route_id: "800-1455", via_variant: "", avi_code: "86"},
        %{route_id: "Green-B", hastus_route_id: "800-1455", via_variant: "B", avi_code: "81"},
        %{route_id: "Green-C", hastus_route_id: "800-1455", via_variant: "C", avi_code: "834"},
        %{route_id: "Green-D", hastus_route_id: "800-1455", via_variant: "D", avi_code: "854"},
        %{route_id: "Green-E", hastus_route_id: "800-1455", via_variant: "T", avi_code: "86"},
        %{route_id: "Green-D", hastus_route_id: "800-1455", via_variant: "U", avi_code: "85"},
        %{route_id: "Green-E", hastus_route_id: "800-1464", via_variant: "", avi_code: "86"},
        %{route_id: "Green-B", hastus_route_id: "800-1464", via_variant: "B", avi_code: "812"},
        %{route_id: "Green-B", hastus_route_id: "800-1464", via_variant: "B", avi_code: "816"},
        %{route_id: "Green-B", hastus_route_id: "800-1464", via_variant: "BE", avi_code: "81"},
        %{route_id: "Green-C", hastus_route_id: "800-1464", via_variant: "C", avi_code: "832"},
        %{route_id: "Green-C", hastus_route_id: "800-1464", via_variant: "C", avi_code: "836"},
        %{route_id: "Green-C", hastus_route_id: "800-1464", via_variant: "CE", avi_code: "834"},
        %{route_id: "Green-D", hastus_route_id: "800-1464", via_variant: "D", avi_code: "845"},
        %{route_id: "Green-D", hastus_route_id: "800-1464", via_variant: "D", avi_code: "855"},
        %{route_id: "Green-D", hastus_route_id: "800-1464", via_variant: "DE", avi_code: "854"},
        %{route_id: "Green-E", hastus_route_id: "800-1464", via_variant: "E", avi_code: "885"},
        %{route_id: "Green-E", hastus_route_id: "800-1464", via_variant: "E", avi_code: "886"},
        %{route_id: "Green-E", hastus_route_id: "800-1464", via_variant: "T", avi_code: "86"},
        %{route_id: "Green-D", hastus_route_id: "800-1464", via_variant: "U", avi_code: "85"}
      ]

      assert {:ok,
              {:ok,
               %ExportUpload{
                 services: ^expected_services,
                 line_id: "line-Green",
                 trip_route_directions: ^expected_trip_route_directions,
                 dup_service_ids_amended?: false
               }}} = data
    end
  end
end
