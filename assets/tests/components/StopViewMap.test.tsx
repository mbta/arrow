import React from "react"
import { render } from "@testing-library/react"
import StopViewMap from "../../src/components/StopViewMap"

describe("StopViewMap", () => {
  test("renders", () => {
    const { container } = render(<StopViewMap />)
    expect(container.getElementsByClassName("leaflet-map-pane").length).toBe(1)
    expect(
      container.getElementsByClassName("leaflet-control-container").length
    ).toBe(1)
  })
})
