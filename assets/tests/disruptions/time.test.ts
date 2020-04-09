import DayOfWeek from "../../src/models/dayOfWeek"
import {
  fromDaysOfWeek,
  dayOfWeekTimeRangesToDayOfWeeks,
  DayOfWeekTimeRanges,
  parseDaysAndTimes,
} from "../../src/disruptions/time"

describe("fromDaysOfWeek", () => {
  test("successful conversion", () => {
    expect(
      fromDaysOfWeek([
        new DayOfWeek({ dayName: "monday" }),
        new DayOfWeek({ startTime: "11:30:00", dayName: "tuesday" }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "wednesday",
        }),
        new DayOfWeek({ endTime: "20:45:00", dayName: "thursday" }),
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
        new DayOfWeek({ dayName: "monday" }),
        new DayOfWeek({ startTime: "11:37:00", dayName: "tuesday" }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "wednesday",
        }),
        new DayOfWeek({ endTime: "20:45:00", dayName: "thursday" }),
      ])
    ).toEqual("error")
  })

  test("invalid time format", () => {
    expect(
      fromDaysOfWeek([
        new DayOfWeek({ dayName: "monday" }),
        new DayOfWeek({ startTime: "foo", dayName: "tuesday" }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "wednesday",
        }),
        new DayOfWeek({ endTime: "20:45:00", dayName: "thursday" }),
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
      new DayOfWeek({ dayName: "monday" }),
      new DayOfWeek({ startTime: "09:30:00", dayName: "tuesday" }),
      new DayOfWeek({
        startTime: "11:30:00",
        endTime: "20:45:00",
        dayName: "wednesday",
      }),
      new DayOfWeek({ endTime: "20:45:00", dayName: "thursday" }),
      new DayOfWeek({ endTime: "00:00:00", dayName: "friday" }),
      new DayOfWeek({ dayName: "saturday" }),
      new DayOfWeek({ dayName: "sunday" }),
    ])
  })
})

describe("parseDaysAndTimes", () => {
  test.each([
    [
      [new DayOfWeek({ day: "monday" })],
      "Monday, Start of service - End of service",
    ],
    [
      [
        new DayOfWeek({ startTime: "09:30:00", day: "tuesday" }),
        new DayOfWeek({ startTime: "09:30:00", day: "thursday" }),
      ],
      "Tuesday, 9:30AM - End of service, Thursday, 9:30AM - End of service",
    ],
    [
      [
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          day: "wednesday",
        }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          day: "thursday",
        }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          day: "friday",
        }),
      ],
      "Wednesday - Friday, 11:30AM - 8:45PM",
    ],

    [
      [
        new DayOfWeek({ startTime: "20:45:00", day: "saturday" }),
        new DayOfWeek({ day: "sunday" }),
      ],
      "Saturday 8:45PM - Sunday End of service",
    ],
    [
      [
        new DayOfWeek({ startTime: "20:45:00", day: "saturday" }),
        new DayOfWeek({ endTime: "20:45:00", day: "sunday" }),
      ],
      "Saturday 8:45PM - Sunday 8:45PM",
    ],
    [
      [new DayOfWeek({ day: "saturday" }), new DayOfWeek({ day: "sunday" })],
      "Saturday - Sunday, Start of service - End of service",
    ],
    [
      [
        new DayOfWeek({ day: "friday" }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          day: "saturday",
        }),
        new DayOfWeek({ day: "sunday" }),
      ],
      "Friday, Start of service - End of service, Saturday, 11:30AM - 8:45PM, Sunday, Start of service - End of service",
    ],
    [
      [
        new DayOfWeek({ day: "friday" }),
        new DayOfWeek({
          startTime: "11:30:00",
          day: "saturday",
        }),
        new DayOfWeek({ day: "sunday" }),
      ],
      "Friday, Start of service - End of service, Saturday, 11:30AM - End of service, Sunday, Start of service - End of service",
    ],
    [
      [
        new DayOfWeek({ startTime: "09:00:00", day: "monday", }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "18:30:00",
          day: "tuesday",
        }),
        new DayOfWeek({ day: "wednesday", endTime: "20:45:00" }),
      ],
      "Monday, 9:00AM - End of service, Tuesday, 11:30AM - 6:30PM, Wednesday, Start of service - 8:45PM",
    ],
  ])("parses days and times correctly", (daysOfWeek, expected) => {
    expect(parseDaysAndTimes(daysOfWeek)).toEqual(expected)
  })
})
