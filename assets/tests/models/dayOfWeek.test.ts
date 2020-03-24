import DayOfWeek from "../../src/models/dayOfWeek"

describe("DayOfWeek", () => {
  test("toJsonApi", () => {
    const dow = new DayOfWeek({
      id: "5",
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

  test("fromJsonObject success", () => {
    expect(
      DayOfWeek.fromJsonObject(
        {
          type: "day_of_week",
          attributes: {
            start_time: "20:45:00",
            end_time: undefined,
            monday: true,
            tuesday: false,
            wednesday: false,
            thursday: false,
            friday: false,
            saturday: false,
            sunday: false,
          },
        },
        []
      )
    ).toEqual(new DayOfWeek({ startTime: "20:45:00", day: "monday" }))
  })

  test("fromJsonApi error wrong format", () => {
    expect(DayOfWeek.fromJsonObject({}, [])).toEqual("error")
  })

  test("fromJsonApi error not an object", () => {
    expect(DayOfWeek.fromJsonObject(5, [])).toEqual("error")
  })
})
