import React from "react"
import DisruptionCalendar, {
  disruptionsToCalendarEvents,
} from "../../src/components/DisruptionCalendar"
import { render } from "@testing-library/react"
import DisruptionRevision from "../../src/models/disruptionRevision"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Exception from "../../src/models/exception"
import { toUTCDate } from "../../src/jsonApi"

const SAMPLE_DISRUPTIONS = [
  new DisruptionRevision({
    id: "1",
    disruptionId: "1",
    startDate: toUTCDate("2019-10-31"),
    endDate: toUTCDate("2019-11-15"),
    isActive: true,
    adjustments: [
      new Adjustment({
        id: "1",
        routeId: "Red",
        sourceLabel: "AlewifeHarvard",
      }),
    ],
    daysOfWeek: [
      new DayOfWeek({
        id: "1",
        startTime: "20:45:00",
        dayName: "friday",
      }),
      new DayOfWeek({
        id: "2",
        dayName: "saturday",
      }),
      new DayOfWeek({
        id: "3",
        dayName: "sunday",
      }),
    ],
    exceptions: [new Exception({ excludedDate: toUTCDate("2019-11-01") })],
    tripShortNames: [],
  }),
  new DisruptionRevision({
    id: "3",
    disruptionId: "3",
    startDate: toUTCDate("2019-11-15"),
    endDate: toUTCDate("2019-11-30"),
    isActive: true,
    adjustments: [
      new Adjustment({
        id: "2",
        routeId: "Green-D",
        sourceLabel: "Kenmore-Newton Highlands",
      }),
    ],
    daysOfWeek: [
      new DayOfWeek({
        id: "1",
        startTime: "20:45:00",
        dayName: "friday",
      }),
      new DayOfWeek({
        id: "2",
        dayName: "saturday",
      }),
      new DayOfWeek({
        id: "3",
        dayName: "sunday",
      }),
    ],
    exceptions: [],
    tripShortNames: [],
  }),
  new DisruptionRevision({
    id: "4",
    disruptionId: "4",
    startDate: toUTCDate("2019-11-15"),
    endDate: toUTCDate("2019-11-30"),
    isActive: true,
    adjustments: [
      new Adjustment({
        id: "2",
        routeId: "Green-D",
        sourceLabel: "Kenmore-Newton Highlands",
      }),
    ],
    daysOfWeek: [],
    exceptions: [],
    tripShortNames: [],
  }),
]

describe("DisruptionCalendar", () => {
  describe("disruptionsToCalendarEvents", () => {
    it("parses disruptions", () => {
      expect(disruptionsToCalendarEvents(SAMPLE_DISRUPTIONS)).toEqual([
        {
          id: "1",
          title: "AlewifeHarvard",
          backgroundColor: "#da291c",
          start: "2019-11-02",
          end: "2019-11-04",
          url: "/disruptions/1",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "1",
          title: "AlewifeHarvard",
          backgroundColor: "#da291c",
          start: "2019-11-08",
          end: "2019-11-11",
          url: "/disruptions/1",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "1",
          title: "AlewifeHarvard",
          backgroundColor: "#da291c",
          start: "2019-11-15",
          end: "2019-11-15",
          url: "/disruptions/1",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "3",
          title: "Kenmore-Newton Highlands",
          backgroundColor: "#00843d",
          start: "2019-11-15",
          end: "2019-11-18",
          url: "/disruptions/3",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "3",
          title: "Kenmore-Newton Highlands",
          backgroundColor: "#00843d",
          start: "2019-11-22",
          end: "2019-11-25",
          url: "/disruptions/3",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "3",
          title: "Kenmore-Newton Highlands",
          backgroundColor: "#00843d",
          start: "2019-11-29",
          end: "2019-12-01",
          url: "/disruptions/3",
          eventDisplay: "block",
          allDay: true,
        },
      ])
    })

    it("handles invalid days of week gracefully", () => {
      expect(
        disruptionsToCalendarEvents([
          new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: toUTCDate("2020-07-01"),
            endDate: toUTCDate("2020-07-02"),
            isActive: true,
            adjustments: [
              new Adjustment({
                id: "1",
                routeId: "Red",
                sourceLabel: "AlewifeHarvard",
              }),
            ],
            daysOfWeek: [
              new DayOfWeek({
                id: "1",
                startTime: "20:45:00",
                dayName: "friday",
              }),
            ],
            exceptions: [],
            tripShortNames: [],
          }),
        ])
      ).toEqual([])
    })
  })

  test("renders correctly", () => {
    const tree = render(
      <DisruptionCalendar
        initialDate={toUTCDate("2019-11-15")}
        data={SAMPLE_DISRUPTIONS}
      />
    )
    expect(tree).toMatchSnapshot()
  })

  test("accepts a JSON:API disruptions response as input", () => {
    const calendar = render(
      <DisruptionCalendar
        initialDate={toUTCDate("2021-01-01")}
        data={{
          data: [
            {
              attributes: {},
              id: "1",
              relationships: {
                revisions: { data: [{ id: "1", type: "disruption_revision" }] },
                ready_revision: { data: null },
                published_revision: { data: null },
              },
              type: "disruption",
            },
          ],
          included: [
            {
              attributes: {
                end_date: "2021-01-01",
                start_date: "2021-01-01",
                is_active: true,
              },
              id: "1",
              relationships: {
                adjustments: {
                  data: [{ id: "1", type: "adjustment" }],
                },
                days_of_week: { data: [{ id: "1", type: "day_of_week" }] },
                exceptions: { data: [] },
                trip_short_names: { data: [] },
              },
              type: "disruption_revision",
            },
            {
              attributes: { day_name: "friday" },
              id: "1",
              type: "day_of_week",
            },
            {
              attributes: {
                route_id: "Green-D",
                source: "gtfs_creator",
                source_label: "KenmoreReservoir",
              },
              id: "1",
              type: "adjustment",
            },
          ],
          jsonapi: { version: "1.0" },
        }}
      />
    )

    expect(calendar.queryByText(/error loading/i)).not.toBeInTheDocument()

    expect(
      calendar.container.querySelector(
        '[data-date="2021-01-01"] .fc-daygrid-event'
      )
    ).not.toBeNull()
  })

  test("displays an error if the input is not valid JSON:API data", () => {
    const calendar = render(
      <DisruptionCalendar data={{ this_data: "is not JSON:API" }} />
    )

    expect(calendar.queryByText(/error loading/i)).toBeInTheDocument()
  })

  test("handles daylight savings correctly", () => {
    const { container } = render(
      <DisruptionCalendar
        initialDate={toUTCDate("2020-11-15")}
        data={[
          new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: toUTCDate("2020-10-30"),
            endDate: toUTCDate("2020-11-22"),
            isActive: true,
            adjustments: [
              new Adjustment({
                id: "1",
                routeId: "Red",
                sourceLabel: "AlewifeHarvard",
              }),
            ],
            daysOfWeek: [
              new DayOfWeek({
                id: "1",
                startTime: "20:45:00",
                dayName: "friday",
              }),
              new DayOfWeek({
                id: "2",
                dayName: "saturday",
              }),
              new DayOfWeek({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [
              new Exception({ excludedDate: toUTCDate("2020-11-15") }),
            ],
            tripShortNames: [],
          }),
        ]}
      />
    )

    const activeDays = ["01", "06", "08", "13", "20", "22"]

    activeDays.forEach((day) => {
      expect(
        container.querySelector(
          `[data-date="2020-11-${day}"] .fc-daygrid-event`
        )
      ).not.toBeNull()
    })

    expect(
      container.querySelector('[data-date="2020-11-15"] .fc-daygrid-event')
    ).toBeNull()
  })
})
