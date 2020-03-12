import JsonApiResource from "../jsonApiResource"

class TripShortName {
  id?: number
  tripShortName?: string

  constructor({ id, tripShortName }: { id?: number; tripShortName?: string }) {
    this.id = id
    this.tripShortName = tripShortName
  }

  serialize(): JsonApiResource {
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
}

export default TripShortName
