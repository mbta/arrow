enum TransitMode {
  Subway,
  CommuterRail,
}

const formatDisruptionDate = (date: Date | null): string => {
  if (date) {
    return `${
      date.getUTCMonth() + 1
    }/${date.getUTCDate()}/${date.getUTCFullYear()}`
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
