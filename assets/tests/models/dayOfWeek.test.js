"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var dayOfWeek_1 = __importDefault(require("../../src/models/dayOfWeek"))
var tripShortName_1 = __importDefault(require("../../src/models/tripShortName"))
describe("DayOfWeek", function () {
  test("toJsonApi", function () {
    var dow = new dayOfWeek_1.default({
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
  test("fromJsonObject success", function () {
    expect(
      dayOfWeek_1.default.fromJsonObject({
        type: "day_of_week",
        attributes: {
          start_time: "20:45:00",
          day_name: "monday",
        },
      })
    ).toEqual(
      new dayOfWeek_1.default({ startTime: "20:45:00", dayName: "monday" })
    )
  })
  test("fromJsonObject error with invalid day of week", function () {
    expect(
      dayOfWeek_1.default.fromJsonObject({
        type: "day_of_week",
        attributes: {
          start_time: "20:45:00",
          day_name: "not_a_day_of_the_week",
        },
      })
    ).toEqual("error")
  })
  test("fromJsonObject error wrong format", function () {
    expect(dayOfWeek_1.default.fromJsonObject({})).toEqual("error")
  })
  test("fromJsonObject error not an object", function () {
    expect(dayOfWeek_1.default.fromJsonObject(5)).toEqual("error")
  })
  test("isOfType identifies it", function () {
    expect(
      dayOfWeek_1.default.isOfType(
        new dayOfWeek_1.default({ dayName: "monday" })
      )
    ).toEqual(true)
    expect(
      dayOfWeek_1.default.isOfType(new tripShortName_1.default({}))
    ).toEqual(false)
  })
})
