import DayOfWeek, { DayName } from "../models/dayOfWeek"
import { dayNameToInt } from "./disruptionCalendar"

type HourOptions =
  | "12"
  | "1"
  | "2"
  | "3"
  | "4"
  | "5"
  | "6"
  | "7"
  | "8"
  | "9"
  | "10"
  | "11"

type MinuteOptions = "00" | "15" | "30" | "45"

type PeriodOptions = "AM" | "PM"

interface Time {
  hour: HourOptions
  minute: MinuteOptions
  period: PeriodOptions
}

type TimeRange = [Time | null, Time | null]

type DayOfWeekTimeRanges = [
  TimeRange | null,
  TimeRange | null,
  TimeRange | null,
  TimeRange | null,
  TimeRange | null,
  TimeRange | null,
  TimeRange | null
]

const dayNamesToIndices = {
  monday: 0,
  tuesday: 1,
  wednesday: 2,
  thursday: 3,
  friday: 4,
  saturday: 5,
  sunday: 6,
}

const isEmpty = (days: DayOfWeekTimeRanges): boolean => {
  return days.filter((d) => d !== null).length === 0
}

const isHourOption = (hour: string): hour is HourOptions => {
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

const isMinuteOption = (minute: string): minute is MinuteOptions => {
  return ["00", "15", "30", "45"].includes(minute)
}

const timeStringToTime = (
  timeString: string | undefined
): Time | null | "error" => {
  if (typeof timeString === "undefined") {
    return null
  }
  const timeStringComponents = timeString.split(":")

  if (timeStringComponents.length === 3) {
    const hourString = timeStringComponents[0].startsWith("0")
      ? timeStringComponents[0].slice(1)
      : timeStringComponents[0]
    const hour = String(
      +hourString > 12
        ? +hourString - 12
        : hourString === "0"
        ? "12"
        : hourString
    )
    const minute = timeStringComponents[1]
    const second = timeStringComponents[2]
    const period = +timeStringComponents[0] > 12 ? "PM" : "AM"
    if (isHourOption(hour) && isMinuteOption(minute) && second === "00") {
      return {
        hour,
        minute,
        period,
      }
    } else {
      return "error"
    }
  }

  return "error"
}

const fromDaysOfWeek = (
  daysOfWeek: DayOfWeek[]
): DayOfWeekTimeRanges | "error" => {
  const dayOfWeekTimeRanges: DayOfWeekTimeRanges = [
    null,
    null,
    null,
    null,
    null,
    null,
    null,
  ]
  let invalidTimeFound = false

  daysOfWeek.forEach((dayOfWeek) => {
    if (dayOfWeek.dayName) {
      const index = dayNamesToIndices[dayOfWeek.dayName]
      const startTime = timeStringToTime(dayOfWeek.startTime)
      const endTime = timeStringToTime(dayOfWeek.endTime)

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

const numToString = (n: number): string => {
  if (n < 10) {
    return "0" + n.toString()
  }
  return n.toString()
}

const timeToString = (time: Time): string => {
  const { hour, minute, period } = time
  let hourNum = parseInt(hour, 10)
  const minuteNum = parseInt(minute, 10)
  if (period === "AM" && hourNum === 12) {
    hourNum = 0
  } else if (period === "PM" && hourNum !== 12) {
    hourNum += 12
  }

  return `${numToString(hourNum)}:${numToString(minuteNum)}:00`
}

const ixToDayName = (ix: number): DayName => {
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

const dayToIx = (day: DayName): number => {
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

const dayToAbbr = (day: DayName): string => {
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

const dayOfWeekTimeRangesToDayOfWeeks = (
  timeRanges: DayOfWeekTimeRanges
): DayOfWeek[] => {
  const daysOfWeek: DayOfWeek[] = []

  timeRanges.forEach((dow, ix) => {
    if (dow !== null) {
      const dayName = ixToDayName(ix)
      const [startTime, endTime] = dow
      const dayOfWeek = new DayOfWeek({
        dayName,
        ...(startTime !== null && { startTime: timeToString(startTime) }),
        ...(endTime !== null && { endTime: timeToString(endTime) }),
      })
      daysOfWeek.push(dayOfWeek)
    }
  })

  return daysOfWeek
}

const timeOrEndOfService = (
  timeString?: string,
  end: "start" | "end" = "start"
): string => {
  if (timeString) {
    const time = timeStringToTime(timeString)
    if (time && time !== "error") {
      const { hour, minute, period } = time
      return `${hour}:${minute}${period}`
    }
  }
  return end === "start" ? "Start of service" : "End of service"
}

const getTimeType = (
  firstTime: DayOfWeek,
  lastTime: DayOfWeek,
  startTimeSet: Set<string | undefined>,
  endTimeSet: Set<string | undefined>
): "daily" | "ends" | "other" => {
  const setSizeSum = startTimeSet.size + endTimeSet.size
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

type DaysType = "consecutive" | "other"

const getDaysType = (days: DayName[]): DaysType => {
  const sortedDays = days
    .map((day) => ({ day, index: dayToIx(day) }))
    .sort((a, b) => a.index - b.index)
  let consecutive = true
  sortedDays.forEach((day, index, array) => {
    if (index && day.index - array[index - 1].index !== 1) {
      consecutive = false
    }
  })
  return consecutive ? "consecutive" : "other"
}

const describeSingleDay = ({
  dayName,
  startTime,
  endTime,
}: DayOfWeek): string =>
  `${dayToAbbr(dayName)}, ${timeOrEndOfService(
    startTime
  )} - ${timeOrEndOfService(endTime, "end")}`

const parseDaysAndTimes = (daysAndTimes: DayOfWeek[]): string => {
  if (daysAndTimes.length === 1) {
    return describeSingleDay(daysAndTimes[0])
  }
  const sortedDaysAndTimes = daysAndTimes.sort(
    (a, b) => dayNameToInt(a.dayName) - dayNameToInt(b.dayName)
  )
  const first = sortedDaysAndTimes[0]
  const last = sortedDaysAndTimes[sortedDaysAndTimes.length - 1]
  const startTimeSet = new Set<string | undefined>()
  const endTimeSet = new Set<string | undefined>()
  const fallBackStringList: string[] = []

  sortedDaysAndTimes.forEach((dayOfWeek) => {
    const { dayName, startTime, endTime } = dayOfWeek
    if (dayName) {
      startTimeSet.add(startTime)
      endTimeSet.add(endTime)
      fallBackStringList.push(describeSingleDay(dayOfWeek))
    }
  })
  const daysType = getDaysType(
    sortedDaysAndTimes
      .map((day) => day.dayName)
      .filter((day: DayName | undefined): day is DayName => !!day)
  )
  const timeType = getTimeType(first, last, startTimeSet, endTimeSet)
  if (daysType === "other" || timeType === "other") {
    return fallBackStringList.join(", ")
  } else if (timeType === "daily") {
    return `${dayToAbbr(first.dayName)} - ${dayToAbbr(
      last.dayName
    )}, ${timeOrEndOfService(first.startTime)} - ${timeOrEndOfService(
      first.endTime,
      "end"
    )}`
  } else {
    return `${dayToAbbr(first.dayName)} ${timeOrEndOfService(
      first.startTime
    )} - ${dayToAbbr(last.dayName)} ${timeOrEndOfService(last.endTime, "end")}`
  }
}

export {
  Time,
  HourOptions,
  MinuteOptions,
  PeriodOptions,
  TimeRange,
  DayOfWeekTimeRanges,
  fromDaysOfWeek,
  timeToString,
  ixToDayName,
  isEmpty,
  dayOfWeekTimeRangesToDayOfWeeks,
  parseDaysAndTimes,
  dayToIx,
}
