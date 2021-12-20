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

  @empty_set MapSet.new()

  defp apply_filter({:kinds, kinds}, query) when kinds != @empty_set do
    kinds_list = kinds |> expand_kinds_filter() |> MapSet.to_list()

    condition =
      kinds_list
      |> Enum.map(&Adjustment.kind_is/1)
      |> Enum.reduce(dynamic(false), &dynamic([adjustments: a], ^&2 or ^&1))
      |> then(&dynamic([revisions: r], ^&1 or r.adjustment_kind in ^kinds_list))

    from query, where: ^condition
  end

  defp apply_filter({:kinds, kinds}, query) when kinds == @empty_set, do: query

  defp apply_filter({:only_approved?, true}, query) do
    from [revisions: r] in query, where: r.row_approved
  end

  defp apply_filter({:only_approved?, false}, query), do: query

  defp apply_filter({:search, search}, query) when is_binary(search) do
    from [adjustments: a] in query, where: ilike(a.source_label, ^"%#{search}%")
  end

  defp apply_filter({:search, nil}, query), do: query

  defp apply_filter({:sort, {direction, :id}}, query) do
    from [disruptions: d] in query, order_by: {^direction, d.id}
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

  @green_line_branch_kinds ~w(green_line_b green_line_c green_line_d green_line_e)a

  # When `green_line` is used as a kind filter, in addition to taking it literally, include all
  # kinds that refer to specific Green Line branches
  defp expand_kinds_filter(kinds) do
    if :green_line in kinds,
      do: MapSet.union(kinds, MapSet.new(@green_line_branch_kinds)),
      else: kinds
  end
end
