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

  defp events(%Disruption{
         id: id,
         revisions: [%{adjustments: [], adjustment_kind: kind} = revision]
       }) do
    events(id, revision, kind, "(disruption #{id})")
  end

  defp events(%Disruption{id: id, revisions: [%{adjustments: adjustments} = revision]}) do
    Enum.flat_map(adjustments, fn adjustment ->
      events(id, revision, Adjustment.kind(adjustment), Adjustment.display_label(adjustment))
    end)
  end

  defp events(
         disruption_id,
         %DisruptionRevision{
           start_date: start_date,
           end_date: end_date,
           days_of_week: days_of_week,
           exceptions: exceptions,
           row_approved: row_approved
         },
         adjustment_kind,
         event_title
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
        title: event_title,
        classNames: "kind-#{kind_class(adjustment_kind)} status-#{status_class(row_approved)}",
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

  defp kind_class(nil), do: "none"
  defp kind_class(kind), do: kind |> to_string() |> String.replace("_", "-")

  defp status_class(true), do: "approved"
  defp status_class(false), do: "pending"
end
