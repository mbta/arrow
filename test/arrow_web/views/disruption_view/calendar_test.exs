defmodule ArrowWeb.DisruptionView.CalendarTest do
  use ExUnit.Case, async: true

  alias Arrow.Adjustment
  alias Arrow.Disruption
  alias Arrow.Disruption.DayOfWeek
  alias Arrow.Disruption.Exception
  alias Arrow.DisruptionRevision
  alias ArrowWeb.DisruptionView.Calendar, as: DCalendar

  describe "props/1" do
    test "converts a list of Disruptions to DisruptionCalendar props" do
      disruption = %Disruption{
        id: 123,
        revisions: [
          %DisruptionRevision{
            start_date: ~D[2021-01-01],
            end_date: ~D[2021-01-31],
            adjustments: [
              %Adjustment{route_id: "Blue", source_label: "Wonderland"},
              %Adjustment{route_id: "Orange", source_label: "Wellington"}
            ],
            days_of_week: [
              %DayOfWeek{day_name: "monday", start_time: ~T[20:45:00], end_time: nil},
              %DayOfWeek{day_name: "tuesday", start_time: ~T[20:45:00], end_time: nil}
            ],
            exceptions: [%Exception{excluded_date: ~D[2021-01-11]}]
          }
        ]
      }

      expected_events = [
        %{
          title: "Wonderland",
          classNames: "kind-blue-line status-approved",
          start: ~D[2021-01-04],
          end: ~D[2021-01-06],
          url: "/disruptionsv1/123",
          extendedProps: %{kindOrder: 0, statusOrder: 0}
        },
        %{
          title: "Wonderland",
          classNames: "kind-blue-line status-approved",
          start: ~D[2021-01-12],
          end: ~D[2021-01-13],
          url: "/disruptionsv1/123",
          extendedProps: %{kindOrder: 0, statusOrder: 0}
        },
        %{
          title: "Wonderland",
          classNames: "kind-blue-line status-approved",
          start: ~D[2021-01-18],
          end: ~D[2021-01-20],
          url: "/disruptionsv1/123",
          extendedProps: %{kindOrder: 0, statusOrder: 0}
        },
        %{
          title: "Wonderland",
          classNames: "kind-blue-line status-approved",
          start: ~D[2021-01-25],
          end: ~D[2021-01-27],
          url: "/disruptionsv1/123",
          extendedProps: %{kindOrder: 0, statusOrder: 0}
        },
        %{
          title: "Wellington",
          classNames: "kind-orange-line status-approved",
          start: ~D[2021-01-04],
          end: ~D[2021-01-06],
          url: "/disruptionsv1/123",
          extendedProps: %{kindOrder: 1, statusOrder: 0}
        },
        %{
          title: "Wellington",
          classNames: "kind-orange-line status-approved",
          start: ~D[2021-01-12],
          end: ~D[2021-01-13],
          url: "/disruptionsv1/123",
          extendedProps: %{kindOrder: 1, statusOrder: 0}
        },
        %{
          title: "Wellington",
          classNames: "kind-orange-line status-approved",
          start: ~D[2021-01-18],
          end: ~D[2021-01-20],
          url: "/disruptionsv1/123",
          extendedProps: %{kindOrder: 1, statusOrder: 0}
        },
        %{
          title: "Wellington",
          classNames: "kind-orange-line status-approved",
          start: ~D[2021-01-25],
          end: ~D[2021-01-27],
          url: "/disruptionsv1/123",
          extendedProps: %{kindOrder: 1, statusOrder: 0}
        }
      ]

      assert DCalendar.props([disruption]) == %{events: expected_events}
    end

    test "returns no events when passed no disruptions" do
      assert DCalendar.props([]) == %{events: []}
    end

    test "outputs a single event for a disruption with no adjustments" do
      disruption = %Disruption{
        id: 123,
        revisions: [
          %DisruptionRevision{
            start_date: ~D[2021-01-04],
            end_date: ~D[2021-01-04],
            adjustments: [],
            adjustment_kind: :commuter_rail,
            days_of_week: [%DayOfWeek{day_name: "monday", start_time: nil, end_time: nil}],
            exceptions: []
          }
        ]
      }

      expected_events = [
        %{
          title: "(disruption 123)",
          classNames: "kind-commuter-rail status-approved",
          start: ~D[2021-01-04],
          end: ~D[2021-01-05],
          url: "/disruptionsv1/123",
          extendedProps: %{kindOrder: 9, statusOrder: 0}
        }
      ]

      assert DCalendar.props([disruption]) == %{events: expected_events}
    end
  end
end
