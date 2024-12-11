defmodule ArrowWeb.API.ShuttleController do
  use ArrowWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias Arrow.Shuttles.Shuttle
  alias Arrow.Repo

  def index(conn, _params) do
    data =
      from(s in Shuttle,
        where: s.status == :active,
        join: r in assoc(s, :routes),
        join: rs in assoc(r, :route_stops),
        preload: [routes: {r, route_stops: rs}]
      )
      |> Repo.all()

    render(conn, "index.json-api", data: data)
  end
end
