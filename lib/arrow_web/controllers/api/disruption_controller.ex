defmodule ArrowWeb.API.DisruptionController do
  use ArrowWeb, :controller
  import Ecto.Query
  alias Arrow.{Disruption, DisruptionRevision, Repo}
  alias ArrowWeb.API.Util

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, params) do
    with {:ok, start_date} <- parse_date_param(params, "start_date"),
         {:ok, end_date} <- parse_date_param(params, "end_date"),
         :ok <- Util.validate_date_order(start_date, end_date) do
      data =
        from(d in Disruption,
          join: dr in assoc(d, :revisions),
          order_by: [d.id, dr.id],
          where: dr.id >= d.published_revision_id or is_nil(d.published_revision_id),
          where: dr.is_active,
          where: dr.start_date <= ^end_date and dr.end_date >= ^start_date,
          preload: [revisions: {dr, ^DisruptionRevision.associations()}]
        )
        |> Repo.all()

      render(conn, "index.json-api", data: data)
    else
      {:error, :invalid_date_order} ->
        conn
        |> put_status(409)
        |> json(%{error: "`end_date` must be after `start_date`"})

      {{:error, :invalid_date}, name} ->
        conn
        |> put_status(400)
        |> json(%{error: "`#{name}` is not a valid date"})
    end
  end

  defp parse_date_param(params, name) do
    case Util.parse_date(Map.get(params, name)) do
      {:ok, date} ->
        {:ok, date}

      error ->
        {error, name}
    end
  end
end
