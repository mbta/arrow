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
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
exports.timePeriodDescription = exports.timeOrStartOrEndOfService = exports.dayToIx = exports.parseDaysAndTimes = exports.dayOfWeekTimeRangesToDayOfWeeks = exports.ixToDayName = exports.timeToString = exports.fromDaysOfWeek = void 0
var dayOfWeek_1 = __importDefault(require("../models/dayOfWeek"))
var disruptionCalendar_1 = require("./disruptionCalendar")
var dayNamesToIndices = {
  monday: 0,
  tuesday: 1,
  wednesday: 2,
  thursday: 3,
  friday: 4,
  saturday: 5,
  sunday: 6,
}
var isHourOption = function (hour) {
  return [
    "12",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
  ].includes(hour)
}
var isMinuteOption = function (minute) {
  return ["00", "15", "30", "45"].includes(minute)
}
var timeStringToTime = function (timeString) {
  if (typeof timeString === "undefined") {
    return null
  }
  var timeStringComponents = timeString.split(":")
  if (timeStringComponents.length === 3) {
    var hourString = timeStringComponents[0].startsWith("0")
      ? timeStringComponents[0].slice(1)
      : timeStringComponents[0]
    var hour = String(
      +hourString > 12
        ? +hourString - 12
        : hourString === "0"
        ? "12"
        : hourString
    )
    var minute = timeStringComponents[1]
    var second = timeStringComponents[2]
    var period = +timeStringComponents[0] > 12 ? "PM" : "AM"
    if (isHourOption(hour) && isMinuteOption(minute) && second === "00") {
      return {
        hour: hour,
        minute: minute,
        period: period,
      }
    } else {
      return "error"
    }
  }
  return "error"
}
var fromDaysOfWeek = function (daysOfWeek) {
  var dayOfWeekTimeRanges = [null, null, null, null, null, null, null]
  var invalidTimeFound = false
  daysOfWeek.forEach(function (dayOfWeek) {
    if (dayOfWeek.dayName) {
      var index = dayNamesToIndices[dayOfWeek.dayName]
      var startTime = timeStringToTime(dayOfWeek.startTime)
      var endTime = timeStringToTime(dayOfWeek.endTime)
      if (startTime !== "error" && endTime !== "error") {
        dayOfWeekTimeRanges[index] = [startTime, endTime]
      } else {
        invalidTimeFound = true
      }
    }
  })
  if (invalidTimeFound) {
    return "error"
  } else {
    return dayOfWeekTimeRanges
  }
}
exports.fromDaysOfWeek = fromDaysOfWeek
var numToString = function (n) {
  if (n < 10) {
    return "0" + n.toString()
  }
  return n.toString()
}
var timeToString = function (time) {
  var hour = time.hour,
    minute = time.minute,
    period = time.period
  var hourNum = parseInt(hour, 10)
  var minuteNum = parseInt(minute, 10)
  if (period === "AM" && hourNum === 12) {
    hourNum = 0
  } else if (period === "PM" && hourNum !== 12) {
    hourNum += 12
  }
  return numToString(hourNum) + ":" + numToString(minuteNum) + ":00"
}
exports.timeToString = timeToString
var ixToDayName = function (ix) {
  switch (ix) {
    case 0:
      return "monday"
    case 1:
      return "tuesday"
    case 2:
      return "wednesday"
    case 3:
      return "thursday"
    case 4:
      return "friday"
    case 5:
      return "saturday"
    default:
      return "sunday"
  }
}
exports.ixToDayName = ixToDayName
var dayToIx = function (day) {
  switch (day) {
    case "monday":
      return 0
    case "tuesday":
      return 1
    case "wednesday":
      return 2
    case "thursday":
      return 3
    case "friday":
      return 4
    case "saturday":
      return 5
    default:
      return 6
  }
}
exports.dayToIx = dayToIx
var dayToAbbr = function (day) {
  switch (day) {
    case "monday":
      return "Mon"
    case "tuesday":
      return "Tue"
    case "wednesday":
      return "Wed"
    case "thursday":
      return "Thu"
    case "friday":
      return "Fri"
    case "saturday":
      return "Sat"
    default:
      return "Sun"
  }
}
var dayOfWeekTimeRangesToDayOfWeeks = function (timeRanges) {
  var daysOfWeek = []
  timeRanges.forEach(function (dow, ix) {
    if (dow !== null) {
      var dayName = ixToDayName(ix)
      var startTime = dow[0],
        endTime = dow[1]
      var dayOfWeek = new dayOfWeek_1.default(
        __assign(
          __assign(
            { dayName: dayName },
            startTime !== null && { startTime: timeToString(startTime) }
          ),
          endTime !== null && { endTime: timeToString(endTime) }
        )
      )
      daysOfWeek.push(dayOfWeek)
    }
  })
  return daysOfWeek
}
exports.dayOfWeekTimeRangesToDayOfWeeks = dayOfWeekTimeRangesToDayOfWeeks
var timeOrStartOrEndOfService = function (timeString, end) {
  if (end === void 0) {
    end = "start"
  }
  if (timeString) {
    var time = timeStringToTime(timeString)
    if (time && time !== "error") {
      var hour = time.hour,
        minute = time.minute,
        period = time.period
      return hour + ":" + minute + period
    }
  }
  return end === "start" ? "Start of service" : "End of service"
}
exports.timeOrStartOrEndOfService = timeOrStartOrEndOfService
var getTimeType = function (firstTime, lastTime, startTimeSet, endTimeSet) {
  var setSizeSum = startTimeSet.size + endTimeSet.size
  if (setSizeSum === 2) {
    return "daily"
  } else if (
    (!!firstTime.startTime || !!firstTime.endTime) &&
    !firstTime.endTime &&
    !lastTime.startTime &&
    setSizeSum === (firstTime.startTime === lastTime.endTime ? 4 : 3)
  ) {
    return "ends"
  } else {
    return "other"
  }
}
var getDaysType = function (days) {
  var sortedDays = days
    .map(function (day) {
      return { day: day, index: dayToIx(day) }
    })
    .sort(function (a, b) {
      return a.index - b.index
    })
  var consecutive = true
  sortedDays.forEach(function (day, index, array) {
    if (index && day.index - array[index - 1].index !== 1) {
      consecutive = false
    }
  })
  return consecutive ? "consecutive" : "other"
}
var timePeriodDescription = function (startTime, endTime) {
  return (
    timeOrStartOrEndOfService(startTime) +
    " - " +
    timeOrStartOrEndOfService(endTime, "end")
  )
}
exports.timePeriodDescription = timePeriodDescription
var describeSingleDay = function (_a) {
  var dayName = _a.dayName,
    startTime = _a.startTime,
    endTime = _a.endTime
  return dayToAbbr(dayName) + ", " + timePeriodDescription(startTime, endTime)
}
var parseDaysAndTimes = function (daysAndTimes) {
  if (daysAndTimes.length === 1) {
    return describeSingleDay(daysAndTimes[0])
  }
  var sortedDaysAndTimes = daysAndTimes.sort(function (a, b) {
    return (
      disruptionCalendar_1.dayNameToInt(a.dayName) -
      disruptionCalendar_1.dayNameToInt(b.dayName)
    )
  })
  var first = sortedDaysAndTimes[0]
  var last = sortedDaysAndTimes[sortedDaysAndTimes.length - 1]
  var startTimeSet = new Set()
  var endTimeSet = new Set()
  var fallBackStringList = []
  sortedDaysAndTimes.forEach(function (dayOfWeek) {
    var dayName = dayOfWeek.dayName,
      startTime = dayOfWeek.startTime,
      endTime = dayOfWeek.endTime
    if (dayName) {
      startTimeSet.add(startTime)
      endTimeSet.add(endTime)
      fallBackStringList.push(describeSingleDay(dayOfWeek))
    }
  })
  var daysType = getDaysType(
    sortedDaysAndTimes
      .map(function (day) {
        return day.dayName
      })
      .filter(function (day) {
        return !!day
      })
  )
  var timeType = getTimeType(first, last, startTimeSet, endTimeSet)
  if (daysType === "other" || timeType === "other") {
    return fallBackStringList.join(", ")
  } else if (timeType === "daily") {
    return (
      dayToAbbr(first.dayName) +
      " - " +
      dayToAbbr(last.dayName) +
      ", " +
      timeOrStartOrEndOfService(first.startTime) +
      " - " +
      timeOrStartOrEndOfService(first.endTime, "end")
    )
  } else {
    return (
      dayToAbbr(first.dayName) +
      " " +
      timeOrStartOrEndOfService(first.startTime) +
      " - " +
      dayToAbbr(last.dayName) +
      " " +
      timeOrStartOrEndOfService(last.endTime, "end")
    )
  }
}
exports.parseDaysAndTimes = parseDaysAndTimes
