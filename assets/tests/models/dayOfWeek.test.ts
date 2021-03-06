import DayOfWeek from "../../src/models/dayOfWeek"
import TripShortName from "../../src/models/tripShortName"

describe("DayOfWeek", () => {
  test("toJsonApi", () => {
    const dow = new DayOfWeek({
      id: "5",
      startTime: "10:00:00",
      endTime: "15:00:00",
      dayName: "monday",
    })

    expect(dow.toJsonApi()).toEqual({
      data: {
        id: "5",
        type: "day_of_week",
        attributes: {
          start_time: "10:00:00",
          end_time: "15:00:00",
          day_name: "monday",
        },
      },
    })
  })

  test("fromJsonObject success", () => {
    expect(
      DayOfWeek.fromJsonObject({
        type: "day_of_week",
        attributes: {
          start_time: "20:45:00",
          day_name: "monday",
        },
      })
    ).toEqual(new DayOfWeek({ startTime: "20:45:00", dayName: "monday" }))
  })

  test("fromJsonObject error with invalid day of week", () => {
    expect(
      DayOfWeek.fromJsonObject({
        type: "day_of_week",
        attributes: {
          start_time: "20:45:00",
          day_name: "not_a_day_of_the_week",
        },
      })
    ).toEqual("error")
  })

  test("fromJsonObject error wrong format", () => {
    expect(DayOfWeek.fromJsonObject({})).toEqual("error")
  })

  test("fromJsonObject error not an object", () => {
    expect(DayOfWeek.fromJsonObject(5)).toEqual("error")
  })

  test("isOfType identifies it", () => {
    expect(DayOfWeek.isOfType(new DayOfWeek({ dayName: "monday" }))).toEqual(
      true
    )
    expect(DayOfWeek.isOfType(new TripShortName({}))).toEqual(false)
  })
})
