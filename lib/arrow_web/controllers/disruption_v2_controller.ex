defmodule ArrowWeb.DisruptionV2Controller do
  use ArrowWeb, :controller

  alias Arrow.Disruptions
  alias ArrowWeb.DisruptionV2Controller.Filters
  alias ArrowWeb.Plug.Authorize
  alias Plug.Conn

  plug(Authorize, :view_disruption when action == :index)

  @spec index(Conn.t(), Conn.params()) :: Conn.t()
  def index(conn, params) do
    filters = Filters.from_params(params)

    render(conn, "index.html",
      user: conn.assigns.current_user,
      disruptions: Disruptions.list_disruptionsv2(),
      filters: filters
    )
  end
end
