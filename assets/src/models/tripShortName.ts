import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"
import { ModelObject } from "../jsonApi"

class TripShortName extends JsonApiResourceObject {
  id?: string
  tripShortName?: string

  constructor({ id, tripShortName }: { id?: string; tripShortName?: string }) {
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

  static fromJsonObject(
    raw: any,
    _included: ModelObject[]
  ): TripShortName | "error" {
    if (typeof raw.attributes === "object") {
      return new TripShortName({
        id: raw.id,
        tripShortName: raw.attributes.trip_short_name,
      })
    }

    return "error"
  }
}

export default TripShortName
