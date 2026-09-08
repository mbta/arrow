defmodule ArrowWeb.API.ShuttleController do
  use ArrowWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias Arrow.Repo
  alias Arrow.Shuttles.{Route, RouteStop, Shuttle}
  alias Plug.Conn

  @spec index(Conn.t(), map()) :: Conn.t()
  def index(conn, _params) do
    data =
      from(s in Shuttle,
        where: s.status == :active,
        join: r in assoc(s, :routes),
        join: rs in assoc(r, :route_stops),
        join: sh in assoc(r, :shape),
        left_join: gs in assoc(rs, :gtfs_stop),
        left_join: st in assoc(rs, :stop),
        preload: [routes: {r, route_stops: {rs, [:gtfs_stop, :stop]}, shape: sh}]
      )
      |> Repo.all()

    render(conn, "index.json-api", data: data)
  end

  @spec get(Conn.t(), map()) :: Conn.t()
  def get(conn, %{"id" => id}) do
    data =
      from(s in Shuttle,
        where: s.id == ^id,
        preload: [routes: [:shape, route_stops: [:gtfs_stop, :stop]]]
      )
      |> Repo.one!()
      |> update_in([Access.key(:routes), Access.all()], &shuttle_route_data/1)
      |> Map.take([:shuttle_name, :status, :suffix, :disrupted_route_id, :routes])

    json(conn, data)
  end

  defp shuttle_route_data(%Route{} = route) do
    route
    |> update_in([Access.key(:route_stops), Access.all()], &route_stop_data/1)
    |> Map.take([
      :destination,
      :direction_id,
      :direction_desc,
      :waypoint,
      :route_stops
    ])
    |> Map.merge(%{
      shape_id: route.shape.name,
      shape_uri: Arrow.Shuttles.Route.get_shape_uri(route.shape)
    })
  end

  defp route_stop_data(%RouteStop{} = route_stop) do
    route_stop
    |> Map.take([:direction_id, :stop_sequence, :time_to_next_stop])
    |> Map.put(:stop_id, route_stop.gtfs_stop_id || route_stop.stop.stop_id)
  end
end
