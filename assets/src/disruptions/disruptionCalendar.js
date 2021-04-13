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
exports.dayNameToInt = exports.disruptionsToCalendarEvents = exports.DisruptionCalendar = void 0
var React = __importStar(require("react"))
var react_1 = __importDefault(require("@fullcalendar/react"))
var daygrid_1 = __importDefault(require("@fullcalendar/daygrid"))
var rrule_1 = require("rrule")
var disruptionIndex_1 = require("./disruptionIndex")
var disruption_1 = require("../models/disruption")
var viewToggle_1 = require("./viewToggle")
var dayNameToInt = function (day) {
  switch (day) {
    case "monday": {
      return 0
    }
    case "tuesday": {
      return 1
    }
    case "wednesday": {
      return 2
    }
    case "thursday": {
      return 3
    }
    case "friday": {
      return 4
    }
    case "saturday": {
      return 5
    }
    case "sunday": {
      return 6
    }
  }
}
exports.dayNameToInt = dayNameToInt
var addDay = function (date) {
  return new Date(date.setTime(date.getTime() + 60 * 60 * 24 * 1000))
}
var disruptionsToCalendarEvents = function (disruptionRevisions, view) {
  return disruptionRevisions.reduce(function (
    disruptionRevisionsAcc,
    disruptionRevision
  ) {
    if (!disruptionRevision.daysOfWeek.length) {
      return disruptionRevisionsAcc
    }
    disruptionRevision.adjustments.forEach(function (adj) {
      var _a
      var ruleSet = new rrule_1.RRuleSet()
      ruleSet.rrule(
        new rrule_1.RRule({
          byweekday:
            (_a = disruptionRevision.daysOfWeek) === null || _a === void 0
              ? void 0
              : _a.map(function (x) {
                  return dayNameToInt(x.dayName)
                }),
          dtstart: disruptionRevision.startDate,
          until: disruptionRevision.endDate,
        })
      )
      disruptionRevision.exceptions.forEach(function (x) {
        if (x.excludedDate) {
          ruleSet.exdate(x.excludedDate)
        }
      })
      var dateGroups = ruleSet.all().length
        ? ruleSet.all().reduce(
            function (acc, curr) {
              var last = acc.slice(-1)[0].slice(-1)[0]
              if (
                !last ||
                curr.getTime() - last.getTime() === 60 * 60 * 24 * 1000
              ) {
                acc[acc.length - 1].push(curr)
              } else {
                acc.push([curr])
              }
              return acc
            },
            [[]]
          )
        : []
      dateGroups.forEach(function (group) {
        disruptionRevisionsAcc.push({
          id: disruptionRevision.id,
          title: adj.sourceLabel,
          backgroundColor: disruptionIndex_1.getRouteColor(adj.routeId),
          start: group[0],
          end: group.length > 1 ? addDay(group.slice(-1)[0]) : group[0],
          url:
            "/disruptions/" +
            disruptionRevision.disruptionId +
            (view === disruption_1.DisruptionView.Draft ? "?v=draft" : ""),
          eventDisplay: "block",
          allDay: true,
        })
      })
    })
    return disruptionRevisionsAcc
  },
  [])
}
exports.disruptionsToCalendarEvents = disruptionsToCalendarEvents
var DisruptionCalendar = function (_a) {
  var disruptionRevisions = _a.disruptionRevisions,
    initialDate = _a.initialDate
  var view = viewToggle_1.useDisruptionViewParam()
  var calendarEvents = React.useMemo(
    function () {
      return disruptionsToCalendarEvents(disruptionRevisions, view)
    },
    [disruptionRevisions, view]
  )
  return React.createElement(
    "div",
    { id: "calendar", className: "my-3" },
    React.createElement(react_1.default, {
      initialDate: initialDate,
      timeZone: "UTC",
      plugins: [daygrid_1.default],
      initialView: "dayGridMonth",
      events: calendarEvents,
    })
  )
}
exports.DisruptionCalendar = DisruptionCalendar
