defmodule ArrowWeb.DisruptionV2View do
  use ArrowWeb, :html

  alias __MODULE__.Calendar, as: DCalendar
  alias Arrow.Disruptions
  alias Arrow.Permissions
  alias ArrowWeb.DisruptionV2Controller.Filters
  alias Phoenix.Controller

  embed_templates "disruption_v2_html/*"

  @route_icon_names %{
    "Blue" => "blue-line",
    "Green-B" => "green-line-b",
    "Green-C" => "green-line-c",
    "Green-D" => "green-line-d",
    "Green-E" => "green-line-e",
    "Mattapan" => "mattapan-line",
    "Orange" => "orange-line",
    "Red" => "red-line"
  }

  @disruption_kinds ~w(
    blue_line
    orange_line
    red_line
    mattapan_line
    green_line
    green_line_b
    green_line_c
    green_line_d
    green_line_e
    commuter_rail
    silver_line
    bus
  )a

  @disruption_kind_icon_names %{
    blue_line: "blue-line",
    bus: "mode-bus",
    commuter_rail: "mode-commuter-rail",
    green_line: "green-line",
    green_line_b: "green-line-b",
    green_line_c: "green-line-c",
    green_line_d: "green-line-d",
    green_line_e: "green-line-e",
    mattapan_line: "mattapan-line",
    orange_line: "orange-line",
    red_line: "red-line",
    silver_line: "silver-line"
  }

  attr :conn, Plug.Conn, required: true
  attr :route_id, :string, required: true
  attr :size, :string, values: ~w(sm lg), required: true
  attr :class, :string, default: ""

  defp route_icon(assigns) do
    ~H"""
    <span
      class={"m-icon m-icon-#{@size} #{@class}"}
      style={"background-image: url(#{route_icon_path(@conn, @route_id)})"}
    />
    """
  end

  defp line_icon(assigns) do
    ~H"""
    <span
      class={"m-icon m-icon-#{@size} #{@class}"}
      style={"background-image: url(#{line_icon_url(@conn, @line_id)})"}
    />
    """
  end

  attr :conn, Plug.Conn, required: true
  attr :filters, ArrowWeb.DisruptionV2Controller.Filters, required: true
  attr :field, :atom, required: true
  attr :label, :string, required: true
  attr :class, :string, default: nil

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
      class={["m-disruption-table__sortable", @active? and "active", @class]}
      href={update_view_path(@conn, @filters, sort: @new_sort, active_sort: @field)}
    >
      {@label}<span class="mx-1 m-disruption-table__sortable-indicator">{@icon}</span>
    </a>
    """
  end

  defp limits(disruption) do
    limits = Enum.map(disruption.limits, &Map.put(&1, :derived?, false))

    derived_limits =
      for export <- disruption.hastus_exports,
          %{import?: true} = service <- export.services,
          derived_limit <- service.derived_limits do
        %{
          derived?: true,
          line_id: export.line_id,
          start_stop: derived_limit.start_stop,
          end_stop: derived_limit.end_stop
        }
      end
      # Because incomplete details are shown for derived limits in this view,
      # ones that are actually different (e.g. are derived from different services with different service dates)
      # can appear as duplicates.
      # Deduplicate them on the info shown, to avoid confusion.
      |> Enum.uniq_by(&{&1.line_id, &1.start_stop.name, &1.end_stop.name})

    limits ++ derived_limits
  end

  @spec route_icon_path(Plug.Conn.t(), String.t()) :: String.t()
  defp route_icon_path(conn, route_id) do
    Routes.static_path(conn, "/images/icon-#{@route_icon_names[route_id]}-small.svg")
  end

  @adjustment_kind_icon_names %{
    blue_line: "blue-line",
    bus: "mode-bus",
    commuter_rail: "mode-commuter-rail",
    green_line: "green-line",
    green_line_b: "green-line-b",
    green_line_c: "green-line-c",
    green_line_d: "green-line-d",
    green_line_e: "green-line-e",
    mattapan_line: "mattapan-line",
    orange_line: "orange-line",
    red_line: "red-line",
    silver_line: "silver-line"
  }

  @line_icon_names %{
    "line-Blue" => :blue_line,
    "line-Orange" => :orange_line,
    "line-Red" => :red_line,
    "line-Mattapan" => :mattapan_line,
    "line-Green" => :green_line
  }

  @spec line_icon_url(Plug.Conn.t(), String.t()) :: String.t()
  defp line_icon_url(conn, line_id) do
    path = "/images/icon-#{@adjustment_kind_icon_names[@line_icon_names[line_id]]}-small.svg"
    Routes.static_path(conn, path)
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
