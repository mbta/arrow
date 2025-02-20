defmodule ArrowWeb.DisruptionV2View.Calendar do
  @moduledoc "An interface between Ecto structs and the `DisruptionCalendar` React component."

  alias Arrow.Disruptions.{DisruptionV2, Limit}
  alias Arrow.Limits.LimitDayOfWeek
  alias ArrowWeb.Endpoint
  alias ArrowWeb.Router.Helpers, as: Routes

  @doc """
  Generates props for `DisruptionCalendar`, which has the same interface as `FullCalendar`.
  Reference: https://fullcalendar.io/docs/event-parsing
  """
  @spec props([DisruptionV2.t()]) :: %{atom => any}
  def props(disruptions), do: %{events: events(disruptions)}

  defp events(disruptions) when is_list(disruptions) do
    Enum.flat_map(disruptions, &events/1)
  end

  defp events(%DisruptionV2{id: id, limits: [limit], is_active: is_active}) do
    events(id, limit, "(disruption #{id})", is_active)
  end

  defp events(%DisruptionV2{id: id, limits: limits, is_active: is_active}) do
    Enum.flat_map(limits, fn limit ->
      events(id, limit, Limit.display_label(limit), is_active)
    end)
  end

  defp events(
         disruption_id,
         %Limit{
           start_date: start_date,
           end_date: end_date,
           limit_day_of_weeks: day_of_weeks
         } = limit,
         event_title,
         is_active
       ) do
    day_numbers =
      day_of_weeks
      |> Enum.filter(& &1.active?)
      |> MapSet.new(&LimitDayOfWeek.day_number/1)

    Date.range(start_date, end_date)
    |> Enum.filter(&(Date.day_of_week(&1) in day_numbers))
    |> Enum.chunk_while([], &chunk_dates/2, &chunk_dates/1)
    |> Enum.map(&{List.last(&1), List.first(&1)})
    |> Enum.map(fn
      {nil, nil} ->
        %{}

      {event_start, event_end} ->
        route = Limit.route(limit)

        %{
          title: event_title,
          classNames: "kind-#{route_class(route)} status-#{status_class(is_active)}",
          start: event_start,
          # end date is treated as exclusive
          end: Date.add(event_end, 1),
          url: Routes.disruption_v2_view_path(Endpoint, :edit, disruption_id),
          extendedProps: %{
            statusOrder: if(is_active, do: 0, else: 1)
          }
        }
    end)
  end

  # Starting a new chunk
  defp chunk_dates(date, []), do: {:cont, [date]}

  # Determine whether a date should be added to the current chunk or start a new one
  defp chunk_dates(date, [prev | _] = dates) do
    if Date.diff(date, prev) == 1 do
      {:cont, [date | dates]}
    else
      {:cont, dates, [date]}
    end
  end

  # Receives the leftover accumulator at the end, which is the last chunk, so emit it
  defp chunk_dates(dates), do: {:cont, dates, []}

  defp route_class(route), do: route |> to_string() |> String.replace("_", "-")

  defp status_class(true), do: "approved"
  defp status_class(false), do: "pending"
end
