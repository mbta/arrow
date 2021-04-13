"use strict"
var __assign =
  (this && this.__assign) ||
  function () {
    __assign =
      Object.assign ||
      function (t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
          s = arguments[i]
          for (var p in s)
            if (Object.prototype.hasOwnProperty.call(s, p)) t[p] = s[p]
        }
        return t
      }
    return __assign.apply(this, arguments)
  }
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
exports.DisruptionTimeRange = exports.DisruptionTimePicker = void 0
var React = __importStar(require("react"))
var Col_1 = __importDefault(require("react-bootstrap/Col"))
var Form_1 = __importDefault(require("react-bootstrap/Form"))
var Row_1 = __importDefault(require("react-bootstrap/Row"))
var checkbox_1 = __importDefault(require("../checkbox"))
var disruptions_1 = require("./disruptions")
var DisruptionDaysOfWeek = function (_a) {
  var disruptionDaysOfWeek = _a.disruptionDaysOfWeek,
    setDisruptionDaysOfWeek = _a.setDisruptionDaysOfWeek
  var handleClick = function (i) {
    var newDisruptionDaysOfWeek = __spreadArray([], disruptionDaysOfWeek)
    if (disruptionDaysOfWeek[i] === null) {
      newDisruptionDaysOfWeek[i] = [null, null]
    } else {
      newDisruptionDaysOfWeek[i] = null
    }
    setDisruptionDaysOfWeek(newDisruptionDaysOfWeek)
  }
  return React.createElement(
    Form_1.default.Group,
    null,
    React.createElement(
      "div",
      { className: "m-forms__sublegend" },
      "Choose day(s) of week"
    ),
    ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map(function (day, i) {
      return React.createElement(
        "span",
        { key: day, className: "m-forms__day-of-week-bubble" },
        React.createElement(Form_1.default.Check, {
          inline: true,
          type: "checkbox",
          id: "day-of-week-" + day,
          label: day,
          name: "day-of-week",
          checked: disruptionDaysOfWeek[i] !== null,
          onChange: function () {
            handleClick(i)
          },
        })
      )
    })
  )
}
var DEFAULT_TIME = {
  hour: "12",
  minute: "00",
  period: "AM",
}
var DisruptionTimeRanges = function (_a) {
  var disruptionDaysOfWeek = _a.disruptionDaysOfWeek,
    setDisruptionDaysOfWeek = _a.setDisruptionDaysOfWeek
  var setTimeRange = function (dow, idx, val) {
    var newDisruptionDaysOfWeek = __spreadArray([], disruptionDaysOfWeek)
    var oldTimeRange = disruptionDaysOfWeek[dow]
    var newTimeRange = __spreadArray([], oldTimeRange)
    var oldTime = oldTimeRange[idx] || DEFAULT_TIME
    var newTime = val && __assign(__assign({}, oldTime), val)
    newTimeRange[idx] = newTime
    newDisruptionDaysOfWeek[dow] = newTimeRange
    setDisruptionDaysOfWeek(newDisruptionDaysOfWeek)
  }
  return React.createElement(
    "div",
    null,
    disruptionDaysOfWeek.map(function (timeRange, index) {
      return React.createElement(DisruptionTimeRange, {
        key: index,
        timeRange: timeRange,
        setTimeRange: setTimeRange,
        dayOfWeekIndex: index,
      })
    })
  )
}
var DisruptionTimeRange = function (_a) {
  var timeRange = _a.timeRange,
    setTimeRange = _a.setTimeRange,
    dayOfWeekIndex = _a.dayOfWeekIndex
  if (timeRange !== null) {
    return React.createElement(
      Form_1.default.Group,
      null,
      React.createElement(
        "strong",
        null,
        disruptions_1.indexToDayOfWeekString(dayOfWeekIndex)
      ),
      React.createElement(
        Row_1.default,
        null,
        React.createElement(
          Col_1.default,
          { xs: 5 },
          React.createElement(
            "div",
            { className: "m-disruption-times__time_of_day_start" },
            React.createElement(TimeOfDaySelector, {
              dayOfWeekIndex: dayOfWeekIndex,
              timeIndex: 0,
              setTimeRange: setTimeRange,
              time: timeRange[0],
            })
          )
        ),
        "until",
        React.createElement(
          Col_1.default,
          { xs: 5 },
          React.createElement(
            "div",
            { className: "m-disruption-times__time_of_day_end" },
            React.createElement(TimeOfDaySelector, {
              dayOfWeekIndex: dayOfWeekIndex,
              timeIndex: 1,
              setTimeRange: setTimeRange,
              time: timeRange[1],
            })
          )
        )
      )
    )
  } else {
    return React.createElement("div", null)
  }
}
exports.DisruptionTimeRange = DisruptionTimeRange
var TimeOfDaySelector = function (_a) {
  var dayOfWeekIndex = _a.dayOfWeekIndex,
    timeIndex = _a.timeIndex,
    time = _a.time,
    setTimeRange = _a.setTimeRange
  var handleChangeTime = function (val) {
    setTimeRange(dayOfWeekIndex, timeIndex, val)
  }
  var startOrEnd = timeIndex === 0 ? "start" : "end"
  return React.createElement(
    "div",
    null,
    React.createElement(
      "div",
      { className: "form-inline align-items-start" },
      React.createElement(
        Form_1.default.Control,
        {
          as: "select",
          id: "time-of-day-" + startOrEnd + "-hour-" + dayOfWeekIndex,
          value: (time === null || time === void 0 ? void 0 : time.hour) || "",
          disabled: !time,
          onChange: function (e) {
            handleChangeTime({
              hour: e.target.value,
            })
          },
        },
        React.createElement("option", { value: "", disabled: true }, "\u2014"),
        ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"].map(
          function (hour) {
            return React.createElement(
              "option",
              {
                key: hour + "-" + dayOfWeekIndex + "-" + timeIndex,
                value: hour,
              },
              hour
            )
          }
        )
      ),
      React.createElement(
        Form_1.default.Control,
        {
          className: "ml-2",
          as: "select",
          id: "time-of-day-" + startOrEnd + "-minute-" + dayOfWeekIndex,
          value:
            (time === null || time === void 0 ? void 0 : time.minute) || "",
          disabled: !time,
          onChange: function (e) {
            return handleChangeTime({
              minute: e.target.value,
            })
          },
        },
        React.createElement("option", { value: "", disabled: true }, "\u2014"),
        ["00", "15", "30", "45"].map(function (minute) {
          return React.createElement(
            "option",
            {
              key: minute + "-" + dayOfWeekIndex + "-" + timeIndex,
              value: minute,
            },
            minute
          )
        })
      ),
      React.createElement(
        Form_1.default.Control,
        {
          className: "ml-2",
          as: "select",
          id: "time-of-day-" + startOrEnd + "-period-" + dayOfWeekIndex,
          key: "period-" + dayOfWeekIndex + "-" + timeIndex,
          value:
            (time === null || time === void 0 ? void 0 : time.period) || "",
          disabled: !time,
          onChange: function (e) {
            return handleChangeTime({
              period: e.target.value,
            })
          },
        },
        React.createElement("option", { value: "", disabled: true }, "\u2014"),
        ["AM", "PM"].map(function (period) {
          return React.createElement(
            "option",
            {
              key: period + "-" + dayOfWeekIndex + "-" + timeIndex,
              value: period,
            },
            period
          )
        })
      )
    ),
    React.createElement(checkbox_1.default, {
      id: "time-of-day-" + startOrEnd + "-type-" + dayOfWeekIndex,
      labelText: timeIndex === 0 ? "Start of service" : "End of service",
      checked: !time,
      onChange: function (e) {
        if (e.target.checked) {
          handleChangeTime(null)
        } else {
          handleChangeTime({})
        }
      },
    })
  )
}
var DisruptionTimePicker = function (_a) {
  var disruptionDaysOfWeek = _a.disruptionDaysOfWeek,
    setDisruptionDaysOfWeek = _a.setDisruptionDaysOfWeek
  return React.createElement(
    "div",
    null,
    React.createElement(DisruptionDaysOfWeek, {
      disruptionDaysOfWeek: disruptionDaysOfWeek,
      setDisruptionDaysOfWeek: setDisruptionDaysOfWeek,
    }),
    React.createElement(DisruptionTimeRanges, {
      disruptionDaysOfWeek: disruptionDaysOfWeek,
      setDisruptionDaysOfWeek: setDisruptionDaysOfWeek,
    })
  )
}
exports.DisruptionTimePicker = DisruptionTimePicker
