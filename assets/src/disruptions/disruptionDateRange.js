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
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
exports.DisruptionDateRange = void 0
var React = __importStar(require("react"))
var Col_1 = __importDefault(require("react-bootstrap/Col"))
var Form_1 = __importDefault(require("react-bootstrap/Form"))
var Row_1 = __importDefault(require("react-bootstrap/Row"))
var datePicker_1 = __importDefault(require("../datePicker"))
var DisruptionDateRange = function (_a) {
  var fromDate = _a.fromDate,
    setFromDate = _a.setFromDate,
    toDate = _a.toDate,
    setToDate = _a.setToDate
  return React.createElement(
    Form_1.default.Group,
    null,
    React.createElement(
      Row_1.default,
      null,
      React.createElement(
        Col_1.default,
        { lg: 4 },
        React.createElement(
          "div",
          null,
          React.createElement("strong", null, "start")
        ),
        React.createElement(datePicker_1.default, {
          id: "disruption-date-range-start",
          autoComplete: "off",
          selected: fromDate,
          onChange: function (date) {
            if (!Array.isArray(date)) {
              setFromDate(date)
            }
          },
        })
      ),
      React.createElement(
        Col_1.default,
        null,
        React.createElement(
          "div",
          null,
          React.createElement("strong", null, "end")
        ),
        React.createElement(datePicker_1.default, {
          id: "disruption-date-range-end",
          autoComplete: "off",
          selected: toDate,
          onChange: function (date) {
            if (!Array.isArray(date)) {
              setToDate(date)
            }
          },
        })
      )
    )
  )
}
exports.DisruptionDateRange = DisruptionDateRange
