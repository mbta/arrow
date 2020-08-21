import * as React from "react"
import { render, screen } from "@testing-library/react"
import { Page } from "../src/page"

describe("Page", () => {
  test("conditionally renders home link", () => {
    const { container } = render(
      <Page includeHomeLink={true}>
        <div id="content">Your content here!!!</div>
      </Page>
    )
    let link = container.getElementsByTagName("a")[0]
    expect(link.textContent).toContain("back to home")

    const { container: containerWithoutLink } = render(
      <Page includeHomeLink={true}>
        <div id="content">Your content here!!!</div>
      </Page>
    )
    link = containerWithoutLink.getElementsByTagName("a")[0]
    expect(link).not.toBeUndefined()
  })
  test("renders children", () => {
    render(
      <Page>
        <div id="content">Your content here!!!</div>
      </Page>
    )
    expect(screen.getByText("Your content here!!!")).toBeDefined()
  })
})
