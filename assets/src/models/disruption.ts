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
  draftRevision?: DisruptionRevision
  revisions: DisruptionRevision[]

  constructor({
    id,
    lastPublishedAt,
    readyRevision,
    publishedRevision,
    draftRevision,
    revisions,
  }: {
    id?: string
    lastPublishedAt?: Date
    readyRevision?: DisruptionRevision
    publishedRevision?: DisruptionRevision
    draftRevision?: DisruptionRevision
    revisions: DisruptionRevision[]
  }) {
    super()
    this.id = id
    this.lastPublishedAt = lastPublishedAt
    this.readyRevision = readyRevision
    this.publishedRevision = publishedRevision
    this.draftRevision = draftRevision
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
      const revisions = (loadRelationship(
        raw.relationships.revisions,
        included
      ) as DisruptionRevision[]).sort((r1, r2) => {
        return parseInt(r1.id || "", 10) - parseInt(r2.id || "", 10)
      })
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
        draftRevision: revisions[revisions.length - 1],
        revisions,
      })

      if (disruption.draftRevision) {
        disruption.draftRevision.disruptionId = raw.id
        disruption.draftRevision.status = DisruptionView.Draft
      }

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

  getUniqueRevisions(): {
    published: DisruptionRevision | null
    ready: DisruptionRevision | null
    draft: DisruptionRevision | null
  } {
    return {
      published: this.publishedRevision || null,
      ready:
        this.readyRevision &&
        this.readyRevision.id !== this.publishedRevision?.id
          ? this.readyRevision
          : null,
      draft:
        this.draftRevision &&
        this.draftRevision.id !== this.readyRevision?.id &&
        this.draftRevision.id !== this.publishedRevision?.id
          ? this.draftRevision
          : null,
    }
  }

  static isOfType(obj: ModelObject): obj is Disruption {
    return obj instanceof Disruption
  }

  static uniqueRevisionFromDisruptionForView = (
    disruption: Disruption,
    view: DisruptionView
  ): DisruptionRevision | null => {
    const { published, ready, draft } = disruption.getUniqueRevisions()
    switch (view) {
      case DisruptionView.Draft:
        return draft
      case DisruptionView.Ready:
        return ready
      default:
        return published
    }
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
