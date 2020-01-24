interface Adjustment {
  label: string
  route: string
}

enum TransitMode {
  Subway,
  CommuterRail,
}

const formatDisruptionDate = (date: Date | null): string => {
  if (date) {
    return `${date.getMonth() + 1}/${date.getDate()}/${date.getFullYear()}`
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
  Adjustment,
  TransitMode,
  formatDisruptionDate,
  indexToDayOfWeekString,
  modeForRoute,
}
