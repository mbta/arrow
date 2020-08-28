import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"
import { ModelObject, toUTCDate, loadRelationship } from "../jsonApi"

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
        adjustments: {
          data: this.adjustments.map((adj) => adj.toJsonApiData()),
        },
        days_of_week: {
          data: this.daysOfWeek.map((dow) => dow.toJsonApiData()),
        },
        exceptions: { data: this.exceptions.map((ex) => ex.toJsonApiData()) },
        trip_short_names: {
          data: this.tripShortNames.map((tsn) => tsn.toJsonApiData()),
        },
      },
    }
  }

  static fromJsonObject(
    raw: any,
    included: { [key: string]: ModelObject }
  ): Disruption | "error" {
    if (
      typeof raw.attributes === "object" &&
      typeof raw.relationships === "object"
    ) {
      return new Disruption({
        id: raw.id,
        ...(raw.attributes.start_date && {
          startDate: toUTCDate(raw.attributes.start_date),
        }),
        ...(raw.attributes.end_date && {
          endDate: toUTCDate(raw.attributes.end_date),
        }),
        adjustments: loadRelationship(
          raw.relationships.adjustments,
          included
        ) as Adjustment[],
        daysOfWeek: loadRelationship(
          raw.relationships.days_of_week,
          included
        ) as DayOfWeek[],
        exceptions: (loadRelationship(
          raw.relationships.exceptions,
          included
        ) as Exception[]).sort(
          (a, b) => a.excludedDate.getTime() - b.excludedDate.getTime()
        ),
        tripShortNames: loadRelationship(
          raw.relationships.trip_short_names,
          included
        ) as TripShortName[],
      })
    }

    return "error"
  }

  static isOfType(obj: ModelObject): obj is Disruption {
    return obj instanceof Disruption
  }
}

export default Disruption
