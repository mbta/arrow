import React from "react"
import {
  DisruptionCalendar,
  disruptionsToCalendarEvents,
  dayNameToInt,
} from "../../src/disruptions/disruptionCalendar"
import { render } from "@testing-library/react"
import DisruptionRevision from "../../src/models/disruptionRevision"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Exception from "../../src/models/exception"
import { toUTCDate } from "../../src/jsonApi"
import { BrowserRouter } from "react-router-dom"
import { DisruptionView } from "../../src/models/disruption"

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
  test("dayNameToInt", () => {
    ;(
      [
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday",
      ] as DayOfWeek["dayName"][]
    ).forEach((day, i) => {
      expect(dayNameToInt(day)).toEqual(i)
    })
  })

  describe("disruptionsToCalendarEvents", () => {
    it("parses disruptions", () => {
      expect(
        disruptionsToCalendarEvents(SAMPLE_DISRUPTIONS, DisruptionView.Ready)
      ).toEqual([
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

    it("correctly adds view query param to detail page links", () => {
      expect(
        disruptionsToCalendarEvents(
          SAMPLE_DISRUPTIONS,
          DisruptionView.Ready
        ).every((x) => !x.url.includes("?v=draft"))
      ).toEqual(true)

      expect(
        disruptionsToCalendarEvents(
          SAMPLE_DISRUPTIONS,
          DisruptionView.Draft
        ).every((x) => x.url.includes("?v=draft"))
      ).toEqual(true)
    })

    it("handles invalid days of week gracefully", () => {
      expect(
        disruptionsToCalendarEvents(
          [
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
          ],
          DisruptionView.Ready
        )
      ).toEqual([])
    })
  })

  test("handles daylight savings correctly", () => {
    const { container } = render(
      <BrowserRouter>
        <DisruptionCalendar
          initialDate={toUTCDate("2020-11-15")}
          disruptionRevisions={[
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
      </BrowserRouter>
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
      <BrowserRouter>
        <DisruptionCalendar
          initialDate={toUTCDate("2019-11-15")}
          disruptionRevisions={SAMPLE_DISRUPTIONS}
        />
      </BrowserRouter>
    )
    expect(tree).toMatchSnapshot()
  })
})
