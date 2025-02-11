defmodule ArrowWeb.DisruptionV2Controller do
  use ArrowWeb, :controller

  alias ArrowWeb.Plug.Authorize
  alias Plug.Conn

  plug(Authorize, :view_disruption when action == :index)

  @spec index(Conn.t(), Conn.params()) :: Conn.t()
  def index(conn, _params) do
    render(conn, "index.html", user: conn.assigns.current_user)
  end
end
