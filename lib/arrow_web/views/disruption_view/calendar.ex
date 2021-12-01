defmodule ArrowWeb.DisruptionView.Calendar do
  @moduledoc "An interface between Ecto structs and the `DisruptionCalendar` React component."

  alias Arrow.{Adjustment, Disruption, DisruptionRevision}
  alias Arrow.Disruption.DayOfWeek
  alias ArrowWeb.Endpoint
  alias ArrowWeb.Router.Helpers, as: Routes

  @doc """
  Generates props for `DisruptionCalendar`, which has the same interface as `FullCalendar`.
  Reference: https://fullcalendar.io/docs/event-parsing
  """
  @spec props([Disruption.t()]) :: %{atom => any}
  def props(disruptions), do: %{events: events(disruptions)}

  defp events(disruptions) when is_list(disruptions) do
    Enum.flat_map(disruptions, &events/1)
  end

  defp events(%Disruption{id: id, revisions: [%{adjustments: []} = revision]}) do
    events(id, revision, %Adjustment{route_id: "none", source_label: "(disruption #{id})"})
  end

  defp events(%Disruption{id: id, revisions: [%{adjustments: adjustments} = revision]}) do
    Enum.flat_map(adjustments, &events(id, revision, &1))
  end

  defp events(
         disruption_id,
         %DisruptionRevision{
           start_date: start_date,
           end_date: end_date,
           days_of_week: days_of_week,
           exceptions: exceptions
         },
         %Adjustment{route_id: route_id, source_label: source_label}
       ) do
    day_numbers = MapSet.new(days_of_week, &DayOfWeek.day_number/1)
    excluded_dates = MapSet.new(exceptions, & &1.excluded_date)

    Date.range(start_date, end_date)
    |> Enum.filter(&(Date.day_of_week(&1) in day_numbers))
    |> Enum.reject(&(&1 in excluded_dates))
    |> Enum.chunk_while([], &chunk_dates/2, &chunk_dates/1)
    |> Enum.map(&{List.last(&1), hd(&1)})
    |> Enum.map(fn {event_start, event_end} ->
      %{
        title: source_label,
        classNames: "route-#{route_id}",
        start: event_start,
        # end date is treated as exclusive
        end: Date.add(event_end, 1),
        url: Routes.disruption_path(Endpoint, :show, disruption_id)
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
end
