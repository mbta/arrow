import * as React from "react"
import { render } from "@testing-library/react"
import { DisruptionListContainer } from "../../src/disruptions/disruptionListContainer"
import { Router } from "react-router-dom"
import { createMemoryHistory } from "history"

describe("DisruptionListContainer", () => {
  test("renders nav links with indicator for active link", () => {
    const history = createMemoryHistory()
    const { container } = render(
      <Router history={history}>
        <DisruptionListContainer>content</DisruptionListContainer>
      </Router>
    )

    let links = container.getElementsByClassName(
      "m-disruption-list-container_nav-link"
    )
    expect(links.length).toEqual(2)
    expect(links[0].textContent).toEqual("Disruptions")
    expect(links[0].classList).toContain("active")
    expect(links[1].textContent).toEqual("Needs Review")
    expect(links[1].classList).not.toContain("active")

    history.push("/disruptions/needs_review")
    links = container.getElementsByClassName(
      "m-disruption-list-container_nav-link"
    )
    expect(links.length).toEqual(2)
    expect(links[0].textContent).toEqual("Disruptions")
    expect(links[0].classList).not.toContain("active")
    expect(links[1].textContent).toEqual("Needs Review")
    expect(links[1].classList).toContain("active")
  })

  test("renders content", () => {
    const history = createMemoryHistory()
    const { container } = render(
      <Router history={history}>
        <DisruptionListContainer>My Content Here!</DisruptionListContainer>
      </Router>
    )
    expect(container.textContent).toContain("My Content Here!")
  })
})
