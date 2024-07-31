import React from "react"
import { render } from "@testing-library/react"
import ShapeViewMap from "../../src/components/ShapeViewMap"

describe("ShapeViewMap", () => {
  test("renders", () => {
    const { container } = render(<ShapeViewMap shapes={[]} />)
    expect(container.getElementsByClassName("leaflet-map-pane").length).toBe(1)
    expect(
      container.getElementsByClassName("leaflet-control-container").length
    ).toBe(1)
  })
})
