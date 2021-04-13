"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var react_1 = __importDefault(require("react"))
var disruptionCalendar_1 = require("../../src/disruptions/disruptionCalendar")
var react_2 = require("@testing-library/react")
var disruptionRevision_1 = __importDefault(
  require("../../src/models/disruptionRevision")
)
var adjustment_1 = __importDefault(require("../../src/models/adjustment"))
var dayOfWeek_1 = __importDefault(require("../../src/models/dayOfWeek"))
var exception_1 = __importDefault(require("../../src/models/exception"))
var jsonApi_1 = require("../../src/jsonApi")
var react_router_dom_1 = require("react-router-dom")
var disruption_1 = require("../../src/models/disruption")
var SAMPLE_DISRUPTIONS = [
  new disruptionRevision_1.default({
    id: "1",
    disruptionId: "1",
    startDate: jsonApi_1.toUTCDate("2019-10-31"),
    endDate: jsonApi_1.toUTCDate("2019-11-15"),
    isActive: true,
    adjustments: [
      new adjustment_1.default({
        id: "1",
        routeId: "Red",
        sourceLabel: "AlewifeHarvard",
      }),
    ],
    daysOfWeek: [
      new dayOfWeek_1.default({
        id: "1",
        startTime: "20:45:00",
        dayName: "friday",
      }),
      new dayOfWeek_1.default({
        id: "2",
        dayName: "saturday",
      }),
      new dayOfWeek_1.default({
        id: "3",
        dayName: "sunday",
      }),
    ],
    exceptions: [
      new exception_1.default({
        excludedDate: jsonApi_1.toUTCDate("2019-11-01"),
      }),
    ],
    tripShortNames: [],
  }),
  new disruptionRevision_1.default({
    id: "3",
    disruptionId: "3",
    startDate: jsonApi_1.toUTCDate("2019-11-15"),
    endDate: jsonApi_1.toUTCDate("2019-11-30"),
    isActive: true,
    adjustments: [
      new adjustment_1.default({
        id: "2",
        routeId: "Green-D",
        sourceLabel: "Kenmore-Newton Highlands",
      }),
    ],
    daysOfWeek: [
      new dayOfWeek_1.default({
        id: "1",
        startTime: "20:45:00",
        dayName: "friday",
      }),
      new dayOfWeek_1.default({
        id: "2",
        dayName: "saturday",
      }),
      new dayOfWeek_1.default({
        id: "3",
        dayName: "sunday",
      }),
    ],
    exceptions: [],
    tripShortNames: [],
  }),
  new disruptionRevision_1.default({
    id: "4",
    disruptionId: "4",
    startDate: jsonApi_1.toUTCDate("2019-11-15"),
    endDate: jsonApi_1.toUTCDate("2019-11-30"),
    isActive: true,
    adjustments: [
      new adjustment_1.default({
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
describe("DisruptionCalendar", function () {
  test("dayNameToInt", function () {
    ;[
      "monday",
      "tuesday",
      "wednesday",
      "thursday",
      "friday",
      "saturday",
      "sunday",
    ].forEach(function (day, i) {
      expect(disruptionCalendar_1.dayNameToInt(day)).toEqual(i)
    })
  })
  describe("disruptionsToCalendarEvents", function () {
    it("parses disruptions", function () {
      expect(
        disruptionCalendar_1.disruptionsToCalendarEvents(
          SAMPLE_DISRUPTIONS,
          disruption_1.DisruptionView.Ready
        )
      ).toEqual([
        {
          id: "1",
          title: "AlewifeHarvard",
          backgroundColor: "#da291c",
          start: jsonApi_1.toUTCDate("2019-11-02"),
          end: jsonApi_1.toUTCDate("2019-11-04"),
          url: "/disruptions/1",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "1",
          title: "AlewifeHarvard",
          backgroundColor: "#da291c",
          start: jsonApi_1.toUTCDate("2019-11-08"),
          end: jsonApi_1.toUTCDate("2019-11-11"),
          url: "/disruptions/1",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "1",
          title: "AlewifeHarvard",
          backgroundColor: "#da291c",
          start: jsonApi_1.toUTCDate("2019-11-15"),
          end: jsonApi_1.toUTCDate("2019-11-15"),
          url: "/disruptions/1",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "3",
          title: "Kenmore-Newton Highlands",
          backgroundColor: "#00843d",
          start: jsonApi_1.toUTCDate("2019-11-15"),
          end: jsonApi_1.toUTCDate("2019-11-18"),
          url: "/disruptions/3",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "3",
          title: "Kenmore-Newton Highlands",
          backgroundColor: "#00843d",
          start: jsonApi_1.toUTCDate("2019-11-22"),
          end: jsonApi_1.toUTCDate("2019-11-25"),
          url: "/disruptions/3",
          eventDisplay: "block",
          allDay: true,
        },
        {
          id: "3",
          title: "Kenmore-Newton Highlands",
          backgroundColor: "#00843d",
          start: jsonApi_1.toUTCDate("2019-11-29"),
          end: jsonApi_1.toUTCDate("2019-12-01"),
          url: "/disruptions/3",
          eventDisplay: "block",
          allDay: true,
        },
      ])
    })
    it("correctly adds view query param to detail page links", function () {
      expect(
        disruptionCalendar_1
          .disruptionsToCalendarEvents(
            SAMPLE_DISRUPTIONS,
            disruption_1.DisruptionView.Ready
          )
          .every(function (x) {
            return !x.url.includes("?v=draft")
          })
      ).toEqual(true)
      expect(
        disruptionCalendar_1
          .disruptionsToCalendarEvents(
            SAMPLE_DISRUPTIONS,
            disruption_1.DisruptionView.Draft
          )
          .every(function (x) {
            return x.url.includes("?v=draft")
          })
      ).toEqual(true)
    })
    it("handles invalid days of week gracefully", function () {
      expect(
        disruptionCalendar_1.disruptionsToCalendarEvents(
          [
            new disruptionRevision_1.default({
              id: "1",
              disruptionId: "1",
              startDate: jsonApi_1.toUTCDate("2020-07-01"),
              endDate: jsonApi_1.toUTCDate("2020-07-02"),
              isActive: true,
              adjustments: [
                new adjustment_1.default({
                  id: "1",
                  routeId: "Red",
                  sourceLabel: "AlewifeHarvard",
                }),
              ],
              daysOfWeek: [
                new dayOfWeek_1.default({
                  id: "1",
                  startTime: "20:45:00",
                  dayName: "friday",
                }),
              ],
              exceptions: [],
              tripShortNames: [],
            }),
          ],
          disruption_1.DisruptionView.Ready
        )
      ).toEqual([])
    })
  })
  test("handles daylight savings correctly", function () {
    var container = react_2.render(
      react_1.default.createElement(
        react_router_dom_1.BrowserRouter,
        null,
        react_1.default.createElement(disruptionCalendar_1.DisruptionCalendar, {
          initialDate: jsonApi_1.toUTCDate("2020-11-15"),
          disruptionRevisions: [
            new disruptionRevision_1.default({
              id: "1",
              disruptionId: "1",
              startDate: jsonApi_1.toUTCDate("2020-10-30"),
              endDate: jsonApi_1.toUTCDate("2020-11-22"),
              isActive: true,
              adjustments: [
                new adjustment_1.default({
                  id: "1",
                  routeId: "Red",
                  sourceLabel: "AlewifeHarvard",
                }),
              ],
              daysOfWeek: [
                new dayOfWeek_1.default({
                  id: "1",
                  startTime: "20:45:00",
                  dayName: "friday",
                }),
                new dayOfWeek_1.default({
                  id: "2",
                  dayName: "saturday",
                }),
                new dayOfWeek_1.default({
                  id: "3",
                  dayName: "sunday",
                }),
              ],
              exceptions: [
                new exception_1.default({
                  excludedDate: jsonApi_1.toUTCDate("2020-11-15"),
                }),
              ],
              tripShortNames: [],
            }),
          ],
        })
      )
    ).container
    var activeDays = ["01", "06", "08", "13", "20", "22"]
    activeDays.forEach(function (day) {
      expect(
        container.querySelector(
          '[data-date="2020-11-' + day + '"] .fc-daygrid-event'
        )
      ).not.toBeNull()
    })
    expect(
      container.querySelector('[data-date="2020-11-15"] .fc-daygrid-event')
    ).toBeNull()
  })
  test("renders correctly", function () {
    var tree = react_2.render(
      react_1.default.createElement(
        react_router_dom_1.BrowserRouter,
        null,
        react_1.default.createElement(disruptionCalendar_1.DisruptionCalendar, {
          initialDate: jsonApi_1.toUTCDate("2019-11-15"),
          disruptionRevisions: SAMPLE_DISRUPTIONS,
        })
      )
    )
    expect(tree).toMatchSnapshot()
  })
})
