defmodule ArrowWeb.PageController do
  use ArrowWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
