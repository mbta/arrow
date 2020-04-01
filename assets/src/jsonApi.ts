import Adjustment from "./models/adjustment"
import DayOfWeek from "./models/dayOfWeek"
import Disruption from "./models/disruption"
import Exception from "./models/exception"
import TripShortName from "./models/tripShortName"

type ModelObject =
  | Adjustment
  | DayOfWeek
  | Disruption
  | Exception
  | TripShortName

const toModelObject = (response: any): ModelObject | "error" => {
  let includedObjects: (ModelObject | "error")[] = []

  if (Array.isArray(response?.included)) {
    includedObjects = response.included.map((raw: any) =>
      modelFromJsonApiResource(raw, [])
    )

    if (
      includedObjects.some(
        (modelObject: ModelObject | "error") => modelObject === "error"
      )
    ) {
      return "error"
    }
  } else if (typeof response?.included !== "undefined") {
    return "error"
  }

  return modelFromJsonApiResource(
    response.data,
    includedObjects as ModelObject[]
  )
}

const modelFromJsonApiResource = (
  raw: any,
  includedObjects: ModelObject[]
): ModelObject | "error" => {
  if (typeof raw === "object") {
    switch (raw.type) {
      case "adjustment":
        return Adjustment.fromJsonObject(raw)
      case "day_of_week":
        return DayOfWeek.fromJsonObject(raw)
      case "disruption":
        return Disruption.fromJsonObject(raw, includedObjects)
      case "exception":
        return Exception.fromJsonObject(raw)
      case "trip_short_name":
        return TripShortName.fromJsonObject(raw)
      default:
        return "error"
    }
  }

  return "error"
}

export { ModelObject, toModelObject }
