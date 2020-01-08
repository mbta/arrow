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

export { Adjustment, TransitMode, formatDisruptionDate, indexToDayOfWeekString }
