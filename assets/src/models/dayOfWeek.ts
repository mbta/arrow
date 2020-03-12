import JsonApiResource from "../jsonApiResource"

type DayName =
  | "monday"
  | "tuesday"
  | "wednesday"
  | "thursday"
  | "friday"
  | "saturday"
  | "sunday"

class DayOfWeek {
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
    this.id = id
    this.startTime = startTime
    this.endTime = endTime
    this.day = day
  }

  serialize(): JsonApiResource {
    return {
      data: {
        type: "day_of_week",
        ...(this.id && { id: this.id.toString() }),
        attributes: {
          ...(this.startTime && { start_time: this.startTime }),
          ...(this.endTime && { end_time: this.endTime }),
          ...(this.day && { day: this.day }),
        },
      },
    }
  }
}

export default DayOfWeek
