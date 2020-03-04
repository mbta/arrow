defmodule ArrowWeb.DisruptionApiController do
  use ArrowWeb, :controller
  alias Arrow.{Repo, Disruption}

  def index(conn, params) do
    render(conn, "index.json-api",
      data: Repo.all(Disruption),
      opts: [include: Map.get(params, "include"), fields: Map.get(params, "fields")]
    )
  end
end
