defmodule ArrowWeb.API.ShapesController do
  use ArrowWeb, :controller

  alias Arrow.Shuttles

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    data = Shuttles.list_shapes()

    render(conn, "index.json-api", data: data)
  end
end
