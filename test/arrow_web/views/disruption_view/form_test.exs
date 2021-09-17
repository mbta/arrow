defmodule ArrowWeb.DisruptionView.FormTest do
  use ExUnit.Case, async: true

  alias Arrow.{Adjustment, DisruptionRevision}
  alias Arrow.Disruption.{DayOfWeek, Exception, TripShortName}
  alias ArrowWeb.DisruptionView.Form
  alias Ecto.Changeset

  describe "props/2" do
    test "converts a DisruptionRevision changeset and adjustments to DisruptionForm props" do
      adjustments = [
        %Adjustment{id: 1, route_id: "Red", source_label: "Kendall"},
        %Adjustment{id: 2, route_id: "Orange", source_label: "Wellington"}
      ]

      changeset =
        %DisruptionRevision{
          start_date: ~D[2021-01-01],
          end_date: ~D[2021-01-31],
          adjustments: [hd(adjustments)],
          days_of_week: [%DayOfWeek{day_name: "monday", start_time: ~T[21:15:00], end_time: nil}],
          exceptions: [%Exception{excluded_date: ~D[2021-01-11]}],
          trip_short_names: [
            %TripShortName{trip_short_name: "one"},
            %TripShortName{trip_short_name: "two"}
          ]
        }
        |> Changeset.change(%{end_date: ~D[2021-02-28]})

      expected = %{
        "allAdjustments" => [
          %{"id" => 1, "label" => "Kendall", "routeId" => "Red"},
          %{"id" => 2, "label" => "Wellington", "routeId" => "Orange"}
        ],
        "disruptionRevision" => %{
          "startDate" => ~D[2021-01-01],
          "endDate" => ~D[2021-02-28],
          "adjustments" => [%{"id" => 1, "label" => "Kendall", "routeId" => "Red"}],
          "daysOfWeek" => %{"monday" => %{"start" => ~T[21:15:00], "end" => nil}},
          "exceptions" => [~D[2021-01-11]],
          "tripShortNames" => "one,two"
        }
      }

      assert Form.props(changeset, adjustments) == expected
    end
  end
end
