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
  id?: number
  startTime?: string
  endTime?: string
  day?: DayName

  constructor({
    id,
    startTime,
    endTime,
    day,
  }: {
    id?: number
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

  static fromJsonApi(raw: any): DayOfWeek | "error" {
    if (typeof raw === "object") {
      if (raw.data?.type === "day_of_week") {
        return new DayOfWeek({})
      }
    }

    return "error"
  }
}

export default DayOfWeek
