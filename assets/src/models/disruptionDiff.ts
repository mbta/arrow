import Disruption from "./disruption"
import { ModelObject, loadRelationship } from "../jsonApi"

class DisruptionDiff {
  id: string
  disruption: Disruption
  isCreated: boolean
  diffs: string[][]

  constructor({
    id,
    disruption,
    isCreated,
    diffs,
  }: {
    id: string
    disruption: Disruption
    isCreated: boolean
    diffs: string[][]
  }) {
    this.id = id
    this.disruption = disruption
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
      const disruption = loadRelationship(
        rels.latest_revision,
        included
      )[0] as Disruption
      const isCreated = attrs["created?"]
      const diffs = attrs.diffs

      if (
        typeof id === "string" &&
        typeof disruption !== "undefined" &&
        typeof isCreated === "boolean"
      ) {
        return new DisruptionDiff({
          id,
          disruption,
          isCreated,
          diffs,
        })
      }
    }

    return "error"
  }
}

export default DisruptionDiff
