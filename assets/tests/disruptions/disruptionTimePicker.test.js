"use strict"
var __createBinding =
  (this && this.__createBinding) ||
  (Object.create
    ? function (o, m, k, k2) {
        if (k2 === undefined) k2 = k
        Object.defineProperty(o, k2, {
          enumerable: true,
          get: function () {
            return m[k]
          },
        })
      }
    : function (o, m, k, k2) {
        if (k2 === undefined) k2 = k
        o[k2] = m[k]
      })
var __setModuleDefault =
  (this && this.__setModuleDefault) ||
  (Object.create
    ? function (o, v) {
        Object.defineProperty(o, "default", { enumerable: true, value: v })
      }
    : function (o, v) {
        o["default"] = v
      })
var __importStar =
  (this && this.__importStar) ||
  function (mod) {
    if (mod && mod.__esModule) return mod
    var result = {}
    if (mod != null)
      for (var k in mod)
        if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k))
          __createBinding(result, mod, k)
    __setModuleDefault(result, mod)
    return result
  }
Object.defineProperty(exports, "__esModule", { value: true })
var react_1 = require("@testing-library/react")
var React = __importStar(require("react"))
var disruptionTimePicker_1 = require("../../src/disruptions/disruptionTimePicker")
var DisruptionTimePickerWithProps = function (_a) {
  var _b = React.useState([null, null, null, null, null, null, null]),
    disruptionDaysOfWeek = _b[0],
    setDisruptionDaysOfWeek = _b[1]
  return React.createElement(disruptionTimePicker_1.DisruptionTimePicker, {
    disruptionDaysOfWeek: disruptionDaysOfWeek,
    setDisruptionDaysOfWeek: setDisruptionDaysOfWeek,
  })
}
describe("DisruptionTimePicker", function () {
  test("selecting a day of the week enables updating time range", function () {
    var container = react_1.render(
      React.createElement(DisruptionTimePickerWithProps, null)
    ).container
    var mondayCheck = container.querySelector("input#day-of-week-Mon")
    if (!mondayCheck) {
      throw new Error("Monday checkbox not found")
    }
    react_1.fireEvent.click(mondayCheck)
    var mondayStartTypeCheck = container.querySelector(
      "input#time-of-day-start-type-0"
    )
    if (!mondayStartTypeCheck) {
      throw new Error("Monday start time type checkbox not found")
    }
    react_1.fireEvent.click(mondayStartTypeCheck)
    var mondayEndTypeCheck = container.querySelector(
      "input#time-of-day-end-type-0"
    )
    if (!mondayEndTypeCheck) {
      throw new Error("Monday end time type checkbox not found")
    }
    react_1.fireEvent.click(mondayEndTypeCheck)
    var mondayStartHourSelect = container.querySelector(
      "select#time-of-day-start-hour-0"
    )
    if (!mondayStartHourSelect) {
      throw new Error("Monday start hour select not found")
    }
    react_1.fireEvent.change(mondayStartHourSelect, { target: { value: "9" } })
    var mondayEndMinuteSelect = container.querySelector(
      "select#time-of-day-end-minute-0"
    )
    if (!mondayEndMinuteSelect) {
      throw new Error("Monday end minute select not found")
    }
    react_1.fireEvent.change(mondayEndMinuteSelect, { target: { value: "30" } })
    var mondayEndPeriodSelect = container.querySelector(
      "select#time-of-day-end-period-0"
    )
    if (!mondayEndPeriodSelect) {
      throw new Error("Monday end period select not found")
    }
    react_1.fireEvent.change(mondayEndPeriodSelect, { target: { value: "PM" } })
    react_1.fireEvent.click(mondayEndTypeCheck)
    react_1.fireEvent.click(mondayCheck)
    expect(
      container.querySelector("select#time-of-day-start-hour-0")
    ).toBeNull()
    expect(
      container.querySelector("select#time-of-day-start-minute-0")
    ).toBeNull()
    expect(
      container.querySelector("select#time-of-day-start-period-0")
    ).toBeNull()
    expect(container.querySelector("select#time-of-day-end-hour-0")).toBeNull()
    expect(
      container.querySelector("select#time-of-day-end-minute-0")
    ).toBeNull()
    expect(
      container.querySelector("select#time-of-day-end-period-0")
    ).toBeNull()
  })
})
