import * as React from "react"
import { mount } from "enzyme"
import * as renderer from "react-test-renderer"
import { DisruptionSummary } from "../../src/disruptions/disruptionSummary"

import Adjustment from "../../src/models/adjustment"

describe("DisruptionSummary", () => {
  test("renders the adjustments onto the page", () => {
    const summary = (
      <DisruptionSummary
        adjustments={[
          new Adjustment({ routeId: "route1", sourceLabel: "adjustment1" }),
          new Adjustment({ routeId: "route2", sourceLabel: "adjustment2" }),
        ]}
      />
    )

    const testInstance = renderer.create(summary).root
    expect(testInstance.findAllByType("li").length).toEqual(2)
  })

  test("renders the disruption ID if present", () => {
    const text = mount(
      <DisruptionSummary
        disruptionId={"123"}
        adjustments={[
          new Adjustment({ routeId: "route1", sourceLabel: "adjustment1" }),
          new Adjustment({ routeId: "route2", sourceLabel: "adjustment2" }),
        ]}
      />
    ).text()

    expect(text).toMatch("Disruption ID: 123")
  })
})
