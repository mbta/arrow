import * as React from "react"
import { render, screen } from "@testing-library/react"
import Loading from "../src/loading"

describe("Loading", () => {
  test('says "Loading"', () => {
    render(<Loading />)

    expect(screen.queryByText("Loading…")).toBeInTheDocument()
  })
})
