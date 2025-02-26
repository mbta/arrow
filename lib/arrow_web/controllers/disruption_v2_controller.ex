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

    disruptions = Filters.apply_to_disruptions(Disruptions.list_disruptionsv2(), filters)

    render(conn, "index.html",
      user: conn.assigns.current_user,
      disruptions: disruptions,
      filters: filters
    )
  end
end
