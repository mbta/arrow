defmodule ArrowWeb.TempReviewChangesController do
  use ArrowWeb, :controller

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    render(conn, "index.html")
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, _params) do
    :ok = Arrow.DisruptionRevision.ready_all!()

    redirect(conn, to: ArrowWeb.Router.Helpers.disruption_path(conn, :index))
  end
end
