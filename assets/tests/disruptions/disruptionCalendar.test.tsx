import React from "react"
import {
  DisruptionCalendar,
  disruptionsToCalendarEvents,
  dayNameToInt,
} from "../../src/disruptions/disruptionCalendar"
import { render } from "@testing-library/react"
import Disruption from "../../src/models/disruption"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Exception from "../../src/models/exception"
import { toUTCDate } from "../../src/jsonApi"

const SAMPLE_DISRUPTIONS = [
  new Disruption({
    id: "1",
    startDate: toUTCDate("2019-10-31"),
    endDate: toUTCDate("2019-11-15"),
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
  new Disruption({
    id: "3",
    startDate: toUTCDate("2019-11-15"),
    endDate: toUTCDate("2019-11-30"),
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
  new Disruption({
    id: "4",
    startDate: toUTCDate("2019-11-15"),
    endDate: toUTCDate("2019-11-30"),
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
  test("dayNameToInt", () => {
    ;([
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday",
    ] as DayOfWeek["dayName"][]).forEach((day, i) => {
      expect(dayNameToInt(day)).toEqual(i)
    })
  })

  describe("disruptionsToCalendarEvents", () => {
    it("parses disruptions", () => {
      expect(disruptionsToCalendarEvents(SAMPLE_DISRUPTIONS)).toEqual([
        {
          id: "1",
          title: "AlewifeHarvard",
          backgroundColor: "#da291c",
          start: toUTCDate("2019-11-02"),
          end: toUTCDate("2019-11-04"),
          url: "/disruptions/1",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "1",
          title: "AlewifeHarvard",
          backgroundColor: "#da291c",
          start: toUTCDate("2019-11-08"),
          end: toUTCDate("2019-11-11"),
          url: "/disruptions/1",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "1",
          title: "AlewifeHarvard",
          backgroundColor: "#da291c",
          start: toUTCDate("2019-11-15"),
          end: toUTCDate("2019-11-15"),
          url: "/disruptions/1",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "3",
          title: "Kenmore-Newton Highlands",
          backgroundColor: "#00843d",
          start: toUTCDate("2019-11-15"),
          end: toUTCDate("2019-11-18"),
          url: "/disruptions/3",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "3",
          title: "Kenmore-Newton Highlands",
          backgroundColor: "#00843d",
          start: toUTCDate("2019-11-22"),
          end: toUTCDate("2019-11-25"),
          url: "/disruptions/3",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "3",
          title: "Kenmore-Newton Highlands",
          backgroundColor: "#00843d",
          start: toUTCDate("2019-11-29"),
          end: toUTCDate("2019-12-01"),
          url: "/disruptions/3",
          eventDisplay: "block",
          allDay: true,
        },
      ])
    })

    it("handles invalid days of week gracefully", () => {
      expect(
        disruptionsToCalendarEvents([
          new Disruption({
            id: "1",
            startDate: toUTCDate("2020-07-01"),
            endDate: toUTCDate("2020-07-02"),
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

  test("handles daylight savings correctly", () => {
    const { container } = render(
      <DisruptionCalendar
        initialDate={toUTCDate("2020-11-15")}
        disruptions={[
          new Disruption({
            id: "1",
            startDate: toUTCDate("2020-10-30"),
            endDate: toUTCDate("2020-11-22"),
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

  test("renders correctly", () => {
    const tree = render(
      <DisruptionCalendar
        initialDate={toUTCDate("2019-11-15")}
        disruptions={SAMPLE_DISRUPTIONS}
      />
    )
    expect(tree).toMatchSnapshot()
  })
})
