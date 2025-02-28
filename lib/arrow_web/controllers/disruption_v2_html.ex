defmodule ArrowWeb.DisruptionV2View do
  use ArrowWeb, :html

  alias __MODULE__.Calendar, as: DCalendar
  alias Arrow.Disruptions
  alias Arrow.Disruptions.DisruptionV2
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
end
