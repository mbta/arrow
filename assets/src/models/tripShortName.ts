import JsonApiResource from "../jsonApiResource"

class TripShortName {
  id?: number
  tripShortName?: string

  constructor({ id, tripShortName }: { id?: number; tripShortName?: string }) {
    this.id = id
    this.tripShortName = tripShortName
  }

  toJsonApi(): JsonApiResource {
    return {
      data: {
        type: "trip_short_name",
        ...(this.id && { id: this.id.toString() }),
        attributes: {
          ...(this.tripShortName && { trip_short_name: this.tripShortName }),
        },
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
