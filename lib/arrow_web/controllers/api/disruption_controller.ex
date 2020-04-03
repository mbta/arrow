defmodule ArrowWeb.API.DisruptionController do
  use ArrowWeb, :controller
  alias Arrow.{Repo, Disruption}
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

  @spec build_query([{String.t(), Date.t()}]) :: Ecto.Query.t()
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
    changeset = Disruption.changeset(%Disruption{}, attrs, adjustments)

    case Repo.insert(changeset) do
      {:ok, disruption} ->
        conn
        |> put_status(201)
        |> render("show.json-api", data: disruption)

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(:errors, data: changeset)
    end
  end

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
