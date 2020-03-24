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
  day?: DayName

  constructor({
    id,
    startTime,
    endTime,
    day,
  }: {
    id?: string
    startTime?: string
    endTime?: string
    day?: DayName
  }) {
    super()
    this.id = id
    this.startTime = startTime
    this.endTime = endTime
    this.day = day
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
        ...(this.day && { day: this.day }),
      },
    }
  }

  static fromJsonObject(
    raw: any,
    _included: ModelObject[]
  ): DayOfWeek | "error" {
    if (typeof raw.attributes === "object") {
      let day: DayName | undefined

      if (raw.attributes.monday) {
        day = "monday"
      } else if (raw.attributes.tuesday) {
        day = "tuesday"
      } else if (raw.attributes.wednesday) {
        day = "wednesday"
      } else if (raw.attributes.thursday) {
        day = "thursday"
      } else if (raw.attributes.friday) {
        day = "friday"
      } else if (raw.attributes.saturday) {
        day = "saturday"
      } else if (raw.attributes.sunday) {
        day = "sunday"
      }

      return new DayOfWeek({
        id: raw.id,
        ...(raw.attributes.start_time && {
          startTime: raw.attributes.start_time,
        }),
        ...(raw.attributes.end_time && { endTime: raw.attributes.end_time }),
        day,
      })
    }

    return "error"
  }
}

export default DayOfWeek
