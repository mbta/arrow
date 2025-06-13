defmodule Arrow.Hastus.ExportUploadTest do
  @moduledoc false
  use Arrow.DataCase, async: true

  alias Arrow.Hastus.ExportUpload

  @export_dir "test/support/fixtures/hastus"

  describe "extract_data_from_upload/2" do
    setup :build_gtfs

    @tag build_gtfs_line: "line-Blue"
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

    @tag :skip_build_gtfs
    @tag export: "trips_no_shapes.zip"
    test "gives validation errors for invalid exports", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:error, {:trips_with_invalid_shapes, ["67307092-LRV42024-hlb44uf1-Weekday-01"]}}} =
               data
    end

    @tag export: "gl_known_variant.zip"
    @tag build_gtfs_line: "line-Green"
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
    @tag build_gtfs_line: "line-Green"
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
    @tag build_gtfs_line: "line-Green"
    test "gives validation errors for GL export with ambiguous branches", %{export: export} do
      data = ExportUpload.extract_data_from_upload(%{path: "#{@export_dir}/#{export}"}, "uid")

      assert {:ok,
              {:error,
               "Unable to infer the Green Line branch for 800-1428, West, U, 800. Please request the via_variant be updated to the branch name and provide an updated export"}} =
               data
    end

    @tag skip_build_gtfs: true
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
    @tag build_gtfs_line: "line-Blue"
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
    @tag build_gtfs_line: "line-Blue"
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
    @tag build_gtfs_line: "line-Blue"
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
    @tag build_gtfs_line: "line-Orange"
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
    @tag build_gtfs_line: "line-Green"
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
    @tag build_gtfs_line: "line-Green"
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

  ###############################################
  # TODO: Need to also set up parent station ID #
  # relations for all platform IDs...           #
  ###############################################

  defp build_gtfs(%{skip_build_gtfs: true}), do: :ok
  defp build_gtfs(%{build_gtfs_line: line}), do: build_gtfs(line_params(line))

  defp build_gtfs(context) do
    line = insert(:gtfs_line, id: context.line_id)
    service = insert(:gtfs_service, id: "canonical")

    true = length(context.route_ids) == length(context.stop_sequences)
    true = tuple_size(context.direction_descs) == 2

    [context.route_ids, context.stop_sequences]
    |> Enum.zip()
    |> Enum.each(&insert_canonical(&1, line, service, context.direction_descs))
  end

  defp insert_canonical(
         {route_id, {stop_sequence0, stop_sequence1}},
         line,
         service,
         {dir_desc0, dir_desc1}
       ) do
    route = insert(:gtfs_route, id: route_id, line: line)

    direction0 = insert(:gtfs_direction, direction_id: 0, route: route, desc: dir_desc0)
    direction1 = insert(:gtfs_direction, direction_id: 1, route: route, desc: dir_desc1)

    trip_id0 = ExMachina.sequence("representative_trip")
    trip_id1 = ExMachina.sequence("representative_trip")

    route_pattern0 =
      insert(:gtfs_route_pattern,
        route: route,
        representative_trip_id: trip_id0,
        direction_id: 0
      )

    route_pattern1 =
      insert(:gtfs_route_pattern,
        route: route,
        representative_trip_id: trip_id1,
        direction_id: 1
      )

    trip0 =
      insert(:gtfs_trip,
        id: trip_id0,
        service: service,
        route: route,
        route_pattern: route_pattern0,
        direction_id: 0,
        directions: [direction0, direction1]
      )

    trip1 =
      insert(:gtfs_trip,
        id: trip_id1,
        service: service,
        route: route,
        route_pattern: route_pattern1,
        direction_id: 1,
        directions: [direction0, direction1]
      )

    stop_sequence0
    |> Enum.with_index(1)
    |> Enum.each(fn {stop_id, stop_sequence} ->
      stop = maybe_insert(:gtfs_stop, [id: stop_id], Arrow.Gtfs.Stop)

      insert(:gtfs_stop_time,
        trip: trip0,
        stop_sequence: stop_sequence,
        stop: stop
      )
    end)

    stop_sequence1
    |> Enum.with_index(1)
    |> Enum.each(fn {stop_id, stop_sequence} ->
      stop = maybe_insert(:gtfs_stop, [id: stop_id], Arrow.Gtfs.Stop)

      insert(:gtfs_stop_time,
        trip: trip1,
        stop_sequence: stop_sequence,
        stop: stop
      )
    end)
  end

  defp maybe_insert(factory, attrs, schema_mod) do
    insert(factory, attrs)
  rescue
    e in [Ecto.ConstraintError] ->
      if String.contains?(e.message, "unique_constraint") do
        id = Keyword.fetch!(attrs, :id)
        Arrow.Repo.one!(from(schema_mod, where: [id: ^id]))
      else
        reraise e, __STACKTRACE__
      end
  end

  defp line_params("line-Blue") do
    %{
      line_id: "line-Blue",
      direction_descs: {"West", "East"},
      route_ids: ["Blue"],
      stop_sequences: [
        {
          ~w[70059 70057 70055 70053 70051 70049 70047 70045 70043 70041 70039 70838],
          ~w[70038 70040 70042 70044 70046 70048 70050 70052 70054 70056 70058 70060]
        }
      ]
    }
  end

  defp line_params("line-Orange") do
    %{
      line_id: "line-Orange",
      direction_descs: {"South", "North"},
      route_ids: ["Orange"],
      stop_sequences: [
        {
          ~w[70036 70034 70032 70278 70030 70028 70026 70024 70022 70020 70018 70016 70014 70012 70010 70008 70006 70004 70002 70001],
          ~w[70001 70003 70005 70007 70009 70011 70013 70015 70017 70019 70021 70023 70025 70027 70029 70031 70279 70033 70035 70036]
        }
      ]
    }
  end

  defp line_params("line-Red") do
    %{
      line_id: "line-Red",
      direction_descs: {"South", "North"},
      route_ids: ["Red"],
      stop_sequences: [
        {
          ~w[70061 70063 70065 70067 70069 70071 70073 70075 70077 70079 70081 70083 70095 70097 70099 70101 70103 70105],
          ~w[70105 70104 70102 70100 70098 70096 70084 70082 70080 70078 70076 70074 70072 70070 70068 70066 70064 70061]
        },
        {
          ~w[70061 70063 70065 70067 70069 70071 70073 70075 70077 70079 70081 70083 70085 70087 70089 70091 70093],
          ~w[70094 70092 70090 70088 70086 70084 70082 70080 70078 70076 70074 70072 70070 70068 70066 70064 70061]
        }
      ]
    }
  end

  defp line_params("line-Green") do
    %{
      line_id: "line-Green",
      direction_descs: {"West", "East"},
      route_ids: ["Green-B", "Green-C", "Green-D", "Green-E"],
      stop_sequences: [
        {
          ~w[70202 70196 70159 70157 70155 70153 71151 70149 70147 70145 170141 170137 70135 70131 70129 70127 70125 70121 70117 70115 70113 70111 70107],
          ~w[70106 70110 70112 70114 70116 70120 70124 70126 70128 70130 70134 170136 170140 70144 70146 70148 71150 70152 70154 70156 70158 70200 70201]
        },
        {
          ~w[70202 70197 70159 70157 70155 70153 70151 70211 70213 70215 70217 70219 70223 70225 70227 70229 70231 70233 70235 70237],
          ~w[70238 70236 70234 70232 70230 70228 70226 70224 70220 70218 70216 70214 70212 70150 70152 70154 70156 70158 70200 70201]
        },
        {
          ~w[70504 70502 70208 70206 70204 70202 70198 70159 70157 70155 70153 70151 70187 70183 70181 70179 70177 70175 70173 70171 70169 70167 70165 70163 70161],
          ~w[70160 70162 70164 70166 70168 70170 70172 70174 70176 70178 70180 70182 70186 70150 70152 70154 70156 70158 70200 70201 70203 70205 70207 70501 70503]
        },
        {
          ~w[70512 70510 70508 70506 70514 70502 70208 70206 70204 70202 70199 70159 70157 70155 70239 70241 70243 70245 70247 70249 70251 70253 70255 70257 70260],
          ~w[70260 70258 70256 70254 70252 70250 70248 70246 70244 70242 70240 70154 70156 70158 70200 70201 70203 70205 70207 70501 70513 70505 70507 70509 70511]
        }
      ]
    }
  end
end
