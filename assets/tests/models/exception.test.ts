import Exception from "../../src/models/exception"
import { toUTCDate } from "../../src/jsonApi"
import DayOfWeek from "../../src/models/dayOfWeek"

describe("Exception", () => {
  test("toJsonApi", () => {
    const ex = new Exception({
      id: "5",
      excludedDate: new Date(2020, 1, 1),
    })

    expect(ex.toJsonApi()).toEqual({
      data: {
        id: "5",
        type: "exception",
        attributes: {
          excluded_date: "2020-02-01",
        },
      },
    })
  })

  test("fromJsonObject success", () => {
    expect(
      Exception.fromJsonObject({
        id: "1",
        type: "exception",
        attributes: { excluded_date: "2020-03-30" },
      })
    ).toEqual(
      new Exception({ id: "1", excludedDate: new Date("2020-03-30T00:00:00Z") })
    )
  })

  test("fromJsonObject error wrong format", () => {
    expect(Exception.fromJsonObject({})).toEqual("error")
  })

  test("fromJsonObject error not an object", () => {
    expect(Exception.fromJsonObject(5)).toEqual("error")
  })

  test("constructs from array of dates", () => {
    expect(Exception.fromDates([new Date("2020-03-31")])).toEqual([
      new Exception({ excludedDate: new Date("2020-03-31") }),
    ])
  })

  test("isOfType identifies if it is", () => {
    expect(
      Exception.isOfType(
        new Exception({ excludedDate: toUTCDate("2020-01-01") })
      )
    ).toEqual(true)

    expect(Exception.isOfType(new DayOfWeek({ dayName: "monday" }))).toEqual(
      false
    )
  })
})
