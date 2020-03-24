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
    let fromJsonObjectFunction: (
      arg0: any,
      arg1: ModelObject[]
    ) => ModelObject | "error"

    switch (raw.type) {
      case "adjustment":
        fromJsonObjectFunction = Adjustment.fromJsonObject
        break
      case "day_of_week":
        fromJsonObjectFunction = DayOfWeek.fromJsonObject
        break
      case "disruption":
        fromJsonObjectFunction = Disruption.fromJsonObject
        break
      case "exception":
        fromJsonObjectFunction = Exception.fromJsonObject
        break
      case "trip_short_name":
        fromJsonObjectFunction = TripShortName.fromJsonObject
        break
      default:
        return "error"
    }

    return fromJsonObjectFunction(raw, includedObjects)
  }

  return "error"
}

export { ModelObject, toModelObject }
