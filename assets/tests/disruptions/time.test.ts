import DayOfWeek from "../../src/models/dayOfWeek"
import {
  fromDaysOfWeek,
  dayOfWeekTimeRangesToDayOfWeeks,
  DayOfWeekTimeRanges,
} from "../../src/disruptions/time"

describe("fromDaysOfWeek", () => {
  test("successful conversion", () => {
    expect(
      fromDaysOfWeek([
        new DayOfWeek({ day: "monday" }),
        new DayOfWeek({ startTime: "11:30:00", day: "tuesday" }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          day: "wednesday",
        }),
        new DayOfWeek({ endTime: "20:45:00", day: "thursday" }),
      ])
    ).toEqual([
      [null, null],
      [{ hour: "11", minute: "30", period: "AM" }, null],
      [
        { hour: "11", minute: "30", period: "AM" },
        { hour: "8", minute: "45", period: "PM" },
      ],
      [null, { hour: "8", minute: "45", period: "PM" }],
      null,
      null,
      null,
    ])
  })

  test("invalid hours or minutes specified", () => {
    expect(
      fromDaysOfWeek([
        new DayOfWeek({ day: "monday" }),
        new DayOfWeek({ startTime: "11:37:00", day: "tuesday" }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          day: "wednesday",
        }),
        new DayOfWeek({ endTime: "20:45:00", day: "thursday" }),
      ])
    ).toEqual("error")
  })

  test("invalid time format", () => {
    expect(
      fromDaysOfWeek([
        new DayOfWeek({ day: "monday" }),
        new DayOfWeek({ startTime: "foo", day: "tuesday" }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          day: "wednesday",
        }),
        new DayOfWeek({ endTime: "20:45:00", day: "thursday" }),
      ])
    ).toEqual("error")
  })
})

describe("dayOfWeekTimeRangesToDayOfWeeks", () => {
  test("converts from the one to the other", () => {
    const dayOfWeekTimeRanges: DayOfWeekTimeRanges = [
      [null, null],
      [{ hour: "9", minute: "30", period: "AM" }, null],
      [
        { hour: "11", minute: "30", period: "AM" },
        { hour: "8", minute: "45", period: "PM" },
      ],
      [null, { hour: "8", minute: "45", period: "PM" }],
      [null, { hour: "12", minute: "00", period: "AM" }],
      [null, null],
      [null, null],
    ]

    expect(dayOfWeekTimeRangesToDayOfWeeks(dayOfWeekTimeRanges)).toEqual([
      new DayOfWeek({ day: "monday" }),
      new DayOfWeek({ startTime: "09:30:00", day: "tuesday" }),
      new DayOfWeek({
        startTime: "11:30:00",
        endTime: "20:45:00",
        day: "wednesday",
      }),
      new DayOfWeek({ endTime: "20:45:00", day: "thursday" }),
      new DayOfWeek({ endTime: "00:00:00", day: "friday" }),
      new DayOfWeek({ day: "saturday" }),
      new DayOfWeek({ day: "sunday" }),
    ])
  })
})
