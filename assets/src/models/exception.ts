import JsonApiResource from "../jsonApiResource"

class Exception {
  id?: number
  excludedDate?: Date

  constructor({ id, excludedDate }: { id?: number; excludedDate?: Date }) {
    this.id = id
    this.excludedDate = excludedDate
  }

  toJsonApi(): JsonApiResource {
    return {
      data: {
        type: "exception",
        ...(this.id && { id: this.id.toString() }),
        attributes: {
          ...(this.excludedDate && {
            excluded_date: this.excludedDate.toISOString().slice(0, 10),
          }),
        },
      },
    }
  }

  static fromJsonApi(raw: any): Exception | "error" {
    if (typeof raw === "object") {
      if (raw.data?.type === "exception") {
        return new Exception({})
      }
    }

    return "error"
  }
}

export default Exception
