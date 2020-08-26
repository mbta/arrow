defmodule ArrowWeb.API.DisruptionController do
  use ArrowWeb, :controller
  alias Arrow.{Repo, Disruption, DisruptionRevision}
  alias ArrowWeb.Utilities
  import Ecto.Query

  @filters ~w{min_start_date max_start_date min_end_date max_end_date}

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, params) do
    query =
      params
      |> take_filters
      |> format_filters
      |> build_query

    case do_only_published_query(query, params) do
      {:ok, query} ->
        data =
          query
          |> Repo.all()
          |> Repo.preload([:adjustments, :days_of_week, :exceptions, :trip_short_names])

        render(conn, "index.json-api",
          data: data,
          opts: [include: Map.get(params, "include")]
        )

      :error ->
        conn |> put_status(400) |> render(:errors, errors: [%{detail: "Invalid request"}])
    end
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, params) do
    case do_only_published_query(DisruptionRevision, params) do
      {:ok, dr_query} ->
        disruption_revision =
          dr_query
          |> Repo.get_by!(disruption_id: params["id"])
          |> Repo.preload([:adjustments, :days_of_week, :exceptions, :trip_short_names])

        render(conn, "index.json-api",
          data: disruption_revision,
          opts: [include: Map.get(params, "include")]
        )

      :error ->
        conn |> put_status(400) |> render(:errors, errors: [%{detail: "Invalid request"}])
    end
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
      {:ok, disruption_revision} ->
        data =
          Repo.preload(disruption_revision, [
            :adjustments,
            :days_of_week,
            :exceptions,
            :trip_short_names
          ])

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
      |> DisruptionRevision.only_published()
      |> Repo.get_by!(disruption_id: params["id"])

    case Disruption.update(disruption_revision.id, attrs) do
      {:ok, disruption_revision} ->
        conn
        |> put_status(200)
        |> render("show.json-api", data: disruption_revision)

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

  @spec build_query([{String.t(), Date.t()}]) :: Ecto.Query.t()
  defp build_query(filters) do
    query = from(d in DisruptionRevision)
    Enum.reduce(filters, query, &compose_query/2)
  end

  @spec compose_query({String.t(), Date.t()}, Ecto.Query.t()) :: Ecto.Query.t()
  defp compose_query({"min_start_date", date}, query),
    do: from(d in query, where: d.start_date >= ^date)

  defp compose_query({"min_end_date", date}, query),
    do: from(d in query, where: d.end_date >= ^date)

  defp compose_query({"max_start_date", date}, query),
    do: from(d in query, where: d.start_date <= ^date)

  defp compose_query({"max_end_date", date}, query),
    do: from(d in query, where: d.end_date <= ^date)

  @spec take_filters(map()) :: map()
  defp take_filters(params) do
    Map.take(Map.get(params, "filter", %{}), @filters)
  end

  @spec format_filters(map()) :: [{String.t(), Date.t()}]
  defp format_filters(filters) do
    Enum.reduce(filters, [], fn filter, acc -> acc ++ do_format_filter(filter) end)
  end

  @spec do_format_filter({String.t(), String.t()}) :: [{String.t(), Date.t()}]
  defp do_format_filter({filter, value})
       when filter in @filters do
    case Date.from_iso8601(value) do
      {:ok, date} ->
        [{filter, date}]

      {:error, _} ->
        []
    end
  end

  defp do_format_filter(_), do: []

  @spec do_only_published_query(Ecto.Queryable.t(), map()) :: {:ok, Ecto.Query.t()} | :error
  defp do_only_published_query(q, params) do
    case Map.get(params, "only_published") do
      "true" -> {:ok, DisruptionRevision.only_published(q)}
      val when val in [nil, "", "false"] -> {:ok, DisruptionRevision.latest_revision(q)}
      _ -> :error
    end
  end
end
