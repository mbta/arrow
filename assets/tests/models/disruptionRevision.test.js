"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var adjustment_1 = __importDefault(require("../../src/models/adjustment"))
var dayOfWeek_1 = __importDefault(require("../../src/models/dayOfWeek"))
var disruptionRevision_1 = __importDefault(
  require("../../src/models/disruptionRevision")
)
var exception_1 = __importDefault(require("../../src/models/exception"))
var tripShortName_1 = __importDefault(require("../../src/models/tripShortName"))
describe("DisruptionRevision", function () {
  test("toJsonApi", function () {
    var disruptionRevision = new disruptionRevision_1.default({
      id: "5",
      startDate: new Date(2020, 0, 1),
      endDate: new Date(2020, 2, 1),
      isActive: true,
      adjustments: [
        new adjustment_1.default({
          id: "1",
          routeId: "Red",
          sourceLabel: "HarvardAlewife",
        }),
      ],
      daysOfWeek: [new dayOfWeek_1.default({ id: "2", dayName: "friday" })],
      exceptions: [
        new exception_1.default({
          id: "3",
          excludedDate: new Date(2020, 0, 2),
        }),
      ],
      tripShortNames: [new tripShortName_1.default({ id: "4" })],
    })
    expect(disruptionRevision.toJsonApi()).toEqual({
      data: {
        id: "5",
        type: "disruption_revision",
        attributes: {
          start_date: "2020-01-01",
          end_date: "2020-03-01",
          is_active: true,
        },
        relationships: {
          adjustments: {
            data: [
              {
                id: "1",
                type: "adjustment",
                attributes: { route_id: "Red", source_label: "HarvardAlewife" },
              },
            ],
          },
          days_of_week: {
            data: [
              {
                id: "2",
                type: "day_of_week",
                attributes: { day_name: "friday" },
              },
            ],
          },
          exceptions: {
            data: [
              {
                id: "3",
                type: "exception",
                attributes: { excluded_date: "2020-01-02" },
              },
            ],
          },
          trip_short_names: {
            data: [{ id: "4", type: "trip_short_name", attributes: {} }],
          },
        },
      },
    })
  })
  test("fromJsonObject success", function () {
    expect(
      disruptionRevision_1.default.fromJsonObject(
        {
          id: "1",
          type: "disruption_revision",
          attributes: {
            start_date: "2019-12-20",
            end_date: "2020-01-12",
            is_active: true,
            inserted_at: "2020-01-01T12:00:00Z",
          },
          relationships: {
            adjustments: {
              data: [
                { id: "2", type: "adjustment" },
                { id: "1", type: "adjustment" },
              ],
            },
            days_of_week: {
              data: [
                { id: "1", type: "day_of_week" },
                { id: "2", type: "day_of_week" },
              ],
            },
            exceptions: {
              data: [
                { id: "2", type: "exception" },
                { id: "1", type: "exception" },
              ],
            },
          },
        },
        {
          "adjustment-1": new adjustment_1.default({
            id: "1",
            sourceLabel: "Kenmore",
            routeId: "Green-D",
          }),
          "adjustment-2": new adjustment_1.default({
            id: "2",
            sourceLabel: "Alewife",
            routeId: "Red",
          }),
          "day_of_week-1": new dayOfWeek_1.default({
            id: "1",
            startTime: "20:45:00",
            dayName: "saturday",
          }),
          "day_of_week-2": new dayOfWeek_1.default({
            id: "2",
            startTime: "20:45:00",
            dayName: "friday",
          }),
          "exception-2": new exception_1.default({
            id: "2",
            excludedDate: new Date(2020, 1, 1),
          }),
          "exception-1": new exception_1.default({
            id: "1",
            excludedDate: new Date(2020, 2, 1),
          }),
        }
      )
    ).toEqual(
      new disruptionRevision_1.default({
        id: "1",
        startDate: new Date("2019-12-20T00:00:00Z"),
        endDate: new Date("2020-01-12T00:00:00Z"),
        isActive: true,
        insertedAt: new Date("2020-01-01T12:00:00Z"),
        adjustments: [
          new adjustment_1.default({
            id: "1",
            sourceLabel: "Kenmore",
            routeId: "Green-D",
          }),
          new adjustment_1.default({
            id: "2",
            sourceLabel: "Alewife",
            routeId: "Red",
          }),
        ],
        daysOfWeek: [
          new dayOfWeek_1.default({
            id: "2",
            startTime: "20:45:00",
            dayName: "friday",
          }),
          new dayOfWeek_1.default({
            id: "1",
            startTime: "20:45:00",
            dayName: "saturday",
          }),
        ],
        exceptions: [
          new exception_1.default({
            id: "2",
            excludedDate: new Date(2020, 1, 1),
          }),
          new exception_1.default({
            id: "1",
            excludedDate: new Date(2020, 2, 1),
          }),
        ],
        tripShortNames: [],
      })
    )
  })
  test("fromJsonObject error wrong format", function () {
    expect(disruptionRevision_1.default.fromJsonObject({}, {})).toEqual("error")
  })
  test("fromJsonObject error not an object", function () {
    expect(disruptionRevision_1.default.fromJsonObject(5, {})).toEqual("error")
  })
  test("isOfType", function () {
    expect(
      disruptionRevision_1.default.isOfType(
        new disruptionRevision_1.default({
          isActive: true,
          adjustments: [],
          daysOfWeek: [],
          exceptions: [],
          tripShortNames: [],
        })
      )
    ).toBe(true)
    expect(
      disruptionRevision_1.default.isOfType(
        new exception_1.default({ excludedDate: new Date() })
      )
    ).toBe(false)
  })
})
