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

type JsonApiResponse = ModelObject | ModelObject[] | "error"

const toUTCDate = (dateStr: string): Date => {
  const [year, month, date] = dateStr.split("-")
  return new Date(
    Date.UTC(parseInt(year, 10), parseInt(month, 10) - 1, parseInt(date, 10))
  )
}

const toModelObject = (response: any): JsonApiResponse => {
  const includedObjects: { [key: string]: ModelObject } = {}

  if (Array.isArray(response?.included)) {
    for (const obj of response.included) {
      // On this first pass, we use {} for the included objects
      const model = modelFromJsonApiResource(obj, {})
      if (model === "error") {
        return "error"
      } else {
        includedObjects[`${obj.type}-${obj.id}`] = model
      }
    }

    for (const obj of response.included) {
      // On this second pass we can now load the nested included objects
      const model = modelFromJsonApiResource(
        obj,
        includedObjects
      ) as ModelObject
      includedObjects[`${obj.type}-${obj.id}`] = model
    }
  } else if (typeof response?.included !== "undefined") {
    return "error"
  }

  if (Array.isArray(response.data)) {
    const modelObjects: ModelObject[] = []

    for (const data of response.data) {
      const model = modelFromJsonApiResource(data, includedObjects)

      if (model === "error") {
        return "error"
      } else {
        modelObjects.push(model)
      }
    }

    return modelObjects
  } else {
    return modelFromJsonApiResource(response.data, includedObjects)
  }
}

const parseErrors = (raw: any): string[] => {
  const errors: string[] = []

  if (typeof raw === "object") {
    const rawErrors = raw?.errors
    if (Array.isArray(rawErrors)) {
      rawErrors.forEach((err) => {
        const rawDetail = err?.detail
        if (typeof rawDetail === "string") {
          errors.push(rawDetail)
        }
      })
    }
  }

  return errors
}

const modelFromJsonApiResource = (
  raw: any,
  includedObjects: { [key: string]: ModelObject }
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

const loadRelationship = (
  relationship: any,
  included: { [key: string]: ModelObject }
): ModelObject[] => {
  if (typeof relationship === "object") {
    if (Array.isArray(relationship.data)) {
      return relationship.data
        .map((r: { id: string; type: string }) => included[`${r.type}-${r.id}`])
        .filter((o: any) => typeof o !== "undefined")
    } else if (typeof relationship.data === "object") {
      const key = relationship.data
      return [included[`${key.type}-${key.id}`]]
    }
  }
  return []
}

export {
  ModelObject,
  JsonApiResponse,
  toModelObject,
  parseErrors,
  toUTCDate,
  loadRelationship,
}
