defmodule ArrowWeb.API.ShuttleController do
  use ArrowWeb, :controller
  import Ecto.Query, only: [from: 2, subquery: 1]

  alias Arrow.Repo
  alias Arrow.Shuttles.Shuttle
  alias Arrow.Disruptions.ReplacementService
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

  def unscheduled(conn, _params) do
    today = Date.utc_today()

    shuttles_with_replacement_service =
      from(r in ReplacementService,
        where: r.end_date >= ^today,
        join: s in assoc(r, :shuttle),
        select: s
      )

    data =
      from(s in Shuttle,
        as: :shuttle,
        distinct: s.id,
        where:
          s.status == :active and
            not exists(subquery(shuttles_with_replacement_service)),
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
end
