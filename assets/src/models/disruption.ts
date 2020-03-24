import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"
import { ModelObject } from "../jsonApi"

import Adjustment from "./adjustment"
import DayOfWeek from "./dayOfWeek"
import Exception from "./exception"
import TripShortName from "./tripShortName"

class Disruption extends JsonApiResourceObject {
  id?: string
  startDate?: Date
  endDate?: Date

  adjustments: Adjustment[]
  daysOfWeek: DayOfWeek[]
  exceptions: Exception[]
  tripShortNames: TripShortName[]

  constructor({
    id,
    endDate,
    startDate,
    adjustments,
    daysOfWeek,
    exceptions,
    tripShortNames,
  }: {
    id?: string
    startDate?: Date
    endDate?: Date
    adjustments: Adjustment[]
    daysOfWeek: DayOfWeek[]
    exceptions: Exception[]
    tripShortNames: TripShortName[]
  }) {
    super()
    this.id = id
    this.endDate = endDate
    this.startDate = startDate
    this.adjustments = adjustments
    this.daysOfWeek = daysOfWeek
    this.exceptions = exceptions
    this.tripShortNames = tripShortNames
  }

  toJsonApi(): JsonApiResource {
    return {
      data: this.toJsonApiData(),
    }
  }

  toJsonApiData(): JsonApiResourceData {
    return {
      type: "disruption",
      ...(this.id && { id: this.id.toString() }),
      attributes: {
        ...(this.startDate && {
          start_date: this.startDate.toISOString().slice(0, 10),
        }),
        ...(this.endDate && {
          end_date: this.endDate.toISOString().slice(0, 10),
        }),
      },
      relationships: {
        adjustment: { data: this.adjustments.map(adj => adj.toJsonApiData()) },
        day_of_week: { data: this.daysOfWeek.map(dow => dow.toJsonApiData()) },
        exceptions: { data: this.exceptions.map(ex => ex.toJsonApiData()) },
        trip_short_name: {
          data: this.tripShortNames.map(tsn => tsn.toJsonApiData()),
        },
      },
    }
  }

  static fromJsonObject(
    raw: any,
    included: ModelObject[]
  ): Disruption | "error" {
    if (typeof raw.attributes === "object") {
      return new Disruption({
        id: raw.id,
        startDate: new Date(raw.attributes.start_date),
        endDate: new Date(raw.attributes.end_date),
        adjustments: included.filter(i => i instanceof Adjustment),
        daysOfWeek: included.filter(i => i instanceof DayOfWeek),
        exceptions: included.filter(i => i instanceof Exception),
        tripShortNames: included.filter(i => i instanceof TripShortName),
      })
    }

    return "error"
  }
}

export default Disruption
