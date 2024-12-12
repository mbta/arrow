defmodule ArrowWeb.API.ShuttleController do
  use ArrowWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias Arrow.Repo
  alias Arrow.Shuttles.Shuttle
  alias Plug.Conn

  @spec index(Conn.t(), map()) :: Conn.t()
  def index(conn, _params) do
    data =
      from(s in Shuttle,
        where: s.status == :active,
        join: r in assoc(s, :routes),
        join: rs in assoc(r, :route_stops),
        left_join: gs in assoc(rs, :gtfs_stop),
        left_join: st in assoc(rs, :stop),
        preload: [routes: {r, route_stops: {rs, [:gtfs_stop, :stop]}}]
      )
      |> Repo.all()

    render(conn, "index.json-api", data: data)
  end
end
