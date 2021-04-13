"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var tripShortName_1 = __importDefault(require("../../src/models/tripShortName"))
var dayOfWeek_1 = __importDefault(require("../../src/models/dayOfWeek"))
describe("TripShortName", function () {
  test("serialize", function () {
    var tsn = new tripShortName_1.default({
      id: "5",
      tripShortName: "1753",
    })
    expect(tsn.toJsonApi()).toEqual({
      data: {
        id: "5",
        type: "trip_short_name",
        attributes: {
          trip_short_name: "1753",
        },
      },
    })
  })
  test("fromJsonObject success", function () {
    expect(
      tripShortName_1.default.fromJsonObject({
        type: "trip_short_name",
        attributes: {},
      })
    ).toEqual(new tripShortName_1.default({}))
  })
  test("fromJsonObject error wrong format", function () {
    expect(tripShortName_1.default.fromJsonObject({})).toEqual("error")
  })
  test("fromJsonObject error not an object", function () {
    expect(tripShortName_1.default.fromJsonObject(5)).toEqual("error")
  })
  test("isOfType identifies if it is", function () {
    expect(
      tripShortName_1.default.isOfType(new tripShortName_1.default({}))
    ).toEqual(true)
    expect(
      tripShortName_1.default.isOfType(
        new dayOfWeek_1.default({ dayName: "monday" })
      )
    ).toEqual(false)
  })
})
