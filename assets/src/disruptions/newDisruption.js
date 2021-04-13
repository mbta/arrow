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
exports.NewDisruption = void 0
var React = __importStar(require("react"))
var react_router_dom_1 = require("react-router-dom")
var react_select_1 = __importDefault(require("react-select"))
var button_1 = require("../button")
var Form_1 = __importDefault(require("react-bootstrap/Form"))
var Alert_1 = __importDefault(require("react-bootstrap/Alert"))
var Col_1 = __importDefault(require("react-bootstrap/Col"))
var Row_1 = __importDefault(require("react-bootstrap/Row"))
var api_1 = require("../api")
var jsonApi_1 = require("../jsonApi")
var disruptionRevision_1 = __importDefault(
  require("../models/disruptionRevision")
)
var adjustment_1 = __importDefault(require("../models/adjustment"))
var exception_1 = __importDefault(require("../models/exception"))
var time_1 = require("./time")
var loading_1 = __importDefault(require("../loading"))
var confirmationModal_1 = require("../confirmationModal")
var disruptionTimePicker_1 = require("./disruptionTimePicker")
var disruptionDateRange_1 = require("./disruptionDateRange")
var disruptions_1 = require("./disruptions")
var tripShortName_1 = __importDefault(require("../models/tripShortName"))
var page_1 = require("../page")
var disruptionExceptionDates_1 = require("./disruptionExceptionDates")
var AdjustmentModePicker = function (_a) {
  var transitMode = _a.transitMode,
    setTransitMode = _a.setTransitMode,
    setAdjustments = _a.setAdjustments
  return React.createElement(
    "fieldset",
    null,
    React.createElement(
      Form_1.default.Group,
      { controlId: "formTransitMode" },
      React.createElement(Form_1.default.Check, {
        type: "radio",
        id: "mode-subway",
        label: "Subway",
        name: "mode-radio",
        checked: transitMode === disruptions_1.TransitMode.Subway,
        onChange: function () {
          setAdjustments([])
          setTransitMode(disruptions_1.TransitMode.Subway)
        },
      }),
      React.createElement(Form_1.default.Check, {
        type: "radio",
        id: "mode-commuter-rail",
        label: "Commuter Rail",
        name: "mode-radio",
        checked: transitMode === disruptions_1.TransitMode.CommuterRail,
        onChange: function () {
          setAdjustments([])
          setTransitMode(disruptions_1.TransitMode.CommuterRail)
        },
      })
    )
  )
}
var AdjustmentsPicker = function (_a) {
  var allAdjustments = _a.allAdjustments,
    transitMode = _a.transitMode,
    adjustments = _a.adjustments,
    setAdjustments = _a.setAdjustments
  var modeAdjustmentOptions = React.useMemo(
    function () {
      return allAdjustments
        .filter(function (adjustment) {
          return (
            adjustment.routeId &&
            disruptions_1.modeForRoute(adjustment.routeId) === transitMode
          )
        })
        .map(function (adjustment) {
          return {
            label: adjustment.sourceLabel,
            value: adjustment.id,
            data: adjustment,
          }
        })
    },
    [allAdjustments, transitMode]
  )
  var modeAdjustmentValues = React.useMemo(
    function () {
      return adjustments.map(function (adj) {
        return { label: adj.sourceLabel, value: adj.id, data: adj }
      })
    },
    [adjustments]
  )
  return React.createElement(
    "fieldset",
    null,
    React.createElement(
      Row_1.default,
      null,
      React.createElement(
        Col_1.default,
        { lg: 10 },
        React.createElement(
          Form_1.default.Group,
          null,
          React.createElement(react_select_1.default, {
            inputId: "adjustment-select",
            classNamePrefix: "adjustment-select",
            onChange: function (value) {
              if (Array.isArray(value)) {
                setAdjustments(
                  value.map(function (adj) {
                    return adj.data
                  })
                )
              } else {
                setAdjustments([])
              }
            },
            value: modeAdjustmentValues,
            options: modeAdjustmentOptions,
            isMulti: true,
          })
        )
      )
    )
  )
}
var TripShortNamesForm = function (_a) {
  var tripShortNames = _a.tripShortNames,
    setTripShortNames = _a.setTripShortNames,
    whichTrips = _a.whichTrips,
    setWhichTrips = _a.setWhichTrips
  return React.createElement(
    "div",
    null,
    React.createElement(
      Form_1.default.Group,
      null,
      React.createElement(Form_1.default.Check, {
        type: "radio",
        id: "trips-all",
        label: "All Trips",
        name: "which-trips",
        checked: whichTrips === "all",
        onChange: function () {
          setWhichTrips("all")
          setTripShortNames("")
        },
      }),
      React.createElement(Form_1.default.Check, {
        type: "radio",
        id: "trips-some",
        label: "Some Trips",
        name: "which-trips",
        checked: whichTrips === "some",
        onChange: function () {
          return setWhichTrips("some")
        },
      }),
      whichTrips === "some" &&
        React.createElement(Form_1.default.Control, {
          className: "mb-3",
          id: "trip-short-names",
          type: "text",
          value: tripShortNames,
          onChange: function (e) {
            return setTripShortNames(e.target.value)
          },
          placeholder: "Enter comma separated trip short names ",
        })
    )
  )
}
var disruptionRevisionFromState = function (_a) {
  var adjustments = _a.adjustments,
    fromDate = _a.fromDate,
    toDate = _a.toDate,
    disruptionDaysOfWeek = _a.disruptionDaysOfWeek,
    exceptionDates = _a.exceptionDates,
    tripShortNames = _a.tripShortNames
  return new disruptionRevision_1.default(
    __assign(
      __assign(
        __assign({}, fromDate && { startDate: fromDate }),
        toDate && { endDate: toDate }
      ),
      {
        isActive: true,
        adjustments: adjustments,
        daysOfWeek: time_1.dayOfWeekTimeRangesToDayOfWeeks(
          disruptionDaysOfWeek
        ),
        exceptions: exception_1.default.fromDates(exceptionDates),
        tripShortNames: tripShortNames
          ? tripShortNames.split(/\s*,\s*/).map(function (tripShortName) {
              return new tripShortName_1.default({
                tripShortName: tripShortName,
              })
            })
          : [],
      }
    )
  )
}
var createFn = function (args) {
  return __awaiter(void 0, void 0, void 0, function () {
    var disruptionRevision
    return __generator(this, function (_a) {
      switch (_a.label) {
        case 0:
          disruptionRevision = disruptionRevisionFromState(args)
          return [
            4 /*yield*/,
            api_1.apiSend({
              url: "/api/disruptions",
              method: "POST",
              json: JSON.stringify(disruptionRevision.toJsonApi()),
              successParser: jsonApi_1.toModelObject,
              errorParser: jsonApi_1.parseErrors,
            }),
          ]
        case 1:
          return [2 /*return*/, _a.sent()]
      }
    })
  })
}
var NewDisruption = function (_a) {
  var _b = React.useState([]),
    adjustments = _b[0],
    setAdjustments = _b[1]
  var _c = React.useState(null),
    fromDate = _c[0],
    setFromDate = _c[1]
  var _d = React.useState(null),
    toDate = _d[0],
    setToDate = _d[1]
  var _e = React.useState([null, null, null, null, null, null, null]),
    disruptionDaysOfWeek = _e[0],
    setDisruptionDaysOfWeek = _e[1]
  var _f = React.useState([]),
    exceptionDates = _f[0],
    setExceptionDates = _f[1]
  var _g = React.useState(""),
    tripShortNames = _g[0],
    setTripShortNames = _g[1]
  var _h = React.useState(null),
    allAdjustments = _h[0],
    setAllAdjustments = _h[1]
  var _j = React.useState([]),
    validationErrors = _j[0],
    setValidationErrors = _j[1]
  var _k = React.useState(false),
    doRedirect = _k[0],
    setDoRedirect = _k[1]
  var _l = React.useState(disruptions_1.TransitMode.Subway),
    transitMode = _l[0],
    setTransitMode = _l[1]
  var _m = React.useState("all"),
    whichTrips = _m[0],
    setWhichTrips = _m[1]
  var history = react_router_dom_1.useHistory()
  var createDisruption = React.useCallback(
    function () {
      return __awaiter(void 0, void 0, void 0, function () {
        var result
        return __generator(this, function (_a) {
          switch (_a.label) {
            case 0:
              return [
                4 /*yield*/,
                createFn({
                  adjustments: adjustments,
                  fromDate: fromDate,
                  toDate: toDate,
                  disruptionDaysOfWeek: disruptionDaysOfWeek,
                  exceptionDates: exceptionDates,
                  tripShortNames: tripShortNames,
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
    [
      adjustments,
      fromDate,
      toDate,
      disruptionDaysOfWeek,
      exceptionDates,
      tripShortNames,
    ]
  )
  React.useEffect(function () {
    api_1
      .apiGet({
        url: "/api/adjustments",
        parser: jsonApi_1.toModelObject,
        defaultResult: "error",
      })
      .then(function (result) {
        if (
          Array.isArray(result) &&
          result.every(adjustment_1.default.isOfType)
        ) {
          setAllAdjustments(result)
        } else {
          setAllAdjustments("error")
        }
      })
  }, [])
  if (allAdjustments === null) {
    return React.createElement(loading_1.default, null)
  }
  if (allAdjustments === "error") {
    return React.createElement(
      "div",
      null,
      "Error loading or parsing adjustments."
    )
  }
  if (doRedirect) {
    return React.createElement(react_router_dom_1.Redirect, { to: "/" })
  }
  return React.createElement(
    page_1.Page,
    null,
    React.createElement(
      Col_1.default,
      { lg: 8 },
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
      React.createElement("h1", null, "create new disruption"),
      React.createElement(
        "div",
        null,
        React.createElement("h4", null, "mode"),
        React.createElement(
          "div",
          { className: "pl-4" },
          React.createElement(AdjustmentModePicker, {
            transitMode: transitMode,
            setTransitMode: setTransitMode,
            setAdjustments: setAdjustments,
          })
        )
      ),
      React.createElement(
        "div",
        null,
        React.createElement("h4", null, "adjustment location"),
        React.createElement(
          "div",
          { className: "pl-4" },
          React.createElement(AdjustmentsPicker, {
            adjustments: adjustments,
            setAdjustments: setAdjustments,
            allAdjustments: allAdjustments,
            transitMode: transitMode,
          })
        )
      ),
      transitMode === disruptions_1.TransitMode.CommuterRail &&
        React.createElement(
          "div",
          null,
          React.createElement("h4", null, "trips"),
          React.createElement(
            "div",
            { className: "pl-4" },
            React.createElement(TripShortNamesForm, {
              whichTrips: whichTrips,
              setWhichTrips: setWhichTrips,
              tripShortNames: tripShortNames,
              setTripShortNames: setTripShortNames,
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
              onClick: createDisruption,
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
              history.push("/")
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
exports.NewDisruption = NewDisruption
