import DisruptionDiff from "../../src/models/disruptionDiff"

describe("DisruptionDiff", () => {
  test("Handles parse error", () => {
    expect(DisruptionDiff.fromJsonObject({}, {})).toEqual("error")
  })
})
