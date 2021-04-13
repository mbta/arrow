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
var disruptionDateRange_1 = require("../../src/disruptions/disruptionDateRange")
var DisruptionDateRangeWithProps = function (_a) {
  var _b = React.useState(null),
    fromDate = _b[0],
    setFromDate = _b[1]
  var _c = React.useState(null),
    toDate = _c[0],
    setToDate = _c[1]
  return React.createElement(disruptionDateRange_1.DisruptionDateRange, {
    fromDate: fromDate,
    setFromDate: setFromDate,
    toDate: toDate,
    setToDate: setToDate,
  })
}
describe("DisruptionDateRange", function () {
  test("can set the date range", function () {
    var container = react_1.render(
      React.createElement(DisruptionDateRangeWithProps, null)
    ).container
    var rangeStartInput = container.querySelector(
      "#disruption-date-range-start"
    )
    if (!rangeStartInput) {
      throw new Error("range start input not found")
    }
    react_1.fireEvent.change(rangeStartInput, {
      target: { value: "01/01/2020" },
    })
    var rangeEndInput = container.querySelector("#disruption-date-range-end")
    if (!rangeEndInput) {
      throw new Error("range end input not found")
    }
    react_1.fireEvent.change(rangeEndInput, { target: { value: "01/02/2020" } })
    expect(
      container.querySelector("#disruption-date-range-start").value
    ).toEqual("01/01/2020")
    expect(container.querySelector("#disruption-date-range-end").value).toEqual(
      "01/02/2020"
    )
  })
})
