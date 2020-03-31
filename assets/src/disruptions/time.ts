import DayOfWeek from "../models/dayOfWeek"

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
    if (dayOfWeek.day) {
      const index = dayNamesToIndices[dayOfWeek.day]
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

export {
  Time,
  HourOptions,
  MinuteOptions,
  PeriodOptions,
  TimeRange,
  DayOfWeekTimeRanges,
  fromDaysOfWeek,
  isEmpty,
}
