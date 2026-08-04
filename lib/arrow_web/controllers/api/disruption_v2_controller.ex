defmodule ArrowWeb.API.DisruptionV2Controller do
  use ArrowWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias Arrow.Disruptions.DisruptionV2
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
          replacement_services: {replacement_service, [shuttle: shuttle]},
          hastus_exports: hastus,
          trainsformer_exports: trainsformer,
          shuttles: {
            shuttle,
            [routes: {route, route_stops: {route_stops, [:gtfs_stop, :stop]}, shape: shape}]
          }
        ]
      )
      |> Arrow.Repo.one!()

    render(conn, "index.json-api", data: data)
  end
end
