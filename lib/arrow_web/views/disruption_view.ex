defmodule ArrowWeb.DisruptionView do
  use ArrowWeb, :view

  alias Arrow.Permissions
  alias __MODULE__.{DaysOfWeek, Form}
  alias __MODULE__.Calendar, as: DCalendar
  alias ArrowWeb.DisruptionController.Filters
  alias Phoenix.Controller

  defp filter_routes, do: ~w(Blue Orange Red Mattapan Green-B Green-C Green-D Green-E Commuter)

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

  defp route_icon(conn, route, size, opts \\ []) when size in ~w(sm lg) do
    class = Keyword.get(opts, :class, "")
    icon_path = Routes.static_path(conn, "/images/icon-#{route_icon_name(route)}.svg")

    content_tag(:span, "",
      class: "m-icon m-icon-#{size} #{class}",
      style: "background-image: url(#{icon_path})"
    )
  end

  @route_icons %{
    "Blue" => "blue-line-small",
    "Commuter" => "mode-commuter-rail-small",
    "Green-B" => "green-line-b-small",
    "Green-C" => "green-line-c-small",
    "Green-D" => "green-line-d-small",
    "Green-E" => "green-line-e-small",
    "Mattapan" => "mattapan-line-small",
    "Orange" => "orange-line-small",
    "Red" => "red-line-small"
  }

  for {name, icon} <- @route_icons do
    defp route_icon_name(unquote(name)), do: unquote(icon)
  end

  defp route_icon_name("CR-" <> _), do: "mode-commuter-rail-small"
  defp route_icon_name(_), do: "404"

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

  defp route_id_uniq("CR-" <> _), do: "CR"
  defp route_id_uniq(route_id), do: route_id
end
