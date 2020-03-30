enum TransitMode {
  Subway,
  CommuterRail,
}

const formatDisruptionDate = (date: Date | null): string => {
  if (date) {
    return `${date.getUTCMonth() +
      1}/${date.getUTCDate()}/${date.getUTCFullYear()}`
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
  switch (route) {
    case "Red":
      return TransitMode.Subway
    case "Green-D":
      return TransitMode.Subway
    case "CR-Fairmount":
      return TransitMode.CommuterRail
    default:
      return TransitMode.Subway
  }
}

export {
  TransitMode,
  formatDisruptionDate,
  indexToDayOfWeekString,
  modeForRoute,
}
