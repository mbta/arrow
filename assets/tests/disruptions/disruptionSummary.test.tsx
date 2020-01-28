import * as React from "react"
import * as renderer from "react-test-renderer"
import { DisruptionSummary } from "../../src/disruptions/disruptionSummary"

describe("DisruptionSummary", () => {
  test("renders the adjustments onto the page", () => {
    const summary = (
      <DisruptionSummary
        adjustments={[
          { label: "adjustment1", route: "route1" },
          { label: "adjustment2", route: "route2" },
        ]}
      />
    )

    const testInstance = renderer.create(summary).root
    expect(testInstance.findAllByType("li").length).toEqual(2)
  })
})
