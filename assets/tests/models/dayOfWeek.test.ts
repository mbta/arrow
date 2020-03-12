import DayOfWeek from "../../src/models/dayOfWeek"

describe("DayOfWeek", () => {
  test("toJsonApi", () => {
    const dow = new DayOfWeek({
      id: 5,
      startTime: "10:00:00",
      endTime: "15:00:00",
      day: "monday",
    })

    expect(dow.toJsonApi()).toEqual({
      data: {
        id: "5",
        type: "day_of_week",
        attributes: {
          start_time: "10:00:00",
          end_time: "15:00:00",
          day: "monday",
        },
      },
    })
  })

  test("fromJsonApi success", () => {
    expect(DayOfWeek.fromJsonApi({ data: { type: "day_of_week" } })).toEqual(
      new DayOfWeek({})
    )
  })

  test("fromJsonApi error wrong format", () => {
    expect(DayOfWeek.fromJsonApi({})).toEqual("error")
  })

  test("fromJsonApi error not an object", () => {
    expect(DayOfWeek.fromJsonApi(5)).toEqual("error")
  })
})
