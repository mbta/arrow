import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"
import {
  ModelObject,
  loadRelationship,
  loadSingleRelationship,
} from "../jsonApi"

import DisruptionRevision from "./disruptionRevision"
import { DisruptionView } from "../disruptions/viewToggle"

class Disruption extends JsonApiResourceObject {
  id?: string
  readyRevision?: DisruptionRevision
  publishedRevision?: DisruptionRevision
  revisions: DisruptionRevision[]

  constructor({
    id,
    readyRevision,
    publishedRevision,
    revisions,
  }: {
    id?: string
    readyRevision?: DisruptionRevision
    publishedRevision?: DisruptionRevision
    revisions: DisruptionRevision[]
  }) {
    super()
    this.id = id
    this.readyRevision = readyRevision
    this.publishedRevision = publishedRevision
    this.revisions = revisions
  }

  toJsonApi(): JsonApiResource {
    return {
      data: this.toJsonApiData(),
    }
  }

  toJsonApiData(): JsonApiResourceData {
    // Implement later if we actually need it
    return {
      type: "disruption",
      attributes: {},
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
      const revisions = loadRelationship(
        raw.relationships.revisions,
        included
      ) as DisruptionRevision[]
      const disruption = new Disruption({
        id: raw.id,
        readyRevision: loadSingleRelationship(
          raw.relationships.ready_revision,
          included
        ) as DisruptionRevision,
        publishedRevision: loadSingleRelationship(
          raw.relationships.published_revision,
          included
        ) as DisruptionRevision,
        revisions,
      })

      if (disruption.readyRevision) {
        disruption.readyRevision.disruptionId = raw.id
        disruption.readyRevision.status = DisruptionView.Ready
      }

      if (disruption.publishedRevision) {
        disruption.publishedRevision.disruptionId = raw.id
        disruption.publishedRevision.status = DisruptionView.Published
      }

      disruption.revisions = disruption.revisions.map((dr) => {
        dr.disruptionId = raw.id
        return dr
      })

      return disruption
    }

    return "error"
  }

  static isOfType(obj: ModelObject): obj is Disruption {
    return obj instanceof Disruption
  }
}

export default Disruption
