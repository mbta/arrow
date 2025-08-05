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
