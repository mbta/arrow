defmodule ArrowWeb.DisruptionV2IndexLive do
  use ArrowWeb, :live_view

  alias Arrow.Disruptions
  alias Arrow.Disruptions.DisruptionV2
  alias ArrowWeb.DisruptionV2Controller.Filters
  alias ArrowWeb.DisruptionV2Controller.Filters.Calendar
  alias ArrowWeb.DisruptionV2Controller.Filters.Table
  use Phoenix.Router
  import Phoenix.LiveView.Router
  import Plug.Conn
  import Phoenix.Controller

  import Ecto.Query

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
      apply_past_filter(disruption, filters) and apply_search_filter(disruption, filters)
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
    do: disruption.is_active

  defp apply_only_approved_filter(_disruption, %Filters{only_approved?: false}),
    do: true

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

  defp route_icon(assigns) do
    ~H"""
    <span
      class={"m-icon m-icon-#{@size} #{@class}"}
      style={"background-image: url(#{route_icon_path(@conn, @route_id)})"}
    />
    """
  end

  attr :conn, Plug.Conn, required: true
  attr :filters, ArrowWeb.DisruptionV2Controller.Filters, required: true
  attr :field, :atom, required: true
  attr :label, :string, required: true

  defp sort_link(assigns) do
    %{view: %{sort: sort_state, active_sort: active_field}} = assigns.filters

    # Current state values
    active? = assigns.field == active_field
    direction = Map.fetch!(sort_state, assigns.field)

    # New state values, if this sort link is clicked
    new_direction =
      case {active?, direction} do
        {true, :asc} -> :desc
        {true, :desc} -> :asc
        {false, dir} -> dir
      end

    new_sort = %{sort_state | assigns.field => new_direction}

    assigns =
      assign(assigns,
        icon: Map.fetch!(%{asc: "↑", desc: "↓"}, direction),
        active?: active?,
        new_sort: new_sort
      )

    ~H"""
    <a
      class={["m-disruption-table__sortable", @active? and "active"]}
      href={update_view_path(@conn, @filters, sort: @new_sort, active_sort: @field)}
    >
      {@label}<span class="mx-1 m-disruption-table__sortable-indicator">{@icon}</span>
    </a>
    """
  end

  @spec route_icon_path(Plug.Conn.t(), atom()) :: String.t()
  defp route_icon_path(conn, route_id) do
    Routes.static_path(conn, "/images/icon-#{@route_icon_names[route_id]}-small.svg")
  end

  @spec disruption_kind_icon_path(Plug.Conn.t(), atom()) :: String.t()
  def disruption_kind_icon_path(conn, kind) do
    Routes.static_path(conn, "/images/icon-#{@disruption_kind_icon_names[kind]}-small.svg")
  end

  defp disruption_kinds, do: @disruption_kinds

  defp disruption_kind_icon(conn, kind, size, opts \\ []) when size in ~w(sm lg) do
    content_tag(:span, "",
      class: "m-icon m-icon-#{size} #{Keyword.get(opts, :class, "")}",
      style: "background-image: url(#{disruption_kind_icon_path(conn, kind)})"
    )
  end

  defp disrupted_routes(%DisruptionV2{limits: limits}) do
    limits |> Enum.map(& &1.route.id) |> Enum.uniq()
  end

  defp format_date(nil), do: "N/A"

  defp format_date(date) do
    Calendar.strftime(date, "%m/%d/%y")
  end

  defp update_filters_path(conn, filters) do
    Controller.current_path(conn, Filters.to_params(filters))
  end

  defp update_view_path(conn, %{view: view} = filters, key, value) do
    update_filters_path(conn, %{filters | view: %{view | key => value}})
  end

  defp update_view_path(conn, filters, updater) do
    view = Enum.reduce(updater, filters.view, fn {key, value}, view -> %{view | key => value} end)

    update_filters_path(conn, %{filters | view: view})
  end
end
