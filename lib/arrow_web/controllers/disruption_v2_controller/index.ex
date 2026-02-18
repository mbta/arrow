defmodule ArrowWeb.DisruptionV2Controller.Index do
  @moduledoc """
  Applies filters on disruptions for index view
  """

  alias Arrow.Disruptions
  alias Arrow.Disruptions.DisruptionV2
  alias ArrowWeb.DisruptionV2Controller.Filters
  alias ArrowWeb.DisruptionV2Controller.Filters.Calendar
  alias ArrowWeb.DisruptionV2Controller.Filters.Table

  @disruption_kind_routes %{
    blue_line: ["Blue"],
    orange_line: ["Orange"],
    red_line: ["Red"],
    mattapan_line: ["Mattapan"],
    green_line: ["Green-B", "Green-C", "Green-D", "Green-E"],
    green_line_b: ["Green-B"],
    green_line_c: ["Green-C"],
    green_line_d: ["Green-D"],
    green_line_e: ["Green-E"]
  }

  @empty_set MapSet.new()

  @spec all(Filters.t() | nil) :: [DisruptionV2.t()]
  def all(filters),
    do: apply_to_disruptions(Disruptions.list_disruptionsv2(), filters)

  @spec apply_to_disruptions([DisruptionV2.t()], Filters.t()) :: [DisruptionV2.t()]
  def apply_to_disruptions(disruptions, filters) do
    disruptions
    |> Enum.filter(&accept?(&1, filters))
    |> sort(filters)
  end

  defp accept?(disruption, filters) do
    apply_kinds_filter(disruption, filters) and apply_only_approved_filter(disruption, filters) and
      apply_only_archived_filter(disruption, filters) and apply_past_filter(disruption, filters) and
      apply_search_filter(disruption, filters)
  end

  defp sort(disruptions, %Filters{view: %Table{sort: sort_state, active_sort: sort_field}}) do
    do_sort(disruptions, Map.fetch!(sort_state, sort_field), sort_field)
  end

  defp sort(disruptions, %Filters{view: %Calendar{}}), do: disruptions

  defp do_sort(disruptions, direction, :start_date) do
    Enum.sort_by(
      disruptions,
      fn disruption ->
        {start_date, _} = Disruptions.start_end_dates(disruption)
        start_date || ~D[0000-01-01]
      end,
      {direction, Date}
    )
  end

  defp do_sort(disruptions, direction, :end_date) do
    Enum.sort_by(
      disruptions,
      fn disruption ->
        {_, end_date} = Disruptions.start_end_dates(disruption)
        end_date || ~D[9999-12-31]
      end,
      {direction, Date}
    )
  end

  defp apply_kinds_filter(_disruption, %Filters{kinds: kinds}) when kinds == @empty_set,
    do: true

  defp apply_kinds_filter(disruption, %Filters{kinds: kinds}) do
    kind_routes = kinds |> Enum.map(&@disruption_kind_routes[&1]) |> List.flatten()

    Enum.any?(disruption.limits, fn limit -> limit.route.id in kind_routes end)
  end

  defp apply_only_approved_filter(disruption, %Filters{only_approved?: true}),
    do: disruption.status == :approved

  defp apply_only_approved_filter(_disruption, %Filters{only_approved?: false}),
    do: true

  defp apply_only_archived_filter(disruption, %Filters{only_archived?: true}),
    do: disruption.status == :archived

  # Do NOT show archived disruptions if the only_archived filter is off.
  defp apply_only_archived_filter(disruption, %Filters{only_archived?: false}),
    do: disruption.status != :archived

  defp apply_past_filter(disruption, %Filters{view: %Table{include_past?: false}}) do
    cutoff = Date.utc_today() |> Date.add(-7)

    {_start_date, end_date} = Disruptions.start_end_dates(disruption)

    is_nil(end_date) or Date.after?(end_date, cutoff)
  end

  defp apply_past_filter(_disruption, _filter), do: true

  defp apply_search_filter(_disruption, %Filters{search: nil}), do: true

  defp apply_search_filter(%DisruptionV2{} = disruption, %Filters{search: search}) do
    title_contains?(disruption, search) or
      limits_contains?(disruption, search) or
      replacement_services_contains?(disruption, search)
  end

  defp title_contains?(disruption, search) do
    string_contains?(disruption.title, search)
  end

  defp limits_contains?(%DisruptionV2{limits: limits}, search) do
    Enum.any?(limits, fn limit ->
      string_contains?(limit.start_stop.name, search) ||
        string_contains?(limit.end_stop.name, search)
    end)
  end

  defp replacement_services_contains?(
         %DisruptionV2{replacement_services: replacement_services},
         search
       ) do
    Enum.any?(replacement_services, fn replacement_service ->
      string_contains?(replacement_service.shuttle.shuttle_name, search)
    end)
  end

  defp string_contains?(string, search) do
    string
    |> String.downcase()
    |> String.contains?(String.downcase(search))
  end
end
