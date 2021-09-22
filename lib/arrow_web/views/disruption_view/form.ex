defmodule ArrowWeb.DisruptionView.Form do
  @moduledoc "An interface between Ecto structs and the `DisruptionForm` React component."

  alias Arrow.{Adjustment, DisruptionRevision}
  alias Arrow.Disruption.DayOfWeek
  alias Ecto.Changeset

  @doc "Encodes the required props passed to the `DisruptionForm` component."
  @spec props(Changeset.t(DisruptionRevision.t()), [Adjustment.t()]) :: %{String.t() => any}
  def props(changeset, all_adjustments) do
    %DisruptionRevision{
      start_date: start_date,
      end_date: end_date,
      row_approved: row_approved,
      adjustments: adjustments,
      days_of_week: days_of_week,
      exceptions: exceptions,
      trip_short_names: trip_short_names
    } = Changeset.apply_changes(changeset)

    %{
      "allAdjustments" => Enum.map(all_adjustments, &encode_adjustment/1),
      "disruptionRevision" => %{
        "startDate" => start_date,
        "endDate" => end_date,
        "rowApproved" => row_approved,
        "adjustments" => Enum.map(adjustments, &encode_adjustment/1),
        "daysOfWeek" => days_of_week |> Enum.map(&encode_day_of_week/1) |> Enum.into(%{}),
        "exceptions" => Enum.map(exceptions, & &1.excluded_date),
        "tripShortNames" => trip_short_names |> Enum.map(& &1.trip_short_name) |> Enum.join(",")
      }
    }
  end

  defp encode_adjustment(%Adjustment{id: id, route_id: route_id} = adjustment) do
    %{"id" => id, "label" => Adjustment.display_label(adjustment), "routeId" => route_id}
  end

  defp encode_day_of_week(%DayOfWeek{
         day_name: day_name,
         start_time: start_time,
         end_time: end_time
       }) do
    {day_name, %{"start" => start_time, "end" => end_time}}
  end
end
