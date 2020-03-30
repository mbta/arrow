import * as React from "react"
import { mount } from "enzyme"
import Loading from "../src/loading"

describe("Loading", () => {
  test('says "Loading"', () => {
    const text = mount(<Loading />).text()

    expect(text).toMatch("Loading")
  })
})
