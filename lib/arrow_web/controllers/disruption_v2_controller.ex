defmodule ArrowWeb.DisruptionV2Controller do
  use ArrowWeb, :controller

  alias ArrowWeb.DisruptionV2Controller.{Filters, Index}
  alias ArrowWeb.Plug.Authorize
  alias Plug.Conn

  plug(Authorize, :view_disruption when action == :index)

  @spec index(Conn.t(), Conn.params()) :: Conn.t()
  def index(conn, params) do
    filters = Filters.from_params(params)

    disruptions = Index.all(filters)

    render(conn, "index.html",
      user: conn.assigns.current_user,
      disruptions: disruptions,
      filters: filters
    )
  end
end
