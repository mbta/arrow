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
var __spreadArray =
  (this && this.__spreadArray) ||
  function (to, from) {
    for (var i = 0, il = from.length, j = to.length; i < il; i++, j++)
      to[j] = from[i]
    return to
  }
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
exports.DisruptionExceptionDates = void 0
var React = __importStar(require("react"))
var Form_1 = __importDefault(require("react-bootstrap/Form"))
var Row_1 = __importDefault(require("react-bootstrap/Row"))
var checkbox_1 = __importDefault(require("../checkbox"))
var datePicker_1 = __importDefault(require("../datePicker"))
var DisruptionExceptionDateList = function (_a) {
  var exceptionDates = _a.exceptionDates,
    setExceptionDates = _a.setExceptionDates,
    isAddingDate = _a.isAddingDate,
    setIsAddingDate = _a.setIsAddingDate
  var dates = isAddingDate
    ? __spreadArray(__spreadArray([], exceptionDates), [null])
    : exceptionDates
  return React.createElement(
    Form_1.default.Group,
    null,
    dates.map(function (date, index) {
      return React.createElement(
        "div",
        {
          id: "date-exception-row-" + index,
          key: "date-exception-row-" + index,
          "data-date-exception-new": !date,
        },
        React.createElement(
          Row_1.default,
          { className: "mb-2 ml-0" },
          React.createElement(datePicker_1.default, {
            autoComplete: "off",
            selected: date,
            onChange: function (newDate) {
              if (newDate !== null && !Array.isArray(newDate)) {
                setExceptionDates(
                  exceptionDates
                    .slice(0, index)
                    .concat([newDate])
                    .concat(exceptionDates.slice(index + 1))
                )
              } else {
                setExceptionDates(
                  exceptionDates
                    .slice(0, index)
                    .concat(exceptionDates.slice(index + 1))
                )
              }
              setIsAddingDate(false)
            },
          }),
          React.createElement(
            "button",
            {
              className: "btn btn-link",
              "data-testid": "remove-exception-date",
              onClick: function () {
                if (date) {
                  var newExceptionDates = exceptionDates
                    .slice(0, index)
                    .concat(exceptionDates.slice(index + 1))
                  setExceptionDates(newExceptionDates)
                } else {
                  setIsAddingDate(false)
                }
              },
            },
            "\uE161"
          )
        )
      )
    }),
    !isAddingDate &&
      React.createElement(
        Row_1.default,
        { key: "date-exception-add-link" },
        React.createElement(
          "button",
          {
            className: "btn btn-link",
            id: "date-exception-add-link",
            onClick: function () {
              return setIsAddingDate(true)
            },
          },
          "\uE15F add an exception"
        )
      )
  )
}
var DisruptionExceptionDates = function (_a) {
  var exceptionDates = _a.exceptionDates,
    setExceptionDates = _a.setExceptionDates
  var _b = React.useState(false),
    isAddingDate = _b[0],
    setIsAddingDate = _b[1]
  var checkboxIsChecked = exceptionDates.length !== 0 || isAddingDate
  return React.createElement(
    "div",
    null,
    React.createElement(
      Form_1.default.Group,
      null,
      React.createElement(checkbox_1.default, {
        id: "exception-add",
        labelText: "Include exceptions",
        checked: checkboxIsChecked,
        onChange: function () {
          setExceptionDates([])
          setIsAddingDate(!checkboxIsChecked)
        },
      })
    ),
    exceptionDates.length !== 0 || isAddingDate
      ? React.createElement(DisruptionExceptionDateList, {
          exceptionDates: exceptionDates,
          setExceptionDates: setExceptionDates,
          isAddingDate: isAddingDate,
          setIsAddingDate: setIsAddingDate,
        })
      : null
  )
}
exports.DisruptionExceptionDates = DisruptionExceptionDates
