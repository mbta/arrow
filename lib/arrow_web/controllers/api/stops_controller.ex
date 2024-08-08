defmodule ArrowWeb.API.StopsController do
  use ArrowWeb, :controller
  alias Arrow.Stops

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    data = Stops.list_stops()

    render(conn, "index.json-api", data: data)
  end
end
