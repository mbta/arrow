import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import DisruptionRevision from "../../src/models/disruptionRevision"
import Exception from "../../src/models/exception"
import TripShortName from "../../src/models/tripShortName"

describe("DisruptionRevision", () => {
  test("toJsonApi", () => {
    const disruptionRevision = new DisruptionRevision({
      id: "5",
      startDate: new Date(2020, 0, 1),
      endDate: new Date(2020, 2, 1),
      isActive: true,
      adjustments: [
        new Adjustment({
          id: "1",
          routeId: "Red",
          sourceLabel: "HarvardAlewife",
        }),
      ],
      daysOfWeek: [new DayOfWeek({ id: "2", dayName: "friday" })],
      exceptions: [
        new Exception({ id: "3", excludedDate: new Date(2020, 0, 2) }),
      ],
      tripShortNames: [new TripShortName({ id: "4" })],
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

  test("fromJsonObject success", () => {
    expect(
      DisruptionRevision.fromJsonObject(
        {
          id: "1",
          type: "disruption_revision",
          attributes: {
            start_date: "2019-12-20",
            end_date: "2020-01-12",
            is_active: true,
          },
          relationships: {
            days_of_week: { data: [{ id: "1", type: "day_of_week" }] },
            exceptions: {
              data: [
                { id: "2", type: "exception" },
                { id: "1", type: "exception" },
              ],
            },
          },
        },
        {
          "day_of_week-1": new DayOfWeek({
            id: "1",
            startTime: "20:45:00",
            dayName: "friday",
          }),
          "exception-2": new Exception({
            id: "2",
            excludedDate: new Date(2020, 1, 1),
          }),
          "exception-1": new Exception({
            id: "1",
            excludedDate: new Date(2020, 2, 1),
          }),
        }
      )
    ).toEqual(
      new DisruptionRevision({
        id: "1",
        startDate: new Date("2019-12-20T00:00:00Z"),
        endDate: new Date("2020-01-12T00:00:00Z"),
        isActive: true,
        adjustments: [],
        daysOfWeek: [
          new DayOfWeek({
            id: "1",
            startTime: "20:45:00",
            dayName: "friday",
          }),
        ],
        exceptions: [
          new Exception({
            id: "2",
            excludedDate: new Date(2020, 1, 1),
          }),
          new Exception({
            id: "1",
            excludedDate: new Date(2020, 2, 1),
          }),
        ],
        tripShortNames: [],
      })
    )
  })

  test("fromJsonObject error wrong format", () => {
    expect(DisruptionRevision.fromJsonObject({}, {})).toEqual("error")
  })

  test("fromJsonObject error not an object", () => {
    expect(DisruptionRevision.fromJsonObject(5, {})).toEqual("error")
  })

  test("isOfType", () => {
    expect(
      DisruptionRevision.isOfType(
        new DisruptionRevision({
          isActive: true,
          adjustments: [],
          daysOfWeek: [],
          exceptions: [],
          tripShortNames: [],
        })
      )
    ).toBe(true)

    expect(
      DisruptionRevision.isOfType(new Exception({ excludedDate: new Date() }))
    ).toBe(false)
  })
})
