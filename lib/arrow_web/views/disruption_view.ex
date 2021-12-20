defmodule ArrowWeb.DisruptionView do
  use ArrowWeb, :view

  alias Arrow.{Adjustment, DisruptionRevision, Permissions}
  alias __MODULE__.{DaysOfWeek, Form}
  alias __MODULE__.Calendar, as: DCalendar
  alias ArrowWeb.DisruptionController.Filters
  alias Phoenix.Controller

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

  @spec adjustment_kind_icon_path(Plug.Conn.t(), atom()) :: String.t()
  def adjustment_kind_icon_path(conn, kind) do
    Routes.static_path(conn, "/images/icon-#{@adjustment_kind_icon_names[kind]}-small.svg")
  end

  defp adjustment_kinds, do: Adjustment.kinds()

  defp adjustment_kinds(revision) do
    revision
    |> DisruptionRevision.adjustment_kinds()
    |> Enum.sort_by(&Adjustment.kind_order(&1))
  end

  defp adjustment_kind_icon(conn, kind, size, opts \\ []) when size in ~w(sm lg) do
    content_tag(:span, "",
      class: "m-icon m-icon-#{size} #{Keyword.get(opts, :class, "")}",
      style: "background-image: url(#{adjustment_kind_icon_path(conn, kind)})"
    )
  end

  defp format_date(date, fallback \\ "❓")
  defp format_date(%Date{} = date, _fallback), do: Calendar.strftime(date, "%m/%d/%Y")
  defp format_date(nil, fallback), do: fallback

  # Browsers strip any query params in a form's `action` before submitting, so to retain all the
  # current filter params when the search form is submitted, we need to generate a set of hidden
  # inputs mirroring them.
  defp hidden_inputs_for_search(filters) do
    %{filters | search: nil}
    |> Filters.to_flat_params()
    |> Enum.map(fn {key, value} -> tag(:input, type: "hidden", name: key, value: value) end)
  end

  defp sort_link(conn, filters, field, label) do
    %{view: %{sort: {current_direction, current_field}}} = filters
    active_class = if(field == current_field, do: "active", else: "")
    direction = if(field == current_field and current_direction == :asc, do: :desc, else: :asc)
    arrow_char = if(field == current_field and current_direction == :desc, do: "↓", else: "↑")

    link class: "m-disruption-table__sortable #{active_class}",
         to: update_view_path(conn, filters, :sort, {direction, field}) do
      [
        label,
        content_tag(:span, arrow_char, class: "mx-1 m-disruption-table__sortable-indicator")
      ]
    end
  end

  defp update_filters_path(conn, filters) do
    Controller.current_path(conn, Filters.to_params(filters))
  end

  defp update_view_path(conn, %{view: view} = filters, key, value) do
    update_filters_path(conn, %{filters | view: %{view | key => value}})
  end

  defp mark_as_approved_or_pending(true) do
    "mark as pending"
  end

  defp mark_as_approved_or_pending(false) do
    "mark as approved"
  end
end
