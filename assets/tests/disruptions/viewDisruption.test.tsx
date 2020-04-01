import { createBrowserHistory } from "history"
import * as React from "react"
import { BrowserRouter } from "react-router-dom"
import { act } from "react-dom/test-utils"
import * as ReactDOM from "react-dom"
import * as api from "../../src/api"

import ViewDisruption from "../../src/disruptions/viewDisruption"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Disruption from "../../src/models/disruption"
import Exception from "../../src/models/exception"

describe("ViewDisruption", () => {
  test("loads and displays disruption from the API", async () => {
    jest.spyOn(api, "apiCall").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          startDate: new Date("2020-01-15"),
          endDate: new Date("2020-01-30"),
          adjustments: [
            new Adjustment({
              id: "1",
              routeId: "Green-D",
              source: "gtfs_creator",
              sourceLabel: "NewtonHighlandsKenmore",
            }),
          ],
          daysOfWeek: [
            new DayOfWeek({
              id: "1",
              startTime: "20:45:00",
              day: "friday",
            }),
          ],
          exceptions: [
            new Exception({
              id: "1",
              excludedDate: new Date("2020-01-20"),
            }),
          ],
          tripShortNames: [],
        })
      )
    })

    const history = createBrowserHistory()

    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(
        <BrowserRouter>
          <ViewDisruption
            match={{
              params: { id: "1" },
              isExact: true,
              path: "/disruptions/1",
              url: "https://localhost/disruptions/1",
            }}
            history={history}
            location={{
              pathname: "/disruptions/1",
              search: "",
              state: {},
              hash: "",
            }}
          />
        </BrowserRouter>,
        container
      )
    })

    expect(document.body.textContent).toMatch("NewtonHighlandsKenmore")
    expect(document.body.textContent).toMatch("1/15/2020")
    expect(document.body.textContent).toMatch("1/30/2020")
    expect(document.body.textContent).toMatch("1/20/2020")
    expect(document.body.textContent).toMatch("Friday")
    expect(document.body.textContent).toMatch("8:45PM")
    expect(document.body.textContent).toMatch("End of service")
  })

  test("edit link redirects to edit page", async () => {
    jest.spyOn(api, "apiCall").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          startDate: new Date("2020-01-15"),
          endDate: new Date("2020-01-30"),
          adjustments: [],
          daysOfWeek: [],
          exceptions: [],
          tripShortNames: [],
        })
      )
    })

    const history = createBrowserHistory()

    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(
        <BrowserRouter>
          <ViewDisruption
            match={{
              params: { id: "1" },
              isExact: true,
              path: "/disruptions/1",
              url: "https://localhost/disruptions/1",
            }}
            history={history}
            location={{
              pathname: "/disruptions/1",
              search: "",
              state: {},
              hash: "",
            }}
          />
        </BrowserRouter>,
        container
      )
    })

    const editButton = container.querySelector(
      "#edit-disruption-button"
    ) as Element
    expect(editButton).toBeDefined()
    expect(editButton.textContent).toEqual("edit disruption times")

    act(() => {
      editButton.dispatchEvent(new MouseEvent("click", { bubbles: true }))
    })

    expect(location.pathname).toBe("/disruptions/1/edit")
  })

  test("handles error on fetching / parsing", async () => {
    jest.spyOn(api, "apiCall").mockImplementationOnce(() => {
      return Promise.resolve("error")
    })

    const history = createBrowserHistory()

    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(
        <BrowserRouter>
          <ViewDisruption
            match={{
              params: { id: "1" },
              isExact: true,
              path: "/disruptions/1",
              url: "https://localhost/disruptions/1",
            }}
            history={history}
            location={{
              pathname: "/disruptions/1",
              search: "",
              state: {},
              hash: "",
            }}
          />
        </BrowserRouter>,
        container
      )
    })

    expect(document.body.textContent).toMatch(
      "Error fetching or parsing disruption."
    )
  })

  test("handles error with day of week values", async () => {
    jest.spyOn(api, "apiCall").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          startDate: new Date("2020-01-15"),
          endDate: new Date("2020-01-30"),
          adjustments: [
            new Adjustment({
              id: "1",
              routeId: "Green-D",
              source: "gtfs_creator",
              sourceLabel: "NewtonHighlandsKenmore",
            }),
          ],
          daysOfWeek: [
            new DayOfWeek({
              id: "1",
              startTime: "20:37:00",
              day: "friday",
            }),
          ],
          exceptions: [
            new Exception({
              id: "1",
              excludedDate: new Date("2020-01-20"),
            }),
          ],
          tripShortNames: [],
        })
      )
    })

    const history = createBrowserHistory()

    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(
        <BrowserRouter>
          <ViewDisruption
            match={{
              params: { id: "1" },
              isExact: true,
              path: "/disruptions/1",
              url: "https://localhost/disruptions/1",
            }}
            history={history}
            location={{
              pathname: "/disruptions/1",
              search: "",
              state: {},
              hash: "",
            }}
          />
        </BrowserRouter>,
        container
      )
    })

    expect(document.body.textContent).toMatch(
      "Error parsing day of week information."
    )
  })
})
