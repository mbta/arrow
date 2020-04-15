import * as React from "react"
import { render, screen } from "@testing-library/react"
import { DisruptionSummary } from "../../src/disruptions/disruptionSummary"

import Adjustment from "../../src/models/adjustment"

describe("DisruptionSummary", () => {
  test("renders the adjustments onto the page", () => {
    const { container } = render(
      <DisruptionSummary
        adjustments={[
          new Adjustment({ routeId: "route1", sourceLabel: "adjustment1" }),
          new Adjustment({ routeId: "route2", sourceLabel: "adjustment2" }),
        ]}
      />
    )

    expect(container.querySelectorAll("li").length).toEqual(2)
  })

  test("renders the disruption ID if present", () => {
    render(
      <DisruptionSummary
        disruptionId={"123"}
        adjustments={[
          new Adjustment({ routeId: "route1", sourceLabel: "adjustment1" }),
          new Adjustment({ routeId: "route2", sourceLabel: "adjustment2" }),
        ]}
      />
    )

    expect(screen.queryAllByText("Disruption ID: 123")).not.toBeNull()
  })
})
