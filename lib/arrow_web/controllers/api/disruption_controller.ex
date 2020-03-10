defmodule ArrowWeb.API.DisruptionController do
  use ArrowWeb, :controller
  alias Arrow.{Repo, Disruption}
  import Ecto.Query

  @filters ~w{min_start_date max_start_date min_end_date max_end_date}

  def index(conn, params) do
    query = params |> take_filters |> format_filters |> build_query

    render(conn, "index.json-api",
      data:
        Repo.all(query)
        |> Repo.preload([:adjustments, :days_of_week, :exceptions, :trip_short_names]),
      opts: [include: Map.get(params, "include")]
    )
  end

  defp build_query(filters) do
    Enum.reduce(filters, from(d in Disruption), &compose_query/2)
  end

  defp compose_query({"min_start_date", date}, query),
    do: from(d in query, where: d.start_date >= ^date)

  defp compose_query({"min_end_date", date}, query),
    do: from(d in query, where: d.end_date >= ^date)

  defp compose_query({"max_start_date", date}, query),
    do: from(d in query, where: d.start_date <= ^date)

  defp compose_query({"max_end_date", date}, query),
    do: from(d in query, where: d.end_date <= ^date)

  defp take_filters(params) do
    Map.take(Map.get(params, "filter", %{}), @filters)
  end

  defp format_filters(filters) do
    Enum.reduce(filters, [], fn filter, acc -> acc ++ do_format_filter(filter) end)
  end

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
