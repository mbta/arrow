defmodule ArrowWeb.DisruptionView.DaysOfWeek do
  @moduledoc "Handles the display of disruption `days_of_week`."

  alias Arrow.Disruption.DayOfWeek

  @doc "Describes each day-of-week of a disruption and its time period."
  @spec describe([DayOfWeek.t()]) :: [{String.t(), String.t()}]
  def describe(days_of_week) when is_list(days_of_week) do
    days_of_week |> Enum.sort_by(&day_number/1) |> Enum.map(&describe_day(&1, :long))
  end

  @doc """
  Summarizes the days-of-week of a disruption and their time periods.

  Each item in the returned list is a description of a single day or set of consecutive days. The
  items are themselves lists, to suggest where e.g. line breaks might be placed between the "days"
  and "times" part of the description (if these are separate).
  """
  @spec summarize([DayOfWeek.t()]) :: [[String.t()]]

  def summarize([day_of_week]), do: [summarize_day(day_of_week)]

  def summarize(days_of_week) when is_list(days_of_week) do
    sorted_days = Enum.sort_by(days_of_week, &day_number/1)
    days_are_consecutive = consecutive?(sorted_days)

    cond do
      days_are_consecutive and same_times?(sorted_days) ->
        [describe_days_with_same_times(hd(sorted_days), List.last(sorted_days))]

      days_are_consecutive and contiguous_times?(sorted_days) ->
        [describe_days_with_contiguous_times(hd(sorted_days), List.last(sorted_days))]

      true ->
        Enum.map(sorted_days, &summarize_day/1)
    end
  end

  defp consecutive?(sorted_days) do
    sorted_days
    |> Enum.map(&day_number/1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [a, b] -> a + 1 == b end)
  end

  defp contiguous_times?(sorted_days) do
    sorted_days
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn
      [%{end_time: nil}, %{start_time: nil}] -> true
      _ -> false
    end)
  end

  defp day_number(%{day_name: day_name}), do: day_number(day_name)
  defp day_number("monday"), do: 0
  defp day_number("tuesday"), do: 1
  defp day_number("wednesday"), do: 2
  defp day_number("thursday"), do: 3
  defp day_number("friday"), do: 4
  defp day_number("saturday"), do: 5
  defp day_number("sunday"), do: 6

  defp describe_day(%{day_name: day_name, start_time: start_time, end_time: end_time}, format) do
    {format_day(day_name, format), describe_times(start_time, end_time)}
  end

  defp describe_days_with_contiguous_times(
         %{day_name: first_day, start_time: start_time},
         %{day_name: last_day, end_time: end_time}
       ) do
    from = format_day(first_day, :short) <> " " <> describe_start_time(start_time)
    to = format_day(last_day, :short) <> " " <> describe_end_time(end_time)
    [from <> " – " <> to]
  end

  defp describe_days_with_same_times(
         %{day_name: first_day, start_time: start_time, end_time: end_time},
         %{day_name: last_day}
       ) do
    [
      format_day(first_day, :short) <> " – " <> format_day(last_day, :short),
      describe_times(start_time, end_time)
    ]
  end

  defp describe_times(start_time, end_time) do
    describe_start_time(start_time) <> " – " <> describe_end_time(end_time)
  end

  defp describe_end_time(time), do: format_time(time, "End of service")
  defp describe_start_time(time), do: format_time(time, "Start of service")

  defp format_day(day_name, :long), do: String.capitalize(day_name)
  defp format_day(day_name, :short), do: day_name |> String.slice(0..2) |> String.capitalize()

  defp format_time(%Time{} = time, _fallback), do: Calendar.strftime(time, "%-I:%M%p")
  defp format_time(nil, fallback), do: fallback

  defp same_times?([%{start_time: first_start, end_time: first_end} | _] = days_of_week) do
    Enum.all?(days_of_week, fn
      %{start_time: ^first_start, end_time: ^first_end} -> true
      _ -> false
    end)
  end

  defp summarize_day(day_of_week), do: day_of_week |> describe_day(:short) |> Tuple.to_list()
end
