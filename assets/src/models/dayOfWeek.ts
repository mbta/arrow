import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"
import { ModelObject } from "../jsonApi"

type DayName =
  | "monday"
  | "tuesday"
  | "wednesday"
  | "thursday"
  | "friday"
  | "saturday"
  | "sunday"

class DayOfWeek extends JsonApiResourceObject {
  id?: string
  startTime?: string
  endTime?: string
  dayName: DayName

  constructor({
    id,
    startTime,
    endTime,
    dayName,
  }: {
    id?: string
    startTime?: string
    endTime?: string
    dayName: DayName
  }) {
    super()
    this.id = id
    this.startTime = startTime
    this.endTime = endTime
    this.dayName = dayName
  }

  toJsonApi(): JsonApiResource {
    return {
      data: this.toJsonApiData(),
    }
  }

  toJsonApiData(): JsonApiResourceData {
    return {
      type: "day_of_week",
      ...(this.id && { id: this.id.toString() }),
      attributes: {
        ...(this.startTime && { start_time: this.startTime }),
        ...(this.endTime && { end_time: this.endTime }),
        ...(this.dayName && { day_name: this.dayName }),
      },
    }
  }

  static fromJsonObject(raw: any): DayOfWeek | "error" {
    if (
      typeof raw.attributes === "object" &&
      [
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday",
      ].includes(raw.attributes.day_name)
    ) {
      return new DayOfWeek({
        id: raw.id,
        ...(raw.attributes.start_time && {
          startTime: raw.attributes.start_time,
        }),
        ...(raw.attributes.end_time && { endTime: raw.attributes.end_time }),
        dayName: raw.attributes.day_name,
      })
    } else {
      return "error"
    }
  }

  static isOfType(obj: ModelObject): obj is DayOfWeek {
    return obj instanceof DayOfWeek
  }
}

export default DayOfWeek
export { DayName }
