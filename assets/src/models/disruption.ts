import { JsonApiResource, JsonApiResourceData } from "../jsonApiResource"
import JsonApiResourceObject from "../jsonApiResourceObject"
import {
  ModelObject,
  loadRelationship,
  loadSingleRelationship,
} from "../jsonApi"

enum DisruptionView {
  Draft,
  Ready,
  Published,
}

import DisruptionRevision from "./disruptionRevision"

class Disruption extends JsonApiResourceObject {
  id?: string
  lastPublishedAt?: Date
  readyRevision?: DisruptionRevision
  publishedRevision?: DisruptionRevision
  revisions: DisruptionRevision[]

  constructor({
    id,
    lastPublishedAt,
    readyRevision,
    publishedRevision,
    revisions,
  }: {
    id?: string
    lastPublishedAt?: Date
    readyRevision?: DisruptionRevision
    publishedRevision?: DisruptionRevision
    revisions: DisruptionRevision[]
  }) {
    super()
    this.id = id
    this.lastPublishedAt = lastPublishedAt
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
        lastPublishedAt:
          raw.attributes.last_published_at &&
          new Date(raw.attributes.last_published_at),
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

  static revisionFromDisruptionForView = (
    disruption: Disruption,
    view: DisruptionView
  ): DisruptionRevision | undefined => {
    switch (view) {
      case DisruptionView.Draft: {
        const sortedRevisions = disruption.revisions.sort((r1, r2) => {
          return parseInt(r1.id || "", 10) - parseInt(r2.id || "", 10)
        })

        return sortedRevisions[sortedRevisions.length - 1]
      }
      case DisruptionView.Ready: {
        return disruption.readyRevision
      }
      case DisruptionView.Published: {
        return disruption.publishedRevision
      }
    }
  }
}

export { DisruptionView }
export default Disruption
