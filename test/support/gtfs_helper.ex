defmodule Test.Support.GtfsHelper do
  @moduledoc """
  Helpers to insert valid, realistic GTFS data into the DB for test cases.
  """
  import Arrow.Factory
  import Ecto.Query

  @doc """
  Inserts data for a GTFS subway line (or lines) into the DB.

  To use in tests, call `setup {Test.Support.GtfsHelper, :insert_subway_line}` in the block
  where you'd like to use it.

  Then, annotate each test with the line to insert data for:

      @tag %{subway_line: "line-Orange"}
      test "function does something with Orange Line data" do
        ...
      end

  You can set up multiple lines with

      @tag %{subway_lines: [line1, line2, ...]}

  or disable this helper for a specific test with

      @tag skip_insert_subway_line: true
  """
  def insert_subway_line(%{skip_insert_subway_line: true}), do: :ok
  def insert_subway_line(%{subway_line: line_id}), do: do_insert_subway_line(line_params(line_id))

  def insert_subway_line(%{subway_lines: line_ids}) when is_list(line_ids) do
    for line_id <- line_ids do
      insert_subway_line(%{subway_line: line_id})
    end

    :ok
  end

  def insert_subway_line(_context) do
    raise "test context must contain one of the following keys: `:subway_line`, `:subway_lines`, `:skip_insert_subway_line`"
  end

  def do_insert_subway_line(context) do
    line = insert(:gtfs_line, id: context.line_id)
    service = insert(:gtfs_service, id: "canonical")

    true = tuple_size(context.direction_descs) == 2

    [context.route_ids, context.stop_sequences]
    |> Enum.zip()
    |> Enum.each(
      &insert_canonical(&1, line, service, context.direction_descs, context.parent_stations)
    )
  end

  defp insert_canonical(
         {route_id, {stop_sequence0, stop_sequence1}},
         line,
         service,
         {dir_desc0, dir_desc1},
         parent_stations
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
      parent_station_id = parent_stations[stop_id]

      if parent_station_id do
        maybe_insert(
          :gtfs_stop,
          [id: parent_station_id],
          Arrow.Gtfs.Stop
        )
      end

      stop =
        maybe_insert(
          :gtfs_stop,
          [id: stop_id, parent_station_id: parent_station_id],
          Arrow.Gtfs.Stop
        )

      insert(:gtfs_stop_time,
        trip: trip0,
        stop_sequence: stop_sequence,
        stop: stop
      )
    end)

    stop_sequence1
    |> Enum.with_index(1)
    |> Enum.each(fn {stop_id, stop_sequence} ->
      parent_station_id = parent_stations[stop_id]

      if parent_station_id do
        maybe_insert(
          :gtfs_stop,
          [id: parent_station_id],
          Arrow.Gtfs.Stop
        )
      end

      stop =
        maybe_insert(
          :gtfs_stop,
          [id: stop_id, parent_station_id: parent_station_id],
          Arrow.Gtfs.Stop
        )

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
      ],
      parent_stations: %{
        "70038" => "place-bomnl",
        "70039" => "place-gover",
        "70040" => "place-gover",
        "70041" => "place-state",
        "70042" => "place-state",
        "70043" => "place-aqucl",
        "70044" => "place-aqucl",
        "70045" => "place-mvbcl",
        "70046" => "place-mvbcl",
        "70047" => "place-aport",
        "70048" => "place-aport",
        "70049" => "place-wimnl",
        "70050" => "place-wimnl",
        "70051" => "place-orhte",
        "70052" => "place-orhte",
        "70053" => "place-sdmnl",
        "70054" => "place-sdmnl",
        "70055" => "place-bmmnl",
        "70056" => "place-bmmnl",
        "70057" => "place-rbmnl",
        "70058" => "place-rbmnl",
        "70059" => "place-wondl",
        "70060" => "place-wondl",
        "70838" => "place-bomnl"
      }
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
      ],
      parent_stations: %{
        "70025" => "place-haecl",
        "70027" => "place-north",
        "70001" => "place-forhl",
        "70029" => "place-ccmnl",
        "70015" => "place-bbsta",
        "70018" => "place-chncl",
        "70007" => "place-jaksn",
        "70005" => "place-sbmnl",
        "70003" => "place-grnst",
        "70035" => "place-mlmnl",
        "70023" => "place-state",
        "70021" => "place-dwnxg",
        "70028" => "place-ccmnl",
        "70036" => "place-ogmnl",
        "70019" => "place-chncl",
        "70010" => "place-rugg",
        "70012" => "place-masta",
        "70006" => "place-jaksn",
        "70031" => "place-sull",
        "70011" => "place-rugg",
        "70014" => "place-bbsta",
        "70278" => "place-astao",
        "70022" => "place-state",
        "70032" => "place-welln",
        "70016" => "place-tumnl",
        "70026" => "place-north",
        "70034" => "place-mlmnl",
        "70020" => "place-dwnxg",
        "70024" => "place-haecl",
        "70008" => "place-rcmnl",
        "70033" => "place-welln",
        "70002" => "place-grnst",
        "70017" => "place-tumnl",
        "70004" => "place-sbmnl",
        "70030" => "place-sull",
        "70009" => "place-rcmnl",
        "70013" => "place-masta",
        "70279" => "place-astao"
      }
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
      ],
      parent_stations: %{
        "70061" => "place-alfcl",
        "70083" => "place-andrw",
        "70084" => "place-andrw",
        "70093" => "place-asmnl",
        "70094" => "place-asmnl",
        "70081" => "place-brdwy",
        "70082" => "place-brdwy",
        "70105" => "place-brntn",
        "70073" => "place-chmnl",
        "70074" => "place-chmnl",
        "70069" => "place-cntsq",
        "70070" => "place-cntsq",
        "70063" => "place-davis",
        "70064" => "place-davis",
        "70077" => "place-dwnxg",
        "70078" => "place-dwnxg",
        "70089" => "place-fldcr",
        "70090" => "place-fldcr",
        "70067" => "place-harsq",
        "70068" => "place-harsq",
        "70085" => "place-jfk",
        "70086" => "place-jfk",
        "70095" => "place-jfk",
        "70096" => "place-jfk",
        "70071" => "place-knncl",
        "70072" => "place-knncl",
        "70097" => "place-nqncy",
        "70098" => "place-nqncy",
        "70075" => "place-pktrm",
        "70076" => "place-pktrm",
        "70065" => "place-portr",
        "70066" => "place-portr",
        "70103" => "place-qamnl",
        "70104" => "place-qamnl",
        "70101" => "place-qnctr",
        "70102" => "place-qnctr",
        "70087" => "place-shmnl",
        "70088" => "place-shmnl",
        "70091" => "place-smmnl",
        "70092" => "place-smmnl",
        "70079" => "place-sstat",
        "70080" => "place-sstat",
        "70099" => "place-wlsta",
        "70100" => "place-wlsta"
      }
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
      ],
      parent_stations: %{
        "70126" => "place-alsgr",
        "170140" => "place-amory",
        "70156" => "place-armnl",
        "70157" => "place-armnl",
        "170136" => "place-babck",
        "70509" => "place-balsq",
        "70510" => "place-balsq",
        "70257" => "place-bckhl",
        "70258" => "place-bckhl",
        "70176" => "place-bcnfd",
        "70177" => "place-bcnfd",
        "70229" => "place-bcnwa",
        "70230" => "place-bcnwa",
        "70148" => "place-bland",
        "70225" => "place-bndhl",
        "70226" => "place-bndhl",
        "70158" => "place-boyls",
        "70159" => "place-boyls",
        "70134" => "place-brico",
        "70178" => "place-brkhl",
        "70179" => "place-brkhl",
        "70249" => "place-brmnl",
        "70250" => "place-brmnl",
        "70144" => "place-bucen",
        "70146" => "place-buest",
        "70180" => "place-bvmnl",
        "70181" => "place-bvmnl",
        "70172" => "place-chhil",
        "70173" => "place-chhil",
        "70112" => "place-chill",
        "70114" => "place-chswk",
        "70237" => "place-clmnl",
        "70238" => "place-clmnl",
        "70154" => "place-coecl",
        "70155" => "place-coecl",
        "70219" => "place-cool",
        "70220" => "place-cool",
        "70233" => "place-denrd",
        "70234" => "place-denrd",
        "70166" => "place-eliot",
        "70167" => "place-eliot",
        "70235" => "place-engav",
        "70236" => "place-engav",
        "70513" => "place-esomr",
        "70514" => "place-esomr",
        "70227" => "place-fbkst",
        "70228" => "place-fbkst",
        "70251" => "place-fenwd",
        "70252" => "place-fenwd",
        "70186" => "place-fenwy",
        "70187" => "place-fenwy",
        "70505" => "place-gilmn",
        "70506" => "place-gilmn",
        "70201" => "place-gover",
        "70202" => "place-gover",
        "70128" => "place-grigg",
        "70203" => "place-haecl",
        "70204" => "place-haecl",
        "70130" => "place-harvd",
        "70260" => "place-hsmnl",
        "70213" => "place-hwsst",
        "70214" => "place-hwsst",
        "70152" => "place-hymnl",
        "70153" => "place-hymnl",
        "70150" => "place-kencl",
        "70151" => "place-kencl",
        "71150" => "place-kencl",
        "70215" => "place-kntst",
        "70216" => "place-kntst",
        "70106" => "place-lake",
        "70501" => "place-lech",
        "70502" => "place-lech",
        "70247" => "place-lngmd",
        "70248" => "place-lngmd",
        "70182" => "place-longw",
        "70183" => "place-longw",
        "70511" => "place-mdftf",
        "70512" => "place-mdftf",
        "70245" => "place-mfa",
        "70246" => "place-mfa",
        "70507" => "place-mgngl",
        "70508" => "place-mgngl",
        "70253" => "place-mispk",
        "70254" => "place-mispk",
        "70168" => "place-newtn",
        "70169" => "place-newtn",
        "70170" => "place-newto",
        "70171" => "place-newto",
        "70205" => "place-north",
        "70206" => "place-north",
        "70243" => "place-nuniv",
        "70244" => "place-nuniv",
        "70197" => "place-pktrm",
        "70198" => "place-pktrm",
        "70199" => "place-pktrm",
        "70200" => "place-pktrm",
        "70239" => "place-prmnl",
        "70240" => "place-prmnl",
        "70160" => "place-river",
        "70161" => "place-river",
        "70174" => "place-rsmnl",
        "70175" => "place-rsmnl",
        "70255" => "place-rvrwy",
        "70256" => "place-rvrwy",
        "70211" => "place-smary",
        "70212" => "place-smary",
        "70110" => "place-sougr",
        "70207" => "place-spmnl",
        "70208" => "place-spmnl",
        "70116" => "place-sthld",
        "70217" => "place-stpul",
        "70218" => "place-stpul",
        "70223" => "place-sumav",
        "70224" => "place-sumav",
        "70241" => "place-symcl",
        "70242" => "place-symcl",
        "70231" => "place-tapst",
        "70232" => "place-tapst",
        "70503" => "place-unsqu",
        "70504" => "place-unsqu",
        "70164" => "place-waban",
        "70165" => "place-waban",
        "70120" => "place-wascm",
        "70162" => "place-woodl",
        "70163" => "place-woodl",
        "70124" => "place-wrnst"
      }
    }
  end
end
