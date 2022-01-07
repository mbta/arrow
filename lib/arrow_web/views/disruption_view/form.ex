defmodule ArrowWeb.DisruptionView.Form do
  @moduledoc "An interface between Ecto structs and the `DisruptionForm` React component."

  alias Arrow.{Adjustment, DisruptionRevision}
  alias Arrow.Disruption.DayOfWeek
  alias ArrowWeb.DisruptionView
  alias ArrowWeb.Router.Helpers, as: Routes
  alias Ecto.Changeset

  @doc "Encodes the required props passed to the `DisruptionForm` component."
  @spec props(Plug.Conn.t(), Changeset.t(DisruptionRevision.t()), [Adjustment.t()]) :: %{
          String.t() => any
        }
  def props(conn, changeset, all_adjustments) do
    %DisruptionRevision{
      start_date: start_date,
      end_date: end_date,
      row_approved: row_approved,
      description: description,
      adjustment_kind: adjustment_kind,
      note_body: note_body,
      adjustments: adjustments,
      days_of_week: days_of_week,
      exceptions: exceptions,
      trip_short_names: trip_short_names
    } = Changeset.apply_changes(changeset)

    %{
      "allAdjustments" => Enum.map(all_adjustments, &encode_adjustment/1),
      "disruptionRevision" => %{
        "description" => description,
        "startDate" => start_date,
        "endDate" => end_date,
        "rowApproved" => row_approved,
        "adjustmentKind" => adjustment_kind,
        "adjustments" => Enum.map(adjustments, &encode_adjustment/1),
        "daysOfWeek" => days_of_week |> Enum.map(&encode_day_of_week/1) |> Enum.into(%{}),
        "exceptions" => Enum.map(exceptions, & &1.excluded_date),
        "tripShortNames" => trip_short_names |> Enum.map(& &1.trip_short_name) |> Enum.join(",")
      },
      "iconPaths" => icon_paths(conn),
      "noteBody" => note_body
    }
  end

  defp encode_adjustment(%Adjustment{id: id} = adjustment) do
    %{
      "id" => id,
      "label" => Adjustment.display_label(adjustment),
      "kind" => adjustment |> Adjustment.kind() |> to_string()
    }
  end

  defp encode_day_of_week(%DayOfWeek{
         day_name: day_name,
         start_time: start_time,
         end_time: end_time
       }) do
    {day_name, %{"start" => start_time, "end" => end_time}}
  end

  defp icon_paths(conn) do
    Adjustment.kinds()
    |> Enum.map(&{&1, DisruptionView.adjustment_kind_icon_path(conn, &1)})
    |> Enum.into(%{})
    |> Map.put(:subway, Routes.static_path(conn, "/images/icon-mode-subway-small.svg"))
  end
end
