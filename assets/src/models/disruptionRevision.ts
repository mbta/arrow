import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"
import { ModelObject, toUTCDate, loadRelationship } from "../jsonApi"

import Adjustment from "./adjustment"
import DayOfWeek from "./dayOfWeek"
import Exception from "./exception"
import TripShortName from "./tripShortName"

class DisruptionRevision extends JsonApiResourceObject {
  id?: string
  disruptionId?: string
  startDate?: Date
  endDate?: Date
  isActive: boolean

  adjustments: Adjustment[]
  daysOfWeek: DayOfWeek[]
  exceptions: Exception[]
  tripShortNames: TripShortName[]

  constructor({
    id,
    disruptionId,
    startDate,
    endDate,
    isActive,
    adjustments,
    daysOfWeek,
    exceptions,
    tripShortNames,
  }: {
    id?: string
    disruptionId?: string
    startDate?: Date
    endDate?: Date
    isActive: boolean
    adjustments: Adjustment[]
    daysOfWeek: DayOfWeek[]
    exceptions: Exception[]
    tripShortNames: TripShortName[]
  }) {
    super()
    this.id = id
    this.disruptionId = disruptionId
    this.startDate = startDate
    this.endDate = endDate
    this.isActive = isActive
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
      type: "disruption_revision",
      ...(this.id && { id: this.id.toString() }),
      attributes: {
        ...(this.startDate && {
          start_date: this.startDate.toISOString().slice(0, 10),
        }),
        ...(this.endDate && {
          end_date: this.endDate.toISOString().slice(0, 10),
        }),
        is_active: this.isActive,
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
  ): DisruptionRevision | "error" {
    if (
      typeof raw.attributes === "object" &&
      typeof raw.relationships === "object"
    ) {
      return new DisruptionRevision({
        id: raw.id,
        ...(raw.attributes.start_date && {
          startDate: toUTCDate(raw.attributes.start_date),
        }),
        ...(raw.attributes.end_date && {
          endDate: toUTCDate(raw.attributes.end_date),
        }),
        isActive: raw.attributes.is_active,
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

  static isOfType(obj: ModelObject): obj is DisruptionRevision {
    return obj instanceof DisruptionRevision
  }
}

export default DisruptionRevision
