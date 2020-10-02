import * as React from "react"
import { render } from "@testing-library/react"
import { AdjustmentSummary } from "../../src/disruptions/adjustmentSummary"

import Adjustment from "../../src/models/adjustment"

describe("AdjustmentSummary", () => {
  test("renders the adjustments onto the page", () => {
    const { container } = render(
      <AdjustmentSummary
        adjustments={[
          new Adjustment({
            id: "1",
            routeId: "route1",
            sourceLabel: "adjustment1",
          }),
          new Adjustment({
            id: "2",
            routeId: "route2",
            sourceLabel: "adjustment2",
          }),
        ]}
      />
    )

    expect(container.querySelectorAll("li").length).toEqual(2)
  })
})
