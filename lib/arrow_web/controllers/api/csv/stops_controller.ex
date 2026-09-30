defmodule ArrowWeb.API.CSV.StopsController do
  use ArrowWeb, :controller
  alias Arrow.Stops

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    render(conn, :index, stops: Stops.list_stops())
  end
end
