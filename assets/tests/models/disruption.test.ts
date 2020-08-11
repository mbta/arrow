import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Disruption from "../../src/models/disruption"
import Exception from "../../src/models/exception"
import TripShortName from "../../src/models/tripShortName"

describe("Disruption", () => {
  test("toJsonApi", () => {
    const disruption = new Disruption({
      id: "5",
      startDate: new Date(2020, 0, 1),
      endDate: new Date(2020, 2, 1),
      adjustments: [
        new Adjustment({
          id: "1",
          routeId: "Red",
          sourceLabel: "HarvardAlewife",
        }),
      ],
      daysOfWeek: [new DayOfWeek({ id: "2", dayName: "friday" })],
      exceptions: [new Exception({ id: "3" })],
      tripShortNames: [new TripShortName({ id: "4" })],
    })

    expect(disruption.toJsonApi()).toEqual({
      data: {
        id: "5",
        type: "disruption",
        attributes: {
          start_date: "2020-01-01",
          end_date: "2020-03-01",
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
            data: [{ id: "3", type: "exception", attributes: {} }],
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
      Disruption.fromJsonObject(
        {
          id: "1",
          type: "disruption",
          attributes: { start_date: "2019-12-20", end_date: "2020-01-12" },
        },
        [
          new DayOfWeek({
            id: "1",
            startTime: "20:45:00",
            dayName: "friday",
          }),
        ]
      )
    ).toEqual(
      new Disruption({
        id: "1",
        startDate: new Date("2019-12-20T00:00:00Z"),
        endDate: new Date("2020-01-12T00:00:00Z"),
        adjustments: [],
        daysOfWeek: [
          new DayOfWeek({
            id: "1",
            startTime: "20:45:00",
            dayName: "friday",
          }),
        ],
        exceptions: [],
        tripShortNames: [],
      })
    )
  })

  test("fromJsonObject error wrong format", () => {
    expect(Disruption.fromJsonObject({}, [])).toEqual("error")
  })

  test("fromJsonObject error not an object", () => {
    expect(Disruption.fromJsonObject(5, [])).toEqual("error")
  })

  test("isOfType", () => {
    expect(
      Disruption.isOfType(
        new Disruption({
          adjustments: [],
          daysOfWeek: [],
          exceptions: [],
          tripShortNames: [],
        })
      )
    ).toBe(true)

    expect(Disruption.isOfType(new Exception({}))).toBe(false)
  })
})
