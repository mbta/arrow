import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"
import { ModelObject } from "../jsonApi"

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

  static fromJsonObject(
    raw: any,
    _included: ModelObject[]
  ): Adjustment | "error" {
    if (typeof raw.attributes === "object") {
      let source: Source | undefined

      switch (raw.attributes.source) {
        case "arrow":
          source = "arrow"
          break
        case "gtfs_creator":
          source = "gtfs_creator"
          break
        default:
          return "error"
      }

      return new Adjustment({
        id: raw.id,
        routeId: raw.attributes.route_id || undefined,
        source,
        sourceLabel: raw.attributes.source_label || undefined,
      })
    }

    return "error"
  }
}

export default Adjustment
