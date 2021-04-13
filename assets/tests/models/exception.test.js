"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var exception_1 = __importDefault(require("../../src/models/exception"))
var jsonApi_1 = require("../../src/jsonApi")
var dayOfWeek_1 = __importDefault(require("../../src/models/dayOfWeek"))
describe("Exception", function () {
  test("toJsonApi", function () {
    var ex = new exception_1.default({
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
  test("fromJsonObject success", function () {
    expect(
      exception_1.default.fromJsonObject({
        id: "1",
        type: "exception",
        attributes: { excluded_date: "2020-03-30" },
      })
    ).toEqual(
      new exception_1.default({
        id: "1",
        excludedDate: new Date("2020-03-30T00:00:00Z"),
      })
    )
  })
  test("fromJsonObject error wrong format", function () {
    expect(exception_1.default.fromJsonObject({})).toEqual("error")
  })
  test("fromJsonObject error not an object", function () {
    expect(exception_1.default.fromJsonObject(5)).toEqual("error")
  })
  test("constructs from array of dates", function () {
    expect(exception_1.default.fromDates([new Date("2020-03-31")])).toEqual([
      new exception_1.default({ excludedDate: new Date("2020-03-31") }),
    ])
  })
  test("isOfType identifies if it is", function () {
    expect(
      exception_1.default.isOfType(
        new exception_1.default({
          excludedDate: jsonApi_1.toUTCDate("2020-01-01"),
        })
      )
    ).toEqual(true)
    expect(
      exception_1.default.isOfType(
        new dayOfWeek_1.default({ dayName: "monday" })
      )
    ).toEqual(false)
  })
})
