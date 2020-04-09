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

const toModelObject = (
  response: any
): ModelObject | ModelObject[] | "error" => {
  const includedObjectsMap: {
    [key: string]: ModelObject | "error"
  } = Array.isArray(response?.included)
    ? response.included.reduce(
        (acc: any, curr: { [keys: string]: ModelObject | "error" }) => {
          acc[`${curr.type}-${curr.id}`] = modelFromJsonApiResource(curr, [])
          return acc
        },
        {}
      )
    : {}
  let includedObjects = Object.values(includedObjectsMap)
  if (Array.isArray(response?.included)) {
    includedObjects = response.included.map((raw: any) =>
      modelFromJsonApiResource(raw, [])
    )

    if (
      Object.values(includedObjectsMap).some(
        (modelObject: ModelObject | "error") => modelObject === "error"
      )
    ) {
      return "error"
    }
  } else if (typeof response?.included !== "undefined") {
    return "error"
  }
  if (Array.isArray(response.data)) {
    const maybeModelObjects: (ModelObject | "error")[] = response.data.map(
      (data: any) =>
        modelFromJsonApiResource(
          data,
          Object.values(data?.relationships || []).reduce(
            (acc: any, curr: any) => {
              return [
                ...acc,
                ...(curr?.data || []).map(
                  (x: any) => includedObjectsMap[`${x.type}-${x.id}`]
                ),
              ]
            },
            [] as ModelObject[]
          ) as ModelObject[]
        )
    )
    if (
      maybeModelObjects.some(maybeModelObject => maybeModelObject === "error")
    ) {
      return "error"
    } else {
      return maybeModelObjects as ModelObject[]
    }
  } else {
    return modelFromJsonApiResource(
      response.data,
      includedObjects as ModelObject[]
    )
  }
}

const parseErrors = (raw: any): string[] => {
  const errors: string[] = []

  if (typeof raw === "object") {
    const rawErrors = raw?.errors
    if (Array.isArray(rawErrors)) {
      rawErrors.forEach(err => {
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

export { ModelObject, toModelObject, parseErrors }
