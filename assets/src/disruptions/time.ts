import DayOfWeek, { DayName } from "../models/dayOfWeek"

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
  return days.filter(d => d !== null).length === 0
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
    const hour = String(
      +timeStringComponents[0] > 12
        ? +timeStringComponents[0] - 12
        : timeStringComponents[0]
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

  daysOfWeek.forEach(dayOfWeek => {
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

const ixToDayName = (
  ix: number
):
  | "monday"
  | "tuesday"
  | "wednesday"
  | "thursday"
  | "friday"
  | "saturday"
  | "sunday" => {
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

export const dayToIx = (
  day:
    | "monday"
    | "tuesday"
    | "wednesday"
    | "thursday"
    | "friday"
    | "saturday"
    | "sunday"
): number => {
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

const dayOfWeekTimeRangesToDayOfWeeks = (
  timeRanges: DayOfWeekTimeRanges
): DayOfWeek[] => {
  const daysOfWeek: DayOfWeek[] = []

  timeRanges.forEach((dow, ix) => {
    if (dow !== null) {
      const dayName = ixToDayName(ix)
      const [startTime, endTime] = dow
      const dayOfWeek = new DayOfWeek({
        ...(dayName !== null && { dayName }),
        ...(startTime !== null && { startTime: timeToString(startTime) }),
        ...(endTime !== null && { endTime: timeToString(endTime) }),
      })
      daysOfWeek.push(dayOfWeek)
    }
  })

  return daysOfWeek
}

export {
  Time,
  HourOptions,
  MinuteOptions,
  PeriodOptions,
  TimeRange,
  DayOfWeekTimeRanges,
  fromDaysOfWeek,
  isEmpty,
  dayOfWeekTimeRangesToDayOfWeeks,
}

const hourToString = (hour: number) => {
  if (hour === 0) {
    return "12"
  } else if (hour > 12) {
    return (hour - 12).toString()
  } else {
    return hour.toString()
  }
}

const timeOrEndOfService = (
  time?: string,
  end: "start" | "end" = "start"
): string => {
  if (time) {
    const hoursInt = parseInt(time.slice(0, 2), 10)
    const hours = hourToString(hoursInt)
    const minutes = time.slice(2, 5)
    const period = hoursInt < 12 ? "AM" : "PM"
    return `${hours}${minutes}${period}`
  } else {
    return end === "start" ? "Start of service" : "End of service"
  }
}

const getTimeType = (
  firstTime: DayOfWeek,
  lastTime: DayOfWeek,
  startTimeSet: Set<string | undefined>,
  endTimeSet: Set<string | undefined>
): "daily" | "ends" | "other" => {
  if (startTimeSet.size === 1 && endTimeSet.size === 1) {
    return "daily"
  } else if (
    ((!!firstTime.startTime || !!lastTime.endTime) &&
      startTimeSet.size + endTimeSet.size === 3 &&
      firstTime.startTime !== lastTime.endTime) ||
    (startTimeSet.size + endTimeSet.size === 4 &&
      !!firstTime.startTime &&
      !!lastTime.endTime &&
      firstTime.startTime === lastTime.endTime)
  ) {
    return "ends"
  } else {
    return "other"
  }
}

type DaysType = "consecutive" | "other"

const getDaysType = (days: DayName[]): DaysType => {
  const sortedDays = days
    .map(day => ({ day, index: dayToIx(day) }))
    .sort((a, b) => a.index - b.index)
  let consecutive = true
  sortedDays.forEach((day, index, array) => {
    if (index && day.index - array[index - 1].index !== 1) {
      consecutive = false
    }
  })
  return consecutive ? "consecutive" : "other"
}

const capitalizeFirstLetter = (str?: string) => {
  return str ? str.charAt(0).toUpperCase() + str.slice(1) : ""
}

const describeSingleDay = ({ day, startTime, endTime }: DayOfWeek): string =>
  `${capitalizeFirstLetter(day)}, ${timeOrEndOfService(
    startTime
  )} - ${timeOrEndOfService(endTime, "end")}`

export const parseDaysAndTimes = (daysAndTimes: DayOfWeek[]): string => {
  if (daysAndTimes.length === 1) {
    return describeSingleDay(daysAndTimes[0])
  }
  const first = daysAndTimes[0]
  const last = daysAndTimes[daysAndTimes.length - 1]
  const startTimeSet = new Set<string | undefined>()
  const endTimeSet = new Set<string | undefined>()
  const fallBackStringList: string[] = []
  daysAndTimes.forEach(dayOfWeek => {
    const { day, startTime, endTime } = dayOfWeek
    if (day) {
      startTimeSet.add(startTime)
      endTimeSet.add(endTime)
      fallBackStringList.push(describeSingleDay(dayOfWeek))
    }
  })
  const daysType = getDaysType(
    daysAndTimes
      .map(day => day.day)
      .filter((day: DayName | undefined): day is DayName => !!day)
  )
  const timeType = getTimeType(first, last, startTimeSet, endTimeSet)
  if (daysType === "other" || timeType === "other") {
    return fallBackStringList.join(", ")
  } else if (timeType === "daily") {
    return `${capitalizeFirstLetter(first.day)} - ${capitalizeFirstLetter(
      last.day
    )}, ${timeOrEndOfService(first.startTime)} - ${timeOrEndOfService(
      first.endTime,
      "end"
    )}`
  } else {
    return `${capitalizeFirstLetter(first.day)} ${timeOrEndOfService(
      first.startTime
    )} - ${capitalizeFirstLetter(last.day)} ${timeOrEndOfService(
      last.endTime,
      "end"
    )}`
  }
}
