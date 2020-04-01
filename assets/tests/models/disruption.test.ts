import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Disruption from "../../src/models/disruption"
import Exception from "../../src/models/exception"
import TripShortName from "../../src/models/tripShortName"

describe("Disruption", () => {
  test("toJsonApi", () => {
    const disruption = new Disruption({
      id: 5,
      endDate: new Date(2020, 2, 1),
      startDate: new Date(2020, 0, 1),
      adjustments: [new Adjustment({ id: 1 })],
      daysOfWeek: [new DayOfWeek({ id: 2 })],
      exceptions: [new Exception({ id: 3 })],
      tripShortNames: [new TripShortName({ id: 4 })],
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
          adjustment: {
            data: [{ id: "1", type: "adjustment", attributes: {} }],
          },
          day_of_week: {
            data: [{ id: "2", type: "day_of_week", attributes: {} }],
          },
          exceptions: {
            data: [{ id: "3", type: "exception", attributes: {} }],
          },
          trip_short_name: {
            data: [{ id: "4", type: "trip_short_name", attributes: {} }],
          },
        },
      },
    })
  })

  test("fromJsonApi success", () => {
    expect(Disruption.fromJsonApi({ data: { type: "disruption" } })).toEqual(
      new Disruption({
        adjustments: [],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      })
    )
  })

  test("fromJsonApi error wrong format", () => {
    expect(Disruption.fromJsonApi({})).toEqual("error")
  })

  test("fromJsonApi error not an object", () => {
    expect(Disruption.fromJsonApi(5)).toEqual("error")
  })
})
