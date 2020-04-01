import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"

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

  static fromJsonObject(raw: any): DayOfWeek | "error" {
    if (typeof raw.attributes === "object") {
      let day: DayName | undefined

      if (
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
        day = raw.attributes.day_name
      } else {
        return "error"
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
