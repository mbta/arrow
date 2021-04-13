"use strict"
Object.defineProperty(exports, "__esModule", { value: true })
var disruptions_1 = require("../../src/disruptions/disruptions")
describe("formatDisruptionDate", function () {
  test("formats a date", function () {
    var date = new Date(2020, 0, 23)
    expect(disruptions_1.formatDisruptionDate(date)).toBe("01/23/2020")
  })
  test("formats a null date to the empty string", function () {
    var date = null
    expect(disruptions_1.formatDisruptionDate(date)).toBe("")
  })
})
describe("indexToDayOfWeekString", function () {
  test("returns day of week for a number", function () {
    expect(disruptions_1.indexToDayOfWeekString(2)).toEqual("Wednesday")
  })
  test("returns an empty string for out of range number", function () {
    expect(disruptions_1.indexToDayOfWeekString(10)).toEqual("")
  })
})
describe("modeForRoute", function () {
  test("returns transit mode for a known route", function () {
    expect(disruptions_1.modeForRoute("Red")).toEqual(
      disruptions_1.TransitMode.Subway
    )
  })
  test("returns subway when unknown route", function () {
    expect(disruptions_1.modeForRoute("Unknown")).toEqual(
      disruptions_1.TransitMode.Subway
    )
  })
})
