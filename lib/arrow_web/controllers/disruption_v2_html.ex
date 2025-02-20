defmodule ArrowWeb.DisruptionV2View do
  use ArrowWeb, :html

  alias __MODULE__.Calendar, as: DCalendar
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

  defp disrupted_routes(%DisruptionV2{limits: limits}) do
    limits |> Enum.map(& &1.route.id) |> Enum.uniq()
  end

  defp get_dates(%DisruptionV2{limits: [], replacement_services: []}) do
    {nil, nil}
  end

  defp get_dates(%DisruptionV2{
         limits: limits,
         replacement_services: replacement_services
       }) do
    min_date =
      (limits ++ replacement_services)
      |> Enum.map(& &1.start_date)
      |> Enum.min(Date, fn -> ~D[9999-12-31] end)

    max_date =
      (limits ++ replacement_services)
      |> Enum.map(& &1.end_date)
      |> Enum.max(Date, fn -> ~D[0000-01-01] end)

    {min_date, max_date}
  end

  defp format_date(nil), do: "N/A"

  defp format_date(date) do
    Calendar.strftime(date, "%m/%d/%y")
  end

  defp update_filters_path(conn, filters) do
    Controller.current_path(conn, Filters.to_params(filters))
  end
end
