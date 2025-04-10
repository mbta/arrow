defmodule ArrowWeb.ShuttleController do
  use ArrowWeb, :controller

  alias Arrow.Shuttles

  def index(conn, _params) do
    shuttles = Shuttles.list_shuttles()
    render(conn, :index, shuttles: shuttles)
  end
end
