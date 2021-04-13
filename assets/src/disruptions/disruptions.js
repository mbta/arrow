"use strict"
Object.defineProperty(exports, "__esModule", { value: true })
exports.modeForRoute = exports.indexToDayOfWeekString = exports.formatDisruptionDate = exports.TransitMode = void 0
var TransitMode
;(function (TransitMode) {
  TransitMode[(TransitMode["Subway"] = 0)] = "Subway"
  TransitMode[(TransitMode["CommuterRail"] = 1)] = "CommuterRail"
})(TransitMode || (TransitMode = {}))
exports.TransitMode = TransitMode
var formatNumber = function (n) {
  var str = n.toString()
  if (str.length === 1) {
    return "0" + str
  } else {
    return str
  }
}
var formatDisruptionDate = function (date) {
  if (date) {
    return (
      formatNumber(date.getUTCMonth() + 1) +
      "/" +
      formatNumber(date.getUTCDate()) +
      "/" +
      date.getUTCFullYear()
    )
  } else {
    return ""
  }
}
exports.formatDisruptionDate = formatDisruptionDate
var indexToDayOfWeekString = function (index) {
  var dayOfWeekStrings = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ]
  return dayOfWeekStrings[index] || ""
}
exports.indexToDayOfWeekString = indexToDayOfWeekString
var modeForRoute = function (route) {
  if (route.startsWith("CR-")) {
    return TransitMode.CommuterRail
  } else {
    return TransitMode.Subway
  }
}
exports.modeForRoute = modeForRoute
