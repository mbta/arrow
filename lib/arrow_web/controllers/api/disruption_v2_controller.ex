defmodule ArrowWeb.API.DisruptionV2Controller do
  use ArrowWeb, :controller
  alias Arrow.Disruptions
  alias ArrowWeb.Plug.Authorize

  plug(Authorize, :view_disruption when action in [:show])

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    data = Disruptions.get_disruption_v2!(id)
    json(conn, data)
  end
end
