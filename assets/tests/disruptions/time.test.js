"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var dayOfWeek_1 = __importDefault(require("../../src/models/dayOfWeek"))
var time_1 = require("../../src/disruptions/time")
describe("fromDaysOfWeek", function () {
  test("successful conversion", function () {
    expect(
      time_1.fromDaysOfWeek([
        new dayOfWeek_1.default({ dayName: "monday" }),
        new dayOfWeek_1.default({ startTime: "11:30:00", dayName: "tuesday" }),
        new dayOfWeek_1.default({
          startTime: "08:30:00",
          endTime: "20:45:00",
          dayName: "wednesday",
        }),
        new dayOfWeek_1.default({ endTime: "20:45:00", dayName: "thursday" }),
        new dayOfWeek_1.default({ startTime: "00:00:00", dayName: "friday" }),
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
  test("invalid hours or minutes specified", function () {
    expect(
      time_1.fromDaysOfWeek([
        new dayOfWeek_1.default({ dayName: "monday" }),
        new dayOfWeek_1.default({ startTime: "11:37:00", dayName: "tuesday" }),
        new dayOfWeek_1.default({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "wednesday",
        }),
        new dayOfWeek_1.default({ endTime: "20:45:00", dayName: "thursday" }),
      ])
    ).toEqual("error")
  })
  test("invalid time format", function () {
    expect(
      time_1.fromDaysOfWeek([
        new dayOfWeek_1.default({ dayName: "monday" }),
        new dayOfWeek_1.default({ startTime: "foo", dayName: "tuesday" }),
        new dayOfWeek_1.default({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "wednesday",
        }),
        new dayOfWeek_1.default({ endTime: "20:45:00", dayName: "thursday" }),
      ])
    ).toEqual("error")
  })
})
describe("dayOfWeekTimeRangesToDayOfWeeks", function () {
  test("converts from the one to the other", function () {
    var dayOfWeekTimeRanges = [
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
    expect(time_1.dayOfWeekTimeRangesToDayOfWeeks(dayOfWeekTimeRanges)).toEqual(
      [
        new dayOfWeek_1.default({ dayName: "monday" }),
        new dayOfWeek_1.default({ startTime: "09:30:00", dayName: "tuesday" }),
        new dayOfWeek_1.default({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "wednesday",
        }),
        new dayOfWeek_1.default({ endTime: "20:45:00", dayName: "thursday" }),
        new dayOfWeek_1.default({ endTime: "00:00:00", dayName: "friday" }),
        new dayOfWeek_1.default({ dayName: "saturday" }),
        new dayOfWeek_1.default({ dayName: "sunday" }),
      ]
    )
  })
})
describe("parseDaysAndTimes", function () {
  test.each([
    [
      [new dayOfWeek_1.default({ dayName: "monday" })],
      "Mon, Start of service - End of service",
    ],
    [
      [
        new dayOfWeek_1.default({ startTime: "09:30:00", dayName: "tuesday" }),
        new dayOfWeek_1.default({ startTime: "09:30:00", dayName: "thursday" }),
      ],
      "Tue, 9:30AM - End of service, Thu, 9:30AM - End of service",
    ],
    [
      [
        new dayOfWeek_1.default({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "wednesday",
        }),
        new dayOfWeek_1.default({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "thursday",
        }),
        new dayOfWeek_1.default({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "friday",
        }),
      ],
      "Wed - Fri, 11:30AM - 8:45PM",
    ],
    [
      [
        new dayOfWeek_1.default({ startTime: "20:45:00", dayName: "saturday" }),
        new dayOfWeek_1.default({ dayName: "sunday" }),
      ],
      "Sat 8:45PM - Sun End of service",
    ],
    [
      [
        new dayOfWeek_1.default({ startTime: "20:45:00", dayName: "saturday" }),
        new dayOfWeek_1.default({ endTime: "20:45:00", dayName: "sunday" }),
      ],
      "Sat 8:45PM - Sun 8:45PM",
    ],
    [
      [
        new dayOfWeek_1.default({ dayName: "saturday" }),
        new dayOfWeek_1.default({ dayName: "sunday" }),
      ],
      "Sat - Sun, Start of service - End of service",
    ],
    [
      [
        new dayOfWeek_1.default({ dayName: "friday" }),
        new dayOfWeek_1.default({
          startTime: "11:30:00",
          endTime: "20:45:00",
          dayName: "saturday",
        }),
        new dayOfWeek_1.default({ dayName: "sunday" }),
      ],
      "Fri, Start of service - End of service, Sat, 11:30AM - 8:45PM, Sun, Start of service - End of service",
    ],
    [
      [
        new dayOfWeek_1.default({ dayName: "friday" }),
        new dayOfWeek_1.default({
          startTime: "00:30:00",
          dayName: "saturday",
        }),
        new dayOfWeek_1.default({ dayName: "sunday" }),
      ],
      "Fri, Start of service - End of service, Sat, 12:30AM - End of service, Sun, Start of service - End of service",
    ],
    [
      [
        new dayOfWeek_1.default({ startTime: "09:00:00", dayName: "monday" }),
        new dayOfWeek_1.default({
          startTime: "11:30:00",
          endTime: "18:30:00",
          dayName: "tuesday",
        }),
        new dayOfWeek_1.default({ endTime: "20:45:00", dayName: "wednesday" }),
      ],
      "Mon, 9:00AM - End of service, Tue, 11:30AM - 6:30PM, Wed, Start of service - 8:45PM",
    ],
    [
      [
        new dayOfWeek_1.default({
          dayName: "sunday",
        }),
        new dayOfWeek_1.default({ startTime: "20:45:00", dayName: "friday" }),
        new dayOfWeek_1.default({ dayName: "saturday" }),
      ],
      "Fri 8:45PM - Sun End of service",
    ],
  ])("parses days and times correctly", function (daysOfWeek, expected) {
    expect(time_1.parseDaysAndTimes(daysOfWeek)).toEqual(expected)
  })
})
