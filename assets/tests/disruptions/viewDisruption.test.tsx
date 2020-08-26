import { createBrowserHistory } from "history"
import * as React from "react"
import { BrowserRouter } from "react-router-dom"
import { act } from "react-dom/test-utils"
import { MemoryRouter, Route, Switch } from "react-router-dom"
import * as ReactDOM from "react-dom"
import * as api from "../../src/api"
import { toModelObject } from "../../src/jsonApi"

import { render, fireEvent, screen } from "@testing-library/react"
import { waitForElementToBeRemoved } from "@testing-library/dom"

import ViewDisruption from "../../src/disruptions/viewDisruption"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Disruption from "../../src/models/disruption"
import Exception from "../../src/models/exception"
import TripShortName from "../../src/models/tripShortName"

describe("ViewDisruption", () => {
  test("loads and displays disruption from the API", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
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
              dayName: "friday",
            }),
          ],
          exceptions: [
            new Exception({
              id: "1",
              excludedDate: new Date("2020-01-20"),
            }),
          ],
          tripShortNames: [
            new TripShortName({ tripShortName: "123" }),
            new TripShortName({ tripShortName: "456" }),
          ],
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
    expect(document.body.textContent).toMatch("Trips: 123, 456")
    expect(document.body.textContent).toMatch("End of service")
  })

  test("edit link redirects to edit page", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
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
    history.push("/disruptions/1?v=draft")

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
      "#edit-disruption-link"
    ) as Element
    expect(editButton).toBeDefined()
    expect(editButton.textContent).toEqual("edit disruption times")

    act(() => {
      editButton.dispatchEvent(new MouseEvent("click", { bubbles: true }))
    })

    expect(location.pathname).toBe("/disruptions/1/edit")
  })

  test("handles error on fetching / parsing", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
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
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
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
              dayName: "friday",
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

  test("doesn't display delete button for disruption that started in the past", async () => {
    let startDate = new Date()
    startDate.setTime(startDate.getTime() - 24 * 60 * 60 * 1000)
    startDate = new Date(startDate.toDateString())

    const endDate = new Date(new Date().toDateString())

    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          startDate,
          endDate,
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
              dayName: "friday",
            }),
          ],
          exceptions: [],
          tripShortNames: [],
        })
      )
    })

    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/1"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/"
            component={ViewDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const deleteButton = container.querySelector("#delete-disruption-button")

    expect(deleteButton).toBeNull()
  })

  test("can delete a disruption", async () => {
    let startDate = new Date()
    startDate.setTime(startDate.getTime() + 24 * 60 * 60 * 1000)
    startDate = new Date(startDate.toDateString())

    let endDate = new Date()
    startDate.setTime(startDate.getTime() + 2 * 24 * 60 * 60 * 1000)
    endDate = new Date(endDate.toDateString())

    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          startDate,
          endDate,
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
              dayName: "friday",
            }),
          ],
          exceptions: [],
          tripShortNames: [],
        })
      )
    })

    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/1?v=draft"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/"
            component={ViewDisruption}
          />
          <Route exact={true} path="/" render={() => <div>Success!!!</div>} />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const deleteButton = container.querySelector(
      "#delete-disruption-button"
    ) as Element

    const apiSendSpy = jest
      .spyOn(api, "apiSend")
      .mockImplementationOnce(({ successParser }) => {
        return Promise.resolve({
          ok: successParser(null),
        })
      })

    jest.spyOn(window, "confirm").mockImplementationOnce(() => {
      return true
    })

    if (deleteButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(deleteButton)
      })
    } else {
      throw new Error("delete button not found")
    }

    expect(apiSendSpy).toBeCalled()

    expect(screen.queryByText("Success!!!")).not.toBeNull()
  })

  test("handles errors from deleting a disruption", async () => {
    let startDate = new Date()
    startDate.setTime(startDate.getTime() + 24 * 60 * 60 * 1000)
    startDate = new Date(startDate.toDateString())

    let endDate = new Date()
    startDate.setTime(startDate.getTime() + 2 * 24 * 60 * 60 * 1000)
    endDate = new Date(endDate.toDateString())

    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          startDate,
          endDate,
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
              dayName: "friday",
            }),
          ],
          exceptions: [],
          tripShortNames: [],
        })
      )
    })

    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/1?v=draft"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/"
            component={ViewDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const deleteButton = container.querySelector(
      "#delete-disruption-button"
    ) as Element

    const apiSendSpy = jest.spyOn(api, "apiSend").mockImplementationOnce(() => {
      return Promise.resolve({
        error: ["Test error"],
      })
    })

    jest.spyOn(window, "confirm").mockImplementationOnce(() => {
      return true
    })

    if (deleteButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(deleteButton)
      })
    } else {
      throw new Error("delete button not found")
    }

    expect(apiSendSpy).toBeCalled()

    expect(screen.getByText("Test error")).not.toBeNull()
  })

  test("can toggle between published and draft view", async () => {
    let startDate = new Date()
    startDate.setTime(startDate.getTime() + 24 * 60 * 60 * 1000)
    startDate = new Date(startDate.toDateString())

    let endDate = new Date()
    startDate.setTime(startDate.getTime() + 2 * 24 * 60 * 60 * 1000)
    endDate = new Date(endDate.toDateString())

    const spy = jest.spyOn(api, "apiGet").mockImplementation(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          startDate,
          endDate,
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
              dayName: "friday",
            }),
          ],
          exceptions: [],
          tripShortNames: [],
        })
      )
    })

    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/1"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/"
            component={ViewDisruption}
          />
          <Route exact={true} path="/" render={() => <div>Success!!!</div>} />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    expect(spy).toHaveBeenCalledWith({
      url: "/api/disruptions/1?only_published=true",
      parser: toModelObject,
      defaultResult: "error",
    })

    const publishedButton = container.querySelector("#published")
    expect(publishedButton?.classList).toContain("active")
    const draftButton = container.querySelector("#draft")
    expect(draftButton?.classList).not.toContain("active")
    expect(container.querySelector("#edit-disruption-link")).toBeNull()
    expect(container.querySelector("#delete-disruption-button")).toBeNull()

    if (draftButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(draftButton)
      })
    } else {
      throw new Error("draft button not found")
    }

    expect(spy).toHaveBeenCalledWith({
      url: "/api/disruptions/1?only_published=false",
      parser: toModelObject,
      defaultResult: "error",
    })
    expect(publishedButton?.classList).not.toContain("active")
    expect(draftButton?.classList).toContain("active")
    expect(container.querySelector("#edit-disruption-link")).not.toBeNull()
    expect(container.querySelector("#delete-disruption-button")).not.toBeNull()
  })
})
