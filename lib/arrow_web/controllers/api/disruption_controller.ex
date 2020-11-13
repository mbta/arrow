defmodule ArrowWeb.API.DisruptionController do
  use ArrowWeb, :controller
  alias Arrow.{Repo, Disruption, DisruptionRevision}
  alias ArrowWeb.Utilities
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

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, params) do
    disruption_id = params["id"]

    data =
      from(d in Disruption,
        join: dr in assoc(d, :revisions),
        order_by: [d.id, dr.id],
        where:
          d.id == ^disruption_id and
            (dr.id >= d.published_revision_id or is_nil(d.published_revision_id)),
        preload: [revisions: {dr, ^DisruptionRevision.associations()}]
      )
      |> Repo.one!()

    render(conn, "show.json-api", data: data)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
    params_data = Map.get(params, "data", %{})
    params_relationships = Map.get(params_data, "relationships", %{})

    relationships = ArrowWeb.Utilities.get_json_api_relationships(params_relationships)
    attrs = JaSerializer.Params.to_attributes(params_data)

    adjustment_labels =
      relationships
      |> Map.get("adjustments", [])
      |> Enum.map(& &1["source_label"])

    adjustments =
      Repo.all(from adj in Arrow.Adjustment, where: adj.source_label in ^adjustment_labels)

    attrs = Map.merge(attrs, relationships)

    case Disruption.create(attrs, adjustments) do
      {:ok, disruption} ->
        data = Repo.preload(disruption, revisions: DisruptionRevision.associations())

        conn
        |> put_status(201)
        |> render("show.json-api", data: data)

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(:errors, errors: Utilities.format_errors(changeset))
    end
  end

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, params) do
    params_data = Map.get(params, "data", %{})
    params_relationships = Map.get(params_data, "relationships", %{})

    relationships = ArrowWeb.Utilities.get_json_api_relationships(params_relationships)
    attrs = JaSerializer.Params.to_attributes(params_data)

    attrs = Map.merge(attrs, relationships)

    disruption_revision =
      DisruptionRevision
      |> DisruptionRevision.latest_revision()
      |> Repo.get_by!(disruption_id: params["id"])

    case Disruption.update(disruption_revision.id, attrs) do
      {:ok, disruption} ->
        data = Repo.preload(disruption, revisions: DisruptionRevision.associations())

        conn
        |> put_status(200)
        |> render("show.json-api", data: data)

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(:errors, errors: Utilities.format_errors(changeset))
    end
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    disruption_revision =
      DisruptionRevision
      |> DisruptionRevision.latest_revision()
      |> Repo.get_by(disruption_id: id)

    if is_nil(disruption_revision) do
      conn |> put_status(404) |> render(:errors, errors: [%{detail: "Not found"}])
    else
      {:ok, _disruption} = Disruption.delete(disruption_revision.id)

      send_resp(conn, 204, "")
    end
  end
end
