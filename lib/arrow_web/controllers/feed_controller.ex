defmodule ArrowWeb.FeedController do
  use ArrowWeb, :controller

  plug(ArrowWeb.Plug.Authorize, :view_change_feed)

  @spec index(Plug.Conn.t(), Plug.Conn.params()) :: Plug.Conn.t()
  def index(conn, _params) do
    disruptions = Arrow.Disruption.latest_vs_published()

    render(conn, "index.html", disruptions: disruptions)
  end
end
