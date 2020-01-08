import * as React from "react"
import * as renderer from "react-test-renderer"
import Header from "../src/header"

describe("Header", () => {
  test("includes link to homepage when includeHomeLink set", () => {
    const testInstance = renderer.create(<Header includeHomeLink={true} />).root

    expect(testInstance.findAllByType("a").length).toBe(1)
  })

  test("doesn't include link to homepage when includeHomeLink not set", () => {
    const testInstance = renderer.create(<Header includeHomeLink={false} />)
      .root

    expect(testInstance.findAllByType("a").length).toBe(0)
  })
})
