defmodule Arrow.GtfsLineFixtures do
  @moduledoc """
  This module defines a `build_gtfs/1` helper to
  insert routes, trips, stops, etc into Arrow's
  `gtfs_*` DB tables.
  """
  import Arrow.Factory
  import Ecto.Query

  @doc """
  Inserts canonical data about a subway line into the DB.

  This inserts records in the following tables:
  - gtfs_lines
  - gtfs_services
  - gtfs_routes
  - gtfs_directions
  - gtfs_route_patterns
  - gtfs_trips
  - gtfs_stops
  - gtfs_stop_times

  Intended for use with `setup` and a tag:

      describe "some_fn_with_gtfs_deps/1" do
        setup {Arrow.GtfsLineFixtures, :build_gtfs_line}

        # Insert Green Line data for this test.
        @tag gtfs_line: "line-Green"
        test "handles Green Line scenario" do
          # This test has access to Green Line canonical data.
        end

        # If a test in the block doesn't need line data, use tag `:skip_build_gtfs_line`.
        @tag :skip_build_gtfs_line
        test "raises exception on bad argument" do
          ...
        end
      end
  """
  def build_gtfs_line(%{skip_build_gtfs_line: true}), do: :ok
  def build_gtfs_line(%{gtfs_line: line}), do: do_build_gtfs_line(line_params(line))

  defp do_build_gtfs_line(context) do
    line = insert(:gtfs_line, id: context.line_id)
    service = insert(:gtfs_service, id: "canonical")

    true = length(context.route_ids) == length(context.stop_sequences)
    true = tuple_size(context.direction_descs) == 2

    [context.route_ids, context.stop_sequences]
    |> Enum.zip()
    |> Enum.each(&insert_canonical(&1, line, service, context.direction_descs))
  end

  defp insert_canonical(
         {route_id, stop_sequences},
         line,
         service,
         {dir_desc0, dir_desc1}
       ) do
    route = insert(:gtfs_route, id: route_id, line: line)

    direction0 = insert(:gtfs_direction, direction_id: 0, route: route, desc: dir_desc0)
    direction1 = insert(:gtfs_direction, direction_id: 1, route: route, desc: dir_desc1)

    trip_ids =
      {ExMachina.sequence("representative_trip"), ExMachina.sequence("representative_trip")}

    Enum.each(0..1, fn direction_id ->
      trip_id = elem(trip_ids, direction_id)

      route_pattern =
        insert(:gtfs_route_pattern,
          route: route,
          representative_trip_id: trip_id,
          direction_id: direction_id
        )

      trip =
        insert(:gtfs_trip,
          id: trip_id,
          service: service,
          route: route,
          route_pattern: route_pattern,
          direction_id: direction_id,
          directions: [direction0, direction1]
        )

      stop_sequences
      |> elem(direction_id)
      |> Enum.with_index(1)
      |> Enum.each(fn {{stop_id, parent_id}, stop_sequence} ->
        parent = maybe_insert(:gtfs_stop, [id: parent_id], Arrow.Gtfs.Stop)
        stop = maybe_insert(:gtfs_stop, [id: stop_id, parent_station: parent], Arrow.Gtfs.Stop)

        insert(:gtfs_stop_time,
          trip: trip,
          stop_sequence: stop_sequence,
          stop: stop
        )
      end)
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

  # Stop sequence data was constructed with:
  #
  #     Arrow.Repo.all(
  #       from t in Arrow.Gtfs.Trip,
  #         # where: t.direction_id == 1,
  #         where: t.service_id == "canonical",
  #         where: t.route_id in ^route_ids,
  #         join: st in Arrow.Gtfs.StopTime,
  #         on: t.id == st.trip_id,
  #         join: s in Arrow.Gtfs.Stop,
  #         on: st.stop_id == s.id,
  #         join: ps in Arrow.Gtfs.Stop,
  #         on: ps.id == s.parent_station_id,
  #         order_by: [t.id, t.direction_id, st.stop_sequence],
  #         select: %{route_id: t.route_id, direction_id: t.direction_id, trip_id: t.id, stop_id: st.stop_id, parent_id: ps.id}
  #     )
  #     |> Stream.chunk_by(&{&1.direction_id, &1.trip_id})
  #     |> Enum.map(fn stops -> Enum.map(stops, &{&1.stop_id, &1.parent_id}) end)
  defp line_params("line-Blue") do
    %{
      line_id: "line-Blue",
      direction_descs: {"West", "East"},
      route_ids: ["Blue"],
      stop_sequences: [
        {
          [
            {"70059", "place-wondl"},
            {"70057", "place-rbmnl"},
            {"70055", "place-bmmnl"},
            {"70053", "place-sdmnl"},
            {"70051", "place-orhte"},
            {"70049", "place-wimnl"},
            {"70047", "place-aport"},
            {"70045", "place-mvbcl"},
            {"70043", "place-aqucl"},
            {"70041", "place-state"},
            {"70039", "place-gover"},
            {"70838", "place-bomnl"}
          ],
          [
            {"70038", "place-bomnl"},
            {"70040", "place-gover"},
            {"70042", "place-state"},
            {"70044", "place-aqucl"},
            {"70046", "place-mvbcl"},
            {"70048", "place-aport"},
            {"70050", "place-wimnl"},
            {"70052", "place-orhte"},
            {"70054", "place-sdmnl"},
            {"70056", "place-bmmnl"},
            {"70058", "place-rbmnl"},
            {"70060", "place-wondl"}
          ]
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
          [
            {"70036", "place-ogmnl"},
            {"70034", "place-mlmnl"},
            {"70032", "place-welln"},
            {"70278", "place-astao"},
            {"70030", "place-sull"},
            {"70028", "place-ccmnl"},
            {"70026", "place-north"},
            {"70024", "place-haecl"},
            {"70022", "place-state"},
            {"70020", "place-dwnxg"},
            {"70018", "place-chncl"},
            {"70016", "place-tumnl"},
            {"70014", "place-bbsta"},
            {"70012", "place-masta"},
            {"70010", "place-rugg"},
            {"70008", "place-rcmnl"},
            {"70006", "place-jaksn"},
            {"70004", "place-sbmnl"},
            {"70002", "place-grnst"},
            {"70001", "place-forhl"}
          ],
          [
            {"70001", "place-forhl"},
            {"70003", "place-grnst"},
            {"70005", "place-sbmnl"},
            {"70007", "place-jaksn"},
            {"70009", "place-rcmnl"},
            {"70011", "place-rugg"},
            {"70013", "place-masta"},
            {"70015", "place-bbsta"},
            {"70017", "place-tumnl"},
            {"70019", "place-chncl"},
            {"70021", "place-dwnxg"},
            {"70023", "place-state"},
            {"70025", "place-haecl"},
            {"70027", "place-north"},
            {"70029", "place-ccmnl"},
            {"70031", "place-sull"},
            {"70279", "place-astao"},
            {"70033", "place-welln"},
            {"70035", "place-mlmnl"},
            {"70036", "place-ogmnl"}
          ]
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
          [
            {"70061", "place-alfcl"},
            {"70063", "place-davis"},
            {"70065", "place-portr"},
            {"70067", "place-harsq"},
            {"70069", "place-cntsq"},
            {"70071", "place-knncl"},
            {"70073", "place-chmnl"},
            {"70075", "place-pktrm"},
            {"70077", "place-dwnxg"},
            {"70079", "place-sstat"},
            {"70081", "place-brdwy"},
            {"70083", "place-andrw"},
            {"70095", "place-jfk"},
            {"70097", "place-nqncy"},
            {"70099", "place-wlsta"},
            {"70101", "place-qnctr"},
            {"70103", "place-qamnl"},
            {"70105", "place-brntn"}
          ],
          [
            {"70105", "place-brntn"},
            {"70104", "place-qamnl"},
            {"70102", "place-qnctr"},
            {"70100", "place-wlsta"},
            {"70098", "place-nqncy"},
            {"70096", "place-jfk"},
            {"70084", "place-andrw"},
            {"70082", "place-brdwy"},
            {"70080", "place-sstat"},
            {"70078", "place-dwnxg"},
            {"70076", "place-pktrm"},
            {"70074", "place-chmnl"},
            {"70072", "place-knncl"},
            {"70070", "place-cntsq"},
            {"70068", "place-harsq"},
            {"70066", "place-portr"},
            {"70064", "place-davis"},
            {"70061", "place-alfcl"}
          ]
        },
        {
          [
            {"70061", "place-alfcl"},
            {"70063", "place-davis"},
            {"70065", "place-portr"},
            {"70067", "place-harsq"},
            {"70069", "place-cntsq"},
            {"70071", "place-knncl"},
            {"70073", "place-chmnl"},
            {"70075", "place-pktrm"},
            {"70077", "place-dwnxg"},
            {"70079", "place-sstat"},
            {"70081", "place-brdwy"},
            {"70083", "place-andrw"},
            {"70085", "place-jfk"},
            {"70087", "place-shmnl"},
            {"70089", "place-fldcr"},
            {"70091", "place-smmnl"},
            {"70093", "place-asmnl"}
          ],
          [
            {"70094", "place-asmnl"},
            {"70092", "place-smmnl"},
            {"70090", "place-fldcr"},
            {"70088", "place-shmnl"},
            {"70086", "place-jfk"},
            {"70084", "place-andrw"},
            {"70082", "place-brdwy"},
            {"70080", "place-sstat"},
            {"70078", "place-dwnxg"},
            {"70076", "place-pktrm"},
            {"70074", "place-chmnl"},
            {"70072", "place-knncl"},
            {"70070", "place-cntsq"},
            {"70068", "place-harsq"},
            {"70066", "place-portr"},
            {"70064", "place-davis"},
            {"70061", "place-alfcl"}
          ]
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
          [
            {"70202", "place-gover"},
            {"70196", "place-pktrm"},
            {"70159", "place-boyls"},
            {"70157", "place-armnl"},
            {"70155", "place-coecl"},
            {"70153", "place-hymnl"},
            {"71151", "place-kencl"},
            {"70149", "place-bland"},
            {"70147", "place-buest"},
            {"70145", "place-bucen"},
            {"170141", "place-amory"},
            {"170137", "place-babck"},
            {"70135", "place-brico"},
            {"70131", "place-harvd"},
            {"70129", "place-grigg"},
            {"70127", "place-alsgr"},
            {"70125", "place-wrnst"},
            {"70121", "place-wascm"},
            {"70117", "place-sthld"},
            {"70115", "place-chswk"},
            {"70113", "place-chill"},
            {"70111", "place-sougr"},
            {"70107", "place-lake"}
          ],
          [
            {"70106", "place-lake"},
            {"70110", "place-sougr"},
            {"70112", "place-chill"},
            {"70114", "place-chswk"},
            {"70116", "place-sthld"},
            {"70120", "place-wascm"},
            {"70124", "place-wrnst"},
            {"70126", "place-alsgr"},
            {"70128", "place-grigg"},
            {"70130", "place-harvd"},
            {"70134", "place-brico"},
            {"170136", "place-babck"},
            {"170140", "place-amory"},
            {"70144", "place-bucen"},
            {"70146", "place-buest"},
            {"70148", "place-bland"},
            {"71150", "place-kencl"},
            {"70152", "place-hymnl"},
            {"70154", "place-coecl"},
            {"70156", "place-armnl"},
            {"70158", "place-boyls"},
            {"70200", "place-pktrm"},
            {"70201", "place-gover"}
          ]
        },
        {
          [
            {"70202", "place-gover"},
            {"70197", "place-pktrm"},
            {"70159", "place-boyls"},
            {"70157", "place-armnl"},
            {"70155", "place-coecl"},
            {"70153", "place-hymnl"},
            {"70151", "place-kencl"},
            {"70211", "place-smary"},
            {"70213", "place-hwsst"},
            {"70215", "place-kntst"},
            {"70217", "place-stpul"},
            {"70219", "place-cool"},
            {"70223", "place-sumav"},
            {"70225", "place-bndhl"},
            {"70227", "place-fbkst"},
            {"70229", "place-bcnwa"},
            {"70231", "place-tapst"},
            {"70233", "place-denrd"},
            {"70235", "place-engav"},
            {"70237", "place-clmnl"}
          ],
          [
            {"70238", "place-clmnl"},
            {"70236", "place-engav"},
            {"70234", "place-denrd"},
            {"70232", "place-tapst"},
            {"70230", "place-bcnwa"},
            {"70228", "place-fbkst"},
            {"70226", "place-bndhl"},
            {"70224", "place-sumav"},
            {"70220", "place-cool"},
            {"70218", "place-stpul"},
            {"70216", "place-kntst"},
            {"70214", "place-hwsst"},
            {"70212", "place-smary"},
            {"70150", "place-kencl"},
            {"70152", "place-hymnl"},
            {"70154", "place-coecl"},
            {"70156", "place-armnl"},
            {"70158", "place-boyls"},
            {"70200", "place-pktrm"},
            {"70201", "place-gover"}
          ]
        },
        {
          [
            {"70504", "place-unsqu"},
            {"70502", "place-lech"},
            {"70208", "place-spmnl"},
            {"70206", "place-north"},
            {"70204", "place-haecl"},
            {"70202", "place-gover"},
            {"70198", "place-pktrm"},
            {"70159", "place-boyls"},
            {"70157", "place-armnl"},
            {"70155", "place-coecl"},
            {"70153", "place-hymnl"},
            {"70151", "place-kencl"},
            {"70187", "place-fenwy"},
            {"70183", "place-longw"},
            {"70181", "place-bvmnl"},
            {"70179", "place-brkhl"},
            {"70177", "place-bcnfd"},
            {"70175", "place-rsmnl"},
            {"70173", "place-chhil"},
            {"70171", "place-newto"},
            {"70169", "place-newtn"},
            {"70167", "place-eliot"},
            {"70165", "place-waban"},
            {"70163", "place-woodl"},
            {"70161", "place-river"}
          ],
          [
            {"70160", "place-river"},
            {"70162", "place-woodl"},
            {"70164", "place-waban"},
            {"70166", "place-eliot"},
            {"70168", "place-newtn"},
            {"70170", "place-newto"},
            {"70172", "place-chhil"},
            {"70174", "place-rsmnl"},
            {"70176", "place-bcnfd"},
            {"70178", "place-brkhl"},
            {"70180", "place-bvmnl"},
            {"70182", "place-longw"},
            {"70186", "place-fenwy"},
            {"70150", "place-kencl"},
            {"70152", "place-hymnl"},
            {"70154", "place-coecl"},
            {"70156", "place-armnl"},
            {"70158", "place-boyls"},
            {"70200", "place-pktrm"},
            {"70201", "place-gover"},
            {"70203", "place-haecl"},
            {"70205", "place-north"},
            {"70207", "place-spmnl"},
            {"70501", "place-lech"},
            {"70503", "place-unsqu"}
          ]
        },
        {
          [
            {"70512", "place-mdftf"},
            {"70510", "place-balsq"},
            {"70508", "place-mgngl"},
            {"70506", "place-gilmn"},
            {"70514", "place-esomr"},
            {"70502", "place-lech"},
            {"70208", "place-spmnl"},
            {"70206", "place-north"},
            {"70204", "place-haecl"},
            {"70202", "place-gover"},
            {"70199", "place-pktrm"},
            {"70159", "place-boyls"},
            {"70157", "place-armnl"},
            {"70155", "place-coecl"},
            {"70239", "place-prmnl"},
            {"70241", "place-symcl"},
            {"70243", "place-nuniv"},
            {"70245", "place-mfa"},
            {"70247", "place-lngmd"},
            {"70249", "place-brmnl"},
            {"70251", "place-fenwd"},
            {"70253", "place-mispk"},
            {"70255", "place-rvrwy"},
            {"70257", "place-bckhl"},
            {"70260", "place-hsmnl"}
          ],
          [
            {"70260", "place-hsmnl"},
            {"70258", "place-bckhl"},
            {"70256", "place-rvrwy"},
            {"70254", "place-mispk"},
            {"70252", "place-fenwd"},
            {"70250", "place-brmnl"},
            {"70248", "place-lngmd"},
            {"70246", "place-mfa"},
            {"70244", "place-nuniv"},
            {"70242", "place-symcl"},
            {"70240", "place-prmnl"},
            {"70154", "place-coecl"},
            {"70156", "place-armnl"},
            {"70158", "place-boyls"},
            {"70200", "place-pktrm"},
            {"70201", "place-gover"},
            {"70203", "place-haecl"},
            {"70205", "place-north"},
            {"70207", "place-spmnl"},
            {"70501", "place-lech"},
            {"70513", "place-esomr"},
            {"70505", "place-gilmn"},
            {"70507", "place-mgngl"},
            {"70509", "place-balsq"},
            {"70511", "place-mdftf"}
          ]
        }
      ]
    }
  end
end
