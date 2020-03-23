import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"

type Source = "gtfs_creator" | "arrow"

class Adjustment extends JsonApiResourceObject {
  id?: string
  routeId?: string
  source?: Source
  sourceLabel?: string

  constructor({
    id,
    routeId,
    source,
    sourceLabel,
  }: {
    id?: string
    routeId?: string
    source?: Source
    sourceLabel?: string
  }) {
    super()
    this.id = id
    this.routeId = routeId
    this.source = source
    this.sourceLabel = sourceLabel
  }

  toJsonApi(): JsonApiResource {
    return {
      data: this.toJsonApiData(),
    }
  }

  toJsonApiData(): JsonApiResourceData {
    return {
      type: "adjustment",
      ...(this.id && { id: this.id.toString() }),
      attributes: {
        ...(this.routeId && { route_id: this.routeId }),
        ...(this.source && { source: this.source }),
        ...(this.sourceLabel && { source_label: this.sourceLabel }),
      },
    }
  }

  static fromJsonApi(raw: any): Adjustment | "error" {
    if (typeof raw === "object") {
      if (raw.data?.type === "adjustment") {
        return new Adjustment({})
      }
    }

    return "error"
  }
}

export default Adjustment
