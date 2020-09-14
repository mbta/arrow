import DisruptionRevision from "./disruptionRevision"
import { ModelObject, loadRelationship } from "../jsonApi"

class DisruptionDiff {
  id: string
  disruptionRevision: DisruptionRevision
  isCreated: boolean
  diffs: string[][]

  constructor({
    id,
    disruptionRevision,
    isCreated,
    diffs,
  }: {
    id: string
    disruptionRevision: DisruptionRevision
    isCreated: boolean
    diffs: string[][]
  }) {
    this.id = id
    this.disruptionRevision = disruptionRevision
    this.isCreated = isCreated
    this.diffs = diffs
  }

  static fromJsonObject(
    raw: any,
    included: { [key: string]: ModelObject }
  ): DisruptionDiff | "error" {
    const attrs = raw.attributes
    const rels = raw.relationships

    if (typeof attrs === "object" && typeof rels === "object") {
      const id = raw.id
      const disruptionRevision = loadRelationship(
        rels.latest_revision,
        included
      )[0] as DisruptionRevision
      const isCreated = attrs["created?"]
      const diffs = attrs.diffs

      if (
        typeof id === "string" &&
        typeof disruptionRevision !== "undefined" &&
        typeof isCreated === "boolean"
      ) {
        return new DisruptionDiff({
          id,
          disruptionRevision,
          isCreated,
          diffs,
        })
      }
    }

    return "error"
  }
}

export default DisruptionDiff
