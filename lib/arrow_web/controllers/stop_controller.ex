defmodule ArrowWeb.StopController do
  use ArrowWeb, :controller

  alias Arrow.Stops
  alias Plug.Conn

  @spec index(Conn.t(), Conn.params()) :: Conn.t()
  def index(conn, _params) do
    stops = Stops.list_stops()
    render(conn, :index, stops: stops)
  end
end
