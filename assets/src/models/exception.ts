import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"

class Exception extends JsonApiResourceObject {
  id?: string
  excludedDate?: Date

  constructor({ id, excludedDate }: { id?: string; excludedDate?: Date }) {
    super()
    this.id = id
    this.excludedDate = excludedDate
  }

  toJsonApi(): JsonApiResource {
    return {
      data: this.toJsonApiData(),
    }
  }

  toJsonApiData(): JsonApiResourceData {
    return {
      type: "exception",
      ...(this.id && { id: this.id.toString() }),
      attributes: {
        ...(this.excludedDate && {
          excluded_date: this.excludedDate.toISOString().slice(0, 10),
        }),
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
