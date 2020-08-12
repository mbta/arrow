defmodule ArrowWeb.API.DisruptionController do
  use ArrowWeb, :controller
  alias Arrow.{Repo, Disruption}
  alias ArrowWeb.Utilities
  import Ecto.Query

  @filters ~w{min_start_date max_start_date min_end_date max_end_date}

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, params) do
    query = params |> take_filters |> format_filters |> build_query

    render(conn, "index.json-api",
      data:
        Repo.all(query)
        |> Repo.preload([:adjustments, :days_of_week, :exceptions, :trip_short_names]),
      opts: [include: Map.get(params, "include")]
    )
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, params) do
    render(conn, "index.json-api",
      data:
        Repo.get!(Disruption, params["id"])
        |> Repo.preload([:adjustments, :days_of_week, :exceptions, :trip_short_names]),
      opts: [include: Map.get(params, "include")]
    )
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
    {:ok, current_time} = DateTime.now(Application.get_env(:arrow, :time_zone))
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
    changeset = Disruption.Revision.changeset_for_create(attrs, adjustments, current_time)

    case Disruption.insert(changeset) do
      {:ok, revision} ->
        conn
        |> put_status(201)
        |> render("show.json-api", data: revision)

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(:errors, errors: Utilities.format_errors(changeset))
    end
  end

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, %{"id" => id} = params) do
    disruption =
      Repo.get!(Disruption, id)
      |> Repo.preload(
        latest_revision: [:adjustments, :days_of_week, :exceptions, :trip_short_names]
      )

    {:ok, current_time} = DateTime.now(Application.get_env(:arrow, :time_zone))
    params_data = Map.get(params, "data", %{})
    params_relationships = Map.get(params_data, "relationships", %{})

    relationships = ArrowWeb.Utilities.get_json_api_relationships(params_relationships)
    attrs = JaSerializer.Params.to_attributes(params_data)
    attrs = Map.merge(attrs, relationships)

    changeset =
      Disruption.Revision.changeset_for_update(disruption.latest_revision, attrs, current_time)

    case Disruption.update(changeset) do
      {:ok, revision} ->
        conn
        |> put_status(200)
        |> render("show.json-api", data: revision)

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(:errors, errors: Utilities.format_errors(changeset))
    end
  end

  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    {:ok, current_time} = DateTime.now(Application.get_env(:arrow, :time_zone))

    disruption = Repo.get!(Disruption, id) |> Repo.preload(:latest_revision)
    changeset = Disruption.Revision.changeset_for_delete(disruption.latest_revision, current_time)

    case Disruption.delete(changeset) do
      {:ok, _revision} ->
        send_resp(conn, 204, "")

      {:error, changeset} ->
        conn |> put_status(400) |> render(:errors, errors: Utilities.format_errors(changeset))
    end
  end

  @spec build_query([{String.t(), Date.t()}]) :: Ecto.Query.t()
  defp build_query(filters) do
    Enum.reduce(filters, from(d in Disruption), &compose_query/2)
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
end
