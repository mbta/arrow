import JsonApiResource from "../jsonApiResource"

type Source = "gtfs_creator" | "arrow"

class Adjustment {
  id?: number
  routeId?: string
  source?: Source
  sourceLabel?: string

  constructor({
    id,
    routeId,
    source,
    sourceLabel,
  }: {
    id?: number
    routeId?: string
    source?: Source
    sourceLabel?: string
  }) {
    this.id = id
    this.routeId = routeId
    this.source = source
    this.sourceLabel = sourceLabel
  }

  toJsonApi(): JsonApiResource {
    return {
      data: {
        type: "adjustment",
        ...(this.id && { id: this.id.toString() }),
        attributes: {
          ...(this.routeId && { route_id: this.routeId }),
          ...(this.source && { source: this.source }),
          ...(this.sourceLabel && { source_label: this.sourceLabel }),
        },
      },
    }
  }
}

export default Adjustment
