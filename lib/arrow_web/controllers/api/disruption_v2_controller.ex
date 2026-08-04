defmodule ArrowWeb.API.DisruptionV2Controller do
  use ArrowWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias Arrow.Repo
  alias Arrow.Disruptions.DisruptionV2
  alias Plug.Conn

  @spec index(Conn.t(), map()) :: Conn.t()
  def index(conn, %{"id" => id}) do
    data =
      from(d in DisruptionV2,
        where: d.id == ^id,
        left_join: l in assoc(d, :limits),
        left_join: rs in assoc(d, :replacement_services),
        left_join: he in assoc(d, :hastus_exports),
        left_join: te in assoc(d, :trainsformer_exports),
        left_join: sh in assoc(rs, :shuttle),
        preload: [
          limits: l,
          replacement_services: {rs, [shuttle: sh]},
          hastus_exports: he,
          trainsformer_exports: te,
          shuttles: sh
        ]
      )
      |> Repo.one!()

    render(conn, "index.json-api", data: data)
  end
end
