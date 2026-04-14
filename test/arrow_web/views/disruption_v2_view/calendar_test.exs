defmodule ArrowWeb.DisruptionV2View.CalendarTest do
  use ExUnit.Case, async: true

  alias Arrow.Disruptions.{DisruptionV2, Limit, ReplacementService}
  alias Arrow.Limits.LimitDayOfWeek
  alias Arrow.Shuttles.Shuttle
  alias ArrowWeb.DisruptionV2View.Calendar, as: DCalendar
  alias Arrow.Trainsformer.{Export, Service, ServiceDate, ServiceDateDayOfWeek}

  describe "props/1" do
    test "converts a list of Disruptions to DisruptionCalendar props" do
      disruption = %DisruptionV2{
        id: 123,
        title: "Disruption Title",
        limits: [
          %Limit{
            start_date: ~D[2021-01-01],
            end_date: ~D[2021-01-31],
            route_id: "Red",
            limit_day_of_weeks: [
              %LimitDayOfWeek{
                day_name: :monday,
                start_time: ~T[20:45:00],
                end_time: nil,
                active?: true
              },
              %LimitDayOfWeek{
                day_name: :tuesday,
                start_time: ~T[20:45:00],
                end_time: nil,
                active?: true
              }
            ]
          }
        ],
        replacement_services: [
          %ReplacementService{
            start_date: ~D[2021-02-01],
            end_date: ~D[2021-02-28],
            shuttle: %Shuttle{disrupted_route_id: "Blue"}
          }
        ],
        trainsformer_exports: [],
        status: :approved
      }

      expected_events = [
        %{
          title: "Disruption Title",
          classNames: "kind-red-line status-approved",
          start: ~D[2021-01-04],
          end: ~D[2021-01-06],
          url: "/disruptions/123/edit",
          extendedProps: %{statusOrder: 0}
        },
        %{
          title: "Disruption Title",
          classNames: "kind-red-line status-approved",
          start: ~D[2021-01-11],
          end: ~D[2021-01-13],
          url: "/disruptions/123/edit",
          extendedProps: %{statusOrder: 0}
        },
        %{
          title: "Disruption Title",
          classNames: "kind-red-line status-approved",
          start: ~D[2021-01-18],
          end: ~D[2021-01-20],
          url: "/disruptions/123/edit",
          extendedProps: %{statusOrder: 0}
        },
        %{
          title: "Disruption Title",
          classNames: "kind-red-line status-approved",
          start: ~D[2021-01-25],
          end: ~D[2021-01-27],
          url: "/disruptions/123/edit",
          extendedProps: %{statusOrder: 0}
        },
        %{
          title: "Disruption Title",
          classNames: "kind-blue-line status-approved",
          start: ~D[2021-02-01],
          end: ~D[2021-03-01],
          url: "/disruptions/123/edit",
          extendedProps: %{statusOrder: 0}
        }
      ]

      assert DCalendar.props([disruption]) == %{events: expected_events}
    end

    test "converts a list with a CR disruption to DisruptionCalendar props" do
      disruption = %DisruptionV2{
        id: 321,
        title: "CR Disruption",
        limits: [],
        replacement_services: [],
        trainsformer_exports: [
          %Export{
            services: [
              %Service{
                service_dates: [
                  %ServiceDate{
                    start_date: ~D[2026-04-01],
                    end_date: ~D[2026-05-01],
                    service_date_days_of_week: [
                      %ServiceDateDayOfWeek{
                        day_name: :saturday
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ],
        status: :approved
      }

      expected_events = [
        %{
          start: ~D[2026-04-04],
          title: "CR Disruption",
          end: ~D[2026-04-05],
          url: "/disruptions/321",
          classNames: "kind-commuter-rail status-approved",
          extendedProps: %{statusOrder: 0}
        },
        %{
          start: ~D[2026-04-11],
          title: "CR Disruption",
          end: ~D[2026-04-12],
          url: "/disruptions/321",
          classNames: "kind-commuter-rail status-approved",
          extendedProps: %{statusOrder: 0}
        },
        %{
          start: ~D[2026-04-18],
          title: "CR Disruption",
          end: ~D[2026-04-19],
          url: "/disruptions/321",
          classNames: "kind-commuter-rail status-approved",
          extendedProps: %{statusOrder: 0}
        },
        %{
          start: ~D[2026-04-25],
          title: "CR Disruption",
          end: ~D[2026-04-26],
          url: "/disruptions/321",
          classNames: "kind-commuter-rail status-approved",
          extendedProps: %{statusOrder: 0}
        }
      ]

      assert DCalendar.props([disruption]) == %{events: expected_events}
    end

    test "returns no events when passed no disruptions" do
      assert DCalendar.props([]) == %{events: []}
    end
  end
end
