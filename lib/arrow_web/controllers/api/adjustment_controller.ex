defmodule ArrowWeb.API.AdjustmentController do
  use ArrowWeb, :controller
  alias Arrow.{Repo, Adjustment}
  import Ecto.Query

  @filters ~w{route_id source}

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, params) do
    query = params |> take_filters |> format_filters |> build_query

    render(conn, "index.json-api", data: Repo.all(query))
  end

  @spec build_query([{String.t(), String.t()}]) :: Ecto.Query.t()
  defp build_query(filters) do
    Enum.reduce(filters, from(adj in Adjustment), &compose_query/2)
  end

  @spec compose_query({String.t(), String.t()}, Ecto.Query.t()) :: Ecto.Query.t()
  defp compose_query({"route_id", route_id}, query),
    do: from(d in query, where: d.route_id == ^route_id)

  defp compose_query({"source", source}, query),
    do: from(d in query, where: d.source == ^source)

  @spec take_filters(map()) :: map()
  defp take_filters(params) do
    Map.take(Map.get(params, "filter", %{}), @filters)
  end

  @spec format_filters(map()) :: [{String.t(), Date.t()}]
  defp format_filters(filters) do
    Enum.reduce(filters, [], fn filter, acc -> acc ++ do_format_filter(filter) end)
  end

  @spec do_format_filter({String.t(), String.t()}) :: [{String.t(), String.t()}]
  defp do_format_filter({filter, value})
       when filter in @filters do
    [{filter, value}]
  end

  defp do_format_filter(_), do: []
end
