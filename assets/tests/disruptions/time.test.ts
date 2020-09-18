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
          startTime: "08:30:00",
          endTime: "20:45:00",
          dayName: "wednesday",
        }),
        new DayOfWeek({ endTime: "20:45:00", dayName: "thursday" }),
        new DayOfWeek({ startTime: "00:00:00", dayName: "friday" }),
      ])
    ).toEqual([
      [null, null],
      [{ hour: "11", minute: "30", period: "AM" }, null],
      [
        { hour: "8", minute: "30", period: "AM" },
        { hour: "8", minute: "45", period: "PM" },
      ],
      [null, { hour: "8", minute: "45", period: "PM" }],
      [{ hour: "12", minute: "00", period: "AM" }, null],
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
      [new DayOfWeek({ dayName: "monday" })],
      "Mon, Start of service - End of service",
    ],
    [
      [
        new DayOfWeek({ startTime: "09:30:00", dayName: "tuesday" }),
        new DayOfWeek({ startTime: "09:30:00", dayName: "thursday" }),
      ],
      "Tue, 9:30AM - End of service, Thu, 9:30AM - End of service",
    ],
    [
      [
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "wednesday",
        }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "thursday",
        }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "friday",
        }),
      ],
      "Wed - Fri, 11:30AM - 8:45PM",
    ],

    [
      [
        new DayOfWeek({ startTime: "20:45:00", dayName: "saturday" }),
        new DayOfWeek({ dayName: "sunday" }),
      ],
      "Sat 8:45PM - Sun End of service",
    ],
    [
      [
        new DayOfWeek({ startTime: "20:45:00", dayName: "saturday" }),
        new DayOfWeek({ endTime: "20:45:00", dayName: "sunday" }),
      ],
      "Sat 8:45PM - Sun 8:45PM",
    ],
    [
      [
        new DayOfWeek({ dayName: "saturday" }),
        new DayOfWeek({ dayName: "sunday" }),
      ],
      "Sat - Sun, Start of service - End of service",
    ],
    [
      [
        new DayOfWeek({ dayName: "friday" }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "saturday",
        }),
        new DayOfWeek({ dayName: "sunday" }),
      ],
      "Fri, Start of service - End of service, Sat, 11:30AM - 8:45PM, Sun, Start of service - End of service",
    ],
    [
      [
        new DayOfWeek({ dayName: "friday" }),
        new DayOfWeek({
          startTime: "00:30:00",
          dayName: "saturday",
        }),
        new DayOfWeek({ dayName: "sunday" }),
      ],
      "Fri, Start of service - End of service, Sat, 12:30AM - End of service, Sun, Start of service - End of service",
    ],
    [
      [
        new DayOfWeek({ startTime: "09:00:00", dayName: "monday" }),
        new DayOfWeek({
          startTime: "11:30:00",
          endTime: "18:30:00",
          dayName: "tuesday",
        }),
        new DayOfWeek({ endTime: "20:45:00", dayName: "wednesday" }),
      ],
      "Mon, 9:00AM - End of service, Tue, 11:30AM - 6:30PM, Wed, Start of service - 8:45PM",
    ],
    [
      [
        new DayOfWeek({
          dayName: "sunday",
        }),
        new DayOfWeek({ startTime: "20:45:00", dayName: "friday" }),
        new DayOfWeek({ dayName: "saturday" }),
      ],
      "Fri 8:45PM - Sun End of service",
    ],
  ])("parses days and times correctly", (daysOfWeek, expected) => {
    expect(parseDaysAndTimes(daysOfWeek)).toEqual(expected)
  })
})
