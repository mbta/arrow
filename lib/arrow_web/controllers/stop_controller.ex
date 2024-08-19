defmodule ArrowWeb.StopController do
  use ArrowWeb, :controller

  alias Arrow.Stops
  alias Plug.Conn

  @spec index(Conn.t(), Conn.params()) :: Conn.t()
  def index(conn, params) do
    stops = Stops.list_stops(params)
    render(conn, :index, stops: stops, order_by: Map.get(params, "order_by"))
  end
end
