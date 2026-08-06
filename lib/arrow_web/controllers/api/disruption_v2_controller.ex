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
        left_join: replacement_service in assoc(d, :replacement_services),
        left_join: hastus in assoc(d, :hastus_exports),
        left_join: trainsformer in assoc(d, :trainsformer_exports),
        left_join: shuttle in assoc(replacement_service, :shuttle),
        left_join: route in assoc(shuttle, :routes),
        left_join: route_stops in assoc(route, :route_stops),
        left_join: shape in assoc(route, :shape),
        left_join: gtfs_stop in assoc(route_stops, :gtfs_stop),
        left_join: stop in assoc(route_stops, :stop),
        preload: [
          limits: limit,
          replacement_services:
            {replacement_service,
             [
               shuttle: {
                 shuttle,
                 [routes: {route, route_stops: {route_stops, [:gtfs_stop, :stop]}, shape: shape}]
               }
             ]},
          hastus_exports: hastus,
          trainsformer_exports: trainsformer
        ]
      )
      |> Arrow.Repo.one!()

    data = %{
      data
      | replacement_services:
          data.replacement_services |> Enum.map(&ReplacementService.add_timetable/1),
        hastus_exports:
          data.hastus_exports
          |> Enum.map(fn export ->
            {:ok, download_url} = Arrow.Hastus.export_download_url(export)
            download_url
          end),
        trainsformer_exports:
          data.trainsformer_exports
          |> Enum.map(fn export ->
            {:ok, download_url} = Arrow.Trainsformer.export_download_url(export)
            download_url
          end),
        shuttles: data.replacement_services |> Enum.map(& &1.shuttle)
    }

    render(conn, "index.json-api", data: data)
  end
end
