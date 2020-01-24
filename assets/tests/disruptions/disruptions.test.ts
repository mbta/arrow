import {
  formatDisruptionDate,
  indexToDayOfWeekString,
  modeForRoute,
  TransitMode,
} from "../../src/disruptions/disruptions"

describe("formatDisruptionDate", () => {
  test("formats a date", () => {
    const date = new Date(2020, 0, 23)

    expect(formatDisruptionDate(date)).toBe("1/23/2020")
  })

  test("formats a null date to the empty string", () => {
    const date = null

    expect(formatDisruptionDate(date)).toBe("")
  })
})

describe("indexToDayOfWeekString", () => {
  test("returns day of week for a number", () => {
    expect(indexToDayOfWeekString(2)).toEqual("Wednesday")
  })

  test("returns an empty string for out of range number", () => {
    expect(indexToDayOfWeekString(10)).toEqual("")
  })
})

describe("modeForRoute", () => {
  test("returns transit mode for a known route", () => {
    expect(modeForRoute("Red")).toEqual(TransitMode.Subway)
  })

  test("returns subway when unknown route", () => {
    expect(modeForRoute("Unknown")).toEqual(TransitMode.Subway)
  })
})
