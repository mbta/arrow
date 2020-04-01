import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"

class TripShortName extends JsonApiResourceObject {
  id?: number
  tripShortName?: string

  constructor({ id, tripShortName }: { id?: number; tripShortName?: string }) {
    super()
    this.id = id
    this.tripShortName = tripShortName
  }

  toJsonApi(): JsonApiResource {
    return {
      data: this.toJsonApiData(),
    }
  }

  toJsonApiData(): JsonApiResourceData {
    return {
      type: "trip_short_name",
      ...(this.id && { id: this.id.toString() }),
      attributes: {
        ...(this.tripShortName && { trip_short_name: this.tripShortName }),
      },
    }
  }

  static fromJsonApi(raw: any): TripShortName | "error" {
    if (typeof raw === "object") {
      if (raw.data?.type === "trip_short_name") {
        return new TripShortName({})
      }
    }

    return "error"
  }
}

export default TripShortName
