defmodule ArrowWeb.DisruptionView.FormTest do
  use ArrowWeb.ConnCase, async: true

  alias Arrow.{Adjustment, DisruptionRevision}
  alias Arrow.Disruption.{DayOfWeek, Exception, TripShortName}
  alias ArrowWeb.DisruptionView.Form
  alias Ecto.Changeset

  describe "props/2" do
    setup %{conn: conn} do
      {:ok, conn: conn |> bypass_through(ArrowWeb.Router) |> get("/")}
    end

    test "converts a DisruptionRevision changeset to DisruptionForm props", %{conn: conn} do
      adjustments = [
        %Adjustment{id: 1, route_id: "Red", source_label: "Kendall"},
        %Adjustment{id: 2, route_id: "Orange", source_label: "Wellington"}
      ]

      changeset =
        %DisruptionRevision{
          start_date: ~D[2021-01-01],
          end_date: ~D[2021-01-31],
          row_approved: true,
          description: "a disruption for testing",
          adjustments: [hd(adjustments)],
          days_of_week: [%DayOfWeek{day_name: "monday", start_time: ~T[21:15:00], end_time: nil}],
          exceptions: [%Exception{excluded_date: ~D[2021-01-11]}],
          trip_short_names: [
            %TripShortName{trip_short_name: "one"},
            %TripShortName{trip_short_name: "two"}
          ]
        }
        |> Changeset.change(%{end_date: ~D[2021-02-28]})

      expected_adjustments = [
        %{"id" => 1, "label" => "Kendall", "kind" => "red_line"},
        %{"id" => 2, "label" => "Wellington", "kind" => "orange_line"}
      ]

      expected_revision = %{
        "startDate" => ~D[2021-01-01],
        "endDate" => ~D[2021-02-28],
        "rowApproved" => true,
        "adjustmentKind" => nil,
        "adjustments" => [%{"id" => 1, "label" => "Kendall", "kind" => "red_line"}],
        "daysOfWeek" => %{"monday" => %{"start" => ~T[21:15:00], "end" => nil}},
        "exceptions" => [~D[2021-01-11]],
        "tripShortNames" => "one,two",
        "description" => "a disruption for testing"
      }

      props = Form.props(conn, changeset, adjustments)

      assert props["allAdjustments"] == expected_adjustments
      assert props["disruptionRevision"] == expected_revision
      assert get_in(props, ["iconPaths", :subway]) =~ ~r(^/images/)
    end
  end
end
