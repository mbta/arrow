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
var __awaiter =
  (this && this.__awaiter) ||
  function (thisArg, _arguments, P, generator) {
    function adopt(value) {
      return value instanceof P
        ? value
        : new P(function (resolve) {
            resolve(value)
          })
    }
    return new (P || (P = Promise))(function (resolve, reject) {
      function fulfilled(value) {
        try {
          step(generator.next(value))
        } catch (e) {
          reject(e)
        }
      }
      function rejected(value) {
        try {
          step(generator["throw"](value))
        } catch (e) {
          reject(e)
        }
      }
      function step(result) {
        result.done
          ? resolve(result.value)
          : adopt(result.value).then(fulfilled, rejected)
      }
      step((generator = generator.apply(thisArg, _arguments || [])).next())
    })
  }
var __generator =
  (this && this.__generator) ||
  function (thisArg, body) {
    var _ = {
        label: 0,
        sent: function () {
          if (t[0] & 1) throw t[1]
          return t[1]
        },
        trys: [],
        ops: [],
      },
      f,
      y,
      t,
      g
    return (
      (g = { next: verb(0), throw: verb(1), return: verb(2) }),
      typeof Symbol === "function" &&
        (g[Symbol.iterator] = function () {
          return this
        }),
      g
    )
    function verb(n) {
      return function (v) {
        return step([n, v])
      }
    }
    function step(op) {
      if (f) throw new TypeError("Generator is already executing.")
      while (_)
        try {
          if (
            ((f = 1),
            y &&
              (t =
                op[0] & 2
                  ? y["return"]
                  : op[0]
                  ? y["throw"] || ((t = y["return"]) && t.call(y), 0)
                  : y.next) &&
              !(t = t.call(y, op[1])).done)
          )
            return t
          if (((y = 0), t)) op = [op[0] & 2, t.value]
          switch (op[0]) {
            case 0:
            case 1:
              t = op
              break
            case 4:
              _.label++
              return { value: op[1], done: false }
            case 5:
              _.label++
              y = op[1]
              op = [0]
              continue
            case 7:
              op = _.ops.pop()
              _.trys.pop()
              continue
            default:
              if (
                !((t = _.trys), (t = t.length > 0 && t[t.length - 1])) &&
                (op[0] === 6 || op[0] === 2)
              ) {
                _ = 0
                continue
              }
              if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) {
                _.label = op[1]
                break
              }
              if (op[0] === 6 && _.label < t[1]) {
                _.label = t[1]
                t = op
                break
              }
              if (t && _.label < t[2]) {
                _.label = t[2]
                _.ops.push(op)
                break
              }
              if (t[2]) _.ops.pop()
              _.trys.pop()
              continue
          }
          op = body.call(thisArg, _)
        } catch (e) {
          op = [6, e]
          y = 0
        } finally {
          f = t = 0
        }
      if (op[0] & 5) throw op[1]
      return { value: op[0] ? op[1] : void 0, done: true }
    }
  }
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var React = __importStar(require("react"))
var Alert_1 = __importDefault(require("react-bootstrap/Alert"))
var button_1 = require("../button")
var Col_1 = __importDefault(require("react-bootstrap/Col"))
var react_router_dom_1 = require("react-router-dom")
var api_1 = require("../api")
var loading_1 = __importDefault(require("../loading"))
var adjustmentSummary_1 = require("./adjustmentSummary")
var time_1 = require("./time")
var disruptionTimePicker_1 = require("./disruptionTimePicker")
var disruption_1 = __importStar(require("../models/disruption"))
var disruptionRevision_1 = __importDefault(
  require("../models/disruptionRevision")
)
var exception_1 = __importDefault(require("../models/exception"))
var jsonApi_1 = require("../jsonApi")
var dayOfWeek_1 = __importDefault(require("../models/dayOfWeek"))
var page_1 = require("../page")
var confirmationModal_1 = require("../confirmationModal")
var disruptionExceptionDates_1 = require("./disruptionExceptionDates")
var disruptionDateRange_1 = require("./disruptionDateRange")
var EditDisruption = function (_a) {
  var match = _a.match
  var _b = React.useState(null),
    disruptionRevision = _b[0],
    setDisruptionRevision = _b[1]
  var _c = React.useState([]),
    validationErrors = _c[0],
    setValidationErrors = _c[1]
  var _d = React.useState(false),
    doRedirect = _d[0],
    setDoRedirect = _d[1]
  var saveDisruption = React.useCallback(
    function () {
      return __awaiter(void 0, void 0, void 0, function () {
        var result
        return __generator(this, function (_a) {
          switch (_a.label) {
            case 0:
              return [
                4 /*yield*/,
                api_1.apiSend({
                  url:
                    "/api/disruptions/" + encodeURIComponent(match.params.id),
                  method: "PATCH",
                  json: JSON.stringify(disruptionRevision.toJsonApi()),
                  successParser: jsonApi_1.toModelObject,
                  errorParser: jsonApi_1.parseErrors,
                }),
              ]
            case 1:
              result = _a.sent()
              if (result.ok) {
                setDoRedirect(true)
              } else if (result.error) {
                setValidationErrors(result.error)
              }
              return [2 /*return*/]
          }
        })
      })
    },
    [disruptionRevision, match]
  )
  React.useEffect(
    function () {
      api_1
        .apiGet({
          url: "/api/disruptions/" + encodeURIComponent(match.params.id),
          parser: jsonApi_1.toModelObject,
          defaultResult: "error",
        })
        .then(function (result) {
          if (result instanceof disruption_1.default) {
            var revisionFromResponse = disruption_1.default.revisionFromDisruptionForView(
              result,
              disruption_1.DisruptionView.Draft
            )
            if (typeof revisionFromResponse !== "undefined") {
              setDisruptionRevision(revisionFromResponse)
            }
          } else {
            setDisruptionRevision("error")
          }
        })
    },
    [match.params.id]
  )
  if (doRedirect) {
    return React.createElement(react_router_dom_1.Redirect, {
      to: "/disruptions/" + encodeURIComponent(match.params.id) + "?v=draft",
    })
  }
  if (disruptionRevision === "error") {
    return React.createElement("div", null, "Error loading disruption.")
  }
  if (disruptionRevision === null) {
    return React.createElement(loading_1.default, null)
  }
  var disruptionDaysOfWeek = time_1.fromDaysOfWeek(
    disruptionRevision.daysOfWeek
  )
  if (disruptionDaysOfWeek === "error") {
    return React.createElement(
      "div",
      null,
      "Error parsing day of week information."
    )
  }
  var exceptionDates = disruptionRevision.exceptions
    .map(function (exception) {
      return exception.excludedDate
    })
    .filter(function (maybeDate) {
      return typeof maybeDate !== "undefined"
    })
  return React.createElement(EditDisruptionForm, {
    disruptionId: match.params.id,
    adjustments: disruptionRevision.adjustments,
    fromDate: disruptionRevision.startDate || null,
    setFromDate: function (newDate) {
      var newDisruptionRevision = new disruptionRevision_1.default(
        __assign({}, disruptionRevision)
      )
      if (newDate) {
        newDisruptionRevision.startDate = newDate
      } else {
        delete newDisruptionRevision.startDate
      }
      setDisruptionRevision(newDisruptionRevision)
    },
    toDate: disruptionRevision.endDate || null,
    setToDate: function (newDate) {
      var newDisruptionRevision = new disruptionRevision_1.default(
        __assign({}, disruptionRevision)
      )
      if (newDate) {
        newDisruptionRevision.endDate = newDate
      } else {
        delete newDisruptionRevision.endDate
      }
      setDisruptionRevision(newDisruptionRevision)
    },
    exceptionDates: exceptionDates,
    setExceptionDates: setExceptionDatesForDisruption(
      new disruptionRevision_1.default(__assign({}, disruptionRevision)),
      setDisruptionRevision
    ),
    disruptionDaysOfWeek: disruptionDaysOfWeek,
    setDisruptionDaysOfWeek: setDisruptionDaysOfWeekForDisruption(
      new disruptionRevision_1.default(__assign({}, disruptionRevision)),
      setDisruptionRevision
    ),
    saveDisruption: saveDisruption,
    validationErrors: validationErrors,
  })
}
var setExceptionDatesForDisruption = function (
  disruptionRevision,
  setDisruptionRevision
) {
  return function (newExceptionDates) {
    var newExceptionDatesAsTimes = newExceptionDates.map(function (date) {
      return date.getTime()
    })
    var currentExceptionDates = disruptionRevision.exceptions
      .map(function (exception) {
        return exception.excludedDate
      })
      .filter(function (maybeDate) {
        return maybeDate instanceof Date
      })
      .map(function (date) {
        return date.getTime()
      })
    var addedDates = newExceptionDatesAsTimes.filter(function (date) {
      return !currentExceptionDates.includes(date)
    })
    var removedDates = currentExceptionDates.filter(function (date) {
      return !newExceptionDatesAsTimes.includes(date)
    })
    // Trim out the removed dates
    disruptionRevision.exceptions = disruptionRevision.exceptions.filter(
      function (exception) {
        return (
          exception.excludedDate instanceof Date &&
          !removedDates.includes(exception.excludedDate.getTime())
        )
      }
    )
    // Add in added dates
    disruptionRevision.exceptions = disruptionRevision.exceptions.concat(
      addedDates.map(function (date) {
        return new exception_1.default({ excludedDate: new Date(date) })
      })
    )
    setDisruptionRevision(disruptionRevision)
  }
}
var setDisruptionDaysOfWeekForDisruption = function (
  disruptionRevision,
  setDisruptionRevision
) {
  return function (newDisruptionDaysOfWeek) {
    var _loop_1 = function (i) {
      if (newDisruptionDaysOfWeek[i] === null) {
        disruptionRevision.daysOfWeek = disruptionRevision.daysOfWeek.filter(
          function (dayOfWeek) {
            return dayOfWeek.dayName !== time_1.ixToDayName(i)
          }
        )
      } else {
        var startTime = void 0
        if (newDisruptionDaysOfWeek[i][0]) {
          startTime = time_1.timeToString(newDisruptionDaysOfWeek[i][0])
        }
        var endTime = void 0
        if (newDisruptionDaysOfWeek[i][1]) {
          endTime = time_1.timeToString(newDisruptionDaysOfWeek[i][1])
        }
        var dayOfWeekIndex = disruptionRevision.daysOfWeek.findIndex(function (
          dayOfWeek
        ) {
          return dayOfWeek.dayName === time_1.ixToDayName(i)
        })
        if (dayOfWeekIndex === -1) {
          disruptionRevision.daysOfWeek = disruptionRevision.daysOfWeek.concat([
            new dayOfWeek_1.default({
              startTime: startTime,
              endTime: endTime,
              dayName: time_1.ixToDayName(i),
            }),
          ])
        } else {
          disruptionRevision.daysOfWeek[dayOfWeekIndex].startTime = startTime
          disruptionRevision.daysOfWeek[dayOfWeekIndex].endTime = endTime
        }
      }
    }
    for (var i = 0; i < newDisruptionDaysOfWeek.length; i++) {
      _loop_1(i)
    }
    setDisruptionRevision(disruptionRevision)
  }
}
var EditDisruptionForm = function (_a) {
  var disruptionId = _a.disruptionId,
    adjustments = _a.adjustments,
    fromDate = _a.fromDate,
    setFromDate = _a.setFromDate,
    toDate = _a.toDate,
    setToDate = _a.setToDate,
    exceptionDates = _a.exceptionDates,
    setExceptionDates = _a.setExceptionDates,
    disruptionDaysOfWeek = _a.disruptionDaysOfWeek,
    setDisruptionDaysOfWeek = _a.setDisruptionDaysOfWeek,
    saveDisruption = _a.saveDisruption,
    validationErrors = _a.validationErrors
  var history = react_router_dom_1.useHistory()
  return React.createElement(
    page_1.Page,
    null,
    React.createElement(
      Col_1.default,
      { lg: 8 },
      React.createElement("hr", null),
      React.createElement(
        "h1",
        null,
        "edit disruption",
        " ",
        React.createElement(
          "span",
          { className: "m-disruption-form__header-id" },
          "ID"
        ),
        " ",
        React.createElement(
          "span",
          { className: "m-disruption-form__header-num" },
          disruptionId
        )
      ),
      React.createElement(adjustmentSummary_1.AdjustmentSummary, {
        adjustments: adjustments,
      }),
      React.createElement("hr", null),
      validationErrors.length > 0 &&
        React.createElement(
          Alert_1.default,
          { variant: "danger" },
          React.createElement(
            "ul",
            null,
            validationErrors.map(function (err) {
              return React.createElement("li", { key: err }, err, " ")
            })
          )
        ),
      React.createElement(
        "div",
        null,
        React.createElement("h4", null, "date range"),
        React.createElement(
          "div",
          { className: "pl-4" },
          React.createElement(disruptionDateRange_1.DisruptionDateRange, {
            fromDate: fromDate,
            setFromDate: setFromDate,
            toDate: toDate,
            setToDate: setToDate,
          })
        )
      ),
      React.createElement(
        "div",
        null,
        React.createElement(
          "fieldset",
          null,
          React.createElement("h4", null, "time period"),
          React.createElement(
            "div",
            { className: "pl-4" },
            React.createElement(disruptionTimePicker_1.DisruptionTimePicker, {
              disruptionDaysOfWeek: disruptionDaysOfWeek,
              setDisruptionDaysOfWeek: setDisruptionDaysOfWeek,
            })
          )
        )
      ),
      React.createElement(
        "div",
        null,
        React.createElement("h4", null, "exceptions"),
        React.createElement(
          "div",
          { className: "pl-4" },
          React.createElement(
            disruptionExceptionDates_1.DisruptionExceptionDates,
            {
              exceptionDates: exceptionDates,
              setExceptionDates: setExceptionDates,
            }
          )
        )
      ),
      React.createElement("hr", { className: "light-hr" }),
      React.createElement(
        "div",
        { className: "d-flex justify-content-center" },
        React.createElement(
          "div",
          { className: "w-25 mr-2" },
          React.createElement(
            button_1.PrimaryButton,
            {
              className: "w-100",
              filled: true,
              onClick: saveDisruption,
              id: "save-disruption-button",
            },
            "save"
          )
        ),
        React.createElement(
          "div",
          { className: "w-25 ml-2" },
          React.createElement(confirmationModal_1.ConfirmationModal, {
            confirmationText:
              "Any changes you've made to this disruption will not be saved as a draft.",
            confirmationButtonText: "discard changes",
            cancelButtonText: "keep editing",
            onClickConfirm: function () {
              history.goBack()
            },
            Component: React.createElement(
              button_1.PrimaryButton,
              { id: "cancel-disruption-button", className: "w-100" },
              "cancel"
            ),
          })
        )
      )
    )
  )
}
exports.default = EditDisruption
