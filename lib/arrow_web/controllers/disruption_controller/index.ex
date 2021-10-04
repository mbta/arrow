defmodule ArrowWeb.DisruptionController.Index do
  @moduledoc """
  Builds and executes the database queries for the disruptions index.
  """

  alias Arrow.{Adjustment, Disruption, Repo}
  alias ArrowWeb.DisruptionController.Filters
  import Ecto.Query

  @spec all(Filters.t() | nil) :: [Disruption.t()]
  def all(filters \\ nil), do: base_query() |> apply_filters(filters) |> Repo.all()

  defp apply_filter({:include_past?, false}, query) do
    cutoff = Date.utc_today() |> Date.add(-7)
    from [revisions: r] in query, where: is_nil(r.end_date) or r.end_date > ^cutoff
  end

  defp apply_filter({:include_past?, true}, query), do: query

  defp apply_filter({:only_approved?, true}, query) do
    from [revisions: r] in query, where: r.row_approved
  end

  defp apply_filter({:only_approved?, false}, query), do: query

  @empty_set MapSet.new()

  defp apply_filter({:routes, routes}, query) when routes != @empty_set do
    condition =
      Enum.reduce(routes, dynamic(false), fn
        "Commuter", dynamic -> dynamic([adjustments: a], ^dynamic or ilike(a.route_id, "CR%"))
        other, dynamic -> dynamic([adjustments: a], ^dynamic or a.route_id == ^other)
      end)

    from [adjustments: a] in query, where: ^condition
  end

  defp apply_filter({:routes, routes}, query) when routes == @empty_set, do: query

  defp apply_filter({:search, search}, query) when is_binary(search) do
    from [adjustments: a] in query, where: ilike(a.source_label, ^"%#{search}%")
  end

  defp apply_filter({:search, nil}, query), do: query

  defp apply_filter({:sort, {direction, :id}}, query) do
    from [disruptions: d] in query, order_by: {^direction, d.id}
  end

  defp apply_filter({:sort, {direction, :source_label}}, query) do
    from [adjustments: a] in query, order_by: {^direction, a.source_label}
  end

  defp apply_filter({:sort, {direction, :start_date}}, query) do
    from [revisions: r] in query, order_by: {^direction, r.start_date}
  end

  defp apply_filters(query, nil), do: query

  defp apply_filters(query, filters) do
    filters |> Filters.flatten() |> Enum.reduce(query, &apply_filter/2)
  end

  defp base_query do
    from [disruptions: d, revisions: r] in Disruption.with_latest_revisions(),
      where: r.is_active == true,
      left_join: a in assoc(r, :adjustments),
      as: :adjustments,
      preload: [
        revisions:
          {r,
           [
             {:adjustments, ^from(a in Adjustment, order_by: :source_label)},
             :days_of_week,
             :exceptions
           ]}
      ]
  end
end
