import * as React from "react"
import { render } from "@testing-library/react"
import Header from "../src/header"

describe("Header", () => {
  test("includes link to homepage when includeHomeLink set", () => {
    const { container } = render(<Header includeHomeLink={true} />)

    expect(container.querySelectorAll("a").length).toBe(1)
  })

  test("doesn't include link to homepage when includeHomeLink not set", () => {
    const { container } = render(<Header includeHomeLink={false} />)

    expect(container.querySelectorAll("a").length).toBe(0)
  })
})
