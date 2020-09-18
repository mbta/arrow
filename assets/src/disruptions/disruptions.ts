enum TransitMode {
  Subway,
  CommuterRail,
}

const formatNumber = (n: number): string => {
  const str = n.toString()
  if (str.length === 1) {
    return "0" + str
  } else {
    return str
  }
}

const formatDisruptionDate = (date: Date | null): string => {
  if (date) {
    return `${formatNumber(date.getUTCMonth() + 1)}/${formatNumber(
      date.getUTCDate()
    )}/${date.getUTCFullYear()}`
  } else {
    return ""
  }
}

const indexToDayOfWeekString = (index: number): string => {
  const dayOfWeekStrings = [
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

const modeForRoute = (route: string): TransitMode => {
  if (route.startsWith("CR-")) {
    return TransitMode.CommuterRail
  } else {
    return TransitMode.Subway
  }
}

export {
  TransitMode,
  formatDisruptionDate,
  indexToDayOfWeekString,
  modeForRoute,
}
