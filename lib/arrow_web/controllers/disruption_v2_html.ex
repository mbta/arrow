defmodule ArrowWeb.DisruptionV2View do
  use ArrowWeb, :html

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Permissions
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

  @spec route_icon_path(Plug.Conn.t(), atom()) :: String.t()
  defp route_icon_path(conn, route_id) do
    Routes.static_path(conn, "/images/icon-#{@route_icon_names[route_id]}-small.svg")
  end

  defp route_icon(conn, route_id, size, opts) when size in ~w(sm lg) do
    content_tag(:span, "",
      class: "m-icon m-icon-#{size} #{Keyword.get(opts, :class, "")}",
      style: "background-image: url(#{route_icon_path(conn, route_id)})"
    )
  end

  defp disrupted_routes(%DisruptionV2{limits: limits}) do
    limits |> Enum.map(& &1.route.id) |> Enum.uniq()
  end

  defp get_dates(%DisruptionV2{
         limits: limits,
         replacement_services: replacement_services
       })
       when limits == [] and replacement_services == [] do
    {nil, nil}
  end

  defp get_dates(%DisruptionV2{
         limits: limits,
         replacement_services: replacement_services
       }) do
    min_start_limit = limits |> Enum.map(& &1.start_date) |> find_minumum()
    max_end_limit = limits |> Enum.map(& &1.end_date) |> find_maximum()

    min_start_replacement_service =
      replacement_services |> Enum.map(& &1.start_date) |> find_minumum()

    max_end_replacement_service =
      replacement_services |> Enum.map(& &1.end_date) |> find_maximum()

    {Enum.min([min_start_limit, min_start_replacement_service], Date),
     Enum.max([max_end_limit, max_end_replacement_service], Date)}
  end

  defp find_minumum([]), do: ~D[9999-12-31]

  defp find_minumum(dates) do
    Enum.min(dates, Date)
  end

  defp find_maximum([]), do: ~D[0000-01-01]

  defp find_maximum(dates) do
    Enum.max(dates, Date)
  end

  defp format_date(nil), do: "N/A"

  defp format_date(date) do
    Calendar.strftime(date, "%m/%d/%y")
  end
end
