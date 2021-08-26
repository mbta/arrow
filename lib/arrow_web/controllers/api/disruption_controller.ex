defmodule ArrowWeb.API.DisruptionController do
  use ArrowWeb, :controller
  alias Arrow.{Disruption, DisruptionRevision, Repo}
  import Ecto.Query

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    data =
      from(d in Disruption,
        join: dr in assoc(d, :revisions),
        order_by: [d.id, dr.id],
        where: dr.id >= d.published_revision_id or is_nil(d.published_revision_id),
        preload: [revisions: {dr, ^DisruptionRevision.associations()}]
      )
      |> Repo.all()

    render(conn, "index.json-api", data: data)
  end
end
