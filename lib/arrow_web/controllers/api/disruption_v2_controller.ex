defmodule ArrowWeb.API.DisruptionV2Controller do
  use ArrowWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias Arrow.Disruptions.{DisruptionV2, ReplacementService}
  alias Plug.Conn

  @spec index(Conn.t(), map()) :: Conn.t()
  def index(conn, %{"id" => id}) do
    data =
      from(d in DisruptionV2,
        where: d.id == ^id,
        left_join: limit in assoc(d, :limits),
        preload: [
          :hastus_exports,
          :trainsformer_exports,
          limits:
            {limit,
             [
               :route,
               :start_stop,
               :end_stop,
               limit_day_of_weeks: :limit,
               disruption: d
             ]},
          replacement_services: [
            shuttle: [routes: [:shape, route_stops: [:gtfs_stop, :stop]]]
          ]
        ]
      )
      |> Arrow.Repo.one!()

    data = %{
      data
      | replacement_services:
          Enum.map(data.replacement_services, &ReplacementService.add_timetable/1),
        hastus_exports: Enum.map(data.hastus_exports, & &1.s3_path),
        trainsformer_exports: Enum.map(data.trainsformer_exports, & &1.s3_path),
        shuttles: Enum.map(data.replacement_services, & &1.shuttle)
    }

    render(conn, "index.json-api", data: data)
  end
end
