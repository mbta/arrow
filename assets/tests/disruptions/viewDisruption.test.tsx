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
import DisruptionRevision from "../../src/models/disruptionRevision"
import Exception from "../../src/models/exception"
import TripShortName from "../../src/models/tripShortName"

describe("ViewDisruption", () => {
  test("loads and displays disruption from the API", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          readyRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
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
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
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
            }),
          ],
        })
      )
    })

    const history = createBrowserHistory()
    history.push("/disruptions/1?v=ready")

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
              path: "/disruptions/1?v=ready",
              url: "https://localhost/disruptions/1?v=ready",
            }}
            history={history}
            location={{
              pathname: "/disruptions/1?v=ready",
              search: "?v=ready",
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
    expect(document.body.textContent).toMatch("123, 456")
    expect(document.body.textContent).toMatch("End of service")
  })

  test("indicates if revision does not exist for ready view", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          publishedRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
            adjustments: [],
            daysOfWeek: [],
            exceptions: [],
            tripShortNames: [],
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
              adjustments: [],
              daysOfWeek: [],
              exceptions: [],
              tripShortNames: [],
            }),
          ],
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
              path: "/disruptions/1?v=draft",
              url: "https://localhost/disruptions/1?v=draft",
            }}
            history={history}
            location={{
              pathname: "/disruptions/1?v=draft",
              search: "?v=draft",
              state: {},
              hash: "",
            }}
          />
        </BrowserRouter>,
        container
      )
    })

    expect(container.textContent).toMatch("Disruption 1 has no draft revision")
  })

  test("indicates if revision does not exist for draft view", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          draftRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
            adjustments: [],
            daysOfWeek: [],
            exceptions: [],
            tripShortNames: [],
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
              adjustments: [],
              daysOfWeek: [],
              exceptions: [],
              tripShortNames: [],
            }),
          ],
        })
      )
    })

    const history = createBrowserHistory()
    history.push("/disruptions/1?v=ready")

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
              path: "/disruptions/1?v=ready",
              url: "https://localhost/disruptions/1?v=ready",
            }}
            history={history}
            location={{
              pathname: "/disruptions/1?v=ready",
              search: "?v=ready",
              state: {},
              hash: "",
            }}
          />
        </BrowserRouter>,
        container
      )
    })

    expect(container.textContent).toMatch("Disruption 1 has no ready revision")
  })

  test("indicates if revision does not exist for published view", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          draftRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
            adjustments: [],
            daysOfWeek: [],
            exceptions: [],
            tripShortNames: [],
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
              adjustments: [],
              daysOfWeek: [],
              exceptions: [],
              tripShortNames: [],
            }),
          ],
        })
      )
    })

    const history = createBrowserHistory()
    history.push("/disruptions/1?v=published")

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
              path: "/disruptions/1?v=published",
              url: "https://localhost/disruptions/1?v=published",
            }}
            history={history}
            location={{
              pathname: "/disruptions/1?v=published",
              search: "?v=published",
              state: {},
              hash: "",
            }}
          />
        </BrowserRouter>,
        container
      )
    })

    expect(container.textContent).toMatch(
      "Disruption 1 has no published revision"
    )
  })

  test("edit link redirects to edit page", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          draftRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
            adjustments: [],
            daysOfWeek: [],
            exceptions: [],
            tripShortNames: [],
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
              adjustments: [],
              daysOfWeek: [],
              exceptions: [],
              tripShortNames: [],
            }),
          ],
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
              path: "/disruptions/1?v=draft",
              url: "https://localhost/disruptions/1?v=draft",
            }}
            history={history}
            location={{
              pathname: "/disruptions/1?v=draft",
              search: "?v=draft",
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
    // expect(editButton.textContent).toEqual("edit")

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
          publishedRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
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
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
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
            }),
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
          readyRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate,
            endDate,
            isActive: true,
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
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate,
              endDate,
              isActive: true,
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
            }),
          ],
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
          readyRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate,
            endDate,
            isActive: true,
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
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate,
              endDate,
              isActive: true,
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
            }),
          ],
        })
      )
    })

    const { container, findByText } = render(
      <MemoryRouter initialEntries={["/disruptions/1?v=ready"]}>
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
          // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
          ok: successParser!(null),
        })
      })

    if (deleteButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(deleteButton)
      })
    } else {
      throw new Error("delete button not found")
    }

    const confirmButton = await findByText("mark for deletion")
    if (confirmButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(confirmButton)
      })
    } else {
      throw new Error("confirm button not found")
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
          readyRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate,
            endDate,
            isActive: true,
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
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate,
              endDate,
              isActive: true,
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
            }),
          ],
        })
      )
    })

    const { container, findByText } = render(
      <MemoryRouter initialEntries={["/disruptions/1?v=ready"]}>
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

    if (deleteButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(deleteButton)
      })
    } else {
      throw new Error("delete button not found")
    }

    const confirmButton = await findByText("mark for deletion")
    if (confirmButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(confirmButton)
      })
    } else {
      throw new Error("confirm button not found")
    }

    expect(apiSendSpy).toBeCalled()

    expect(screen.getByText("Test error")).not.toBeNull()
  })

  test("can toggle between views", async () => {
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
          publishedRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate,
            endDate,
            isActive: true,
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
                startTime: "21:45:00",
                dayName: "friday",
              }),
            ],
            exceptions: [],
            tripShortNames: [],
          }),
          readyRevision: new DisruptionRevision({
            id: "2",
            disruptionId: "1",
            startDate,
            endDate,
            isActive: true,
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
          }),
          draftRevision: new DisruptionRevision({
            id: "3",
            disruptionId: "1",
            startDate,
            endDate,
            isActive: true,
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
                startTime: "19:45:00",
                dayName: "friday",
              }),
            ],
            exceptions: [],
            tripShortNames: [],
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate,
              endDate,
              isActive: true,
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
            }),
            new DisruptionRevision({
              id: "2",
              disruptionId: "1",
              startDate,
              endDate,
              isActive: true,
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
                  startTime: "21:00:00",
                  dayName: "friday",
                }),
              ],
              exceptions: [],
              tripShortNames: [],
            }),
          ],
        })
      )
    })

    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/1?v=ready"]}>
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
      url: "/api/disruptions/1",
      parser: toModelObject,
      defaultResult: "error",
    })

    const publishedButton = container.querySelector("#published")
    expect(publishedButton?.classList).not.toContain("active")
    const readyButton = container.querySelector("#ready")
    expect(readyButton?.classList).toContain("active")
    const draftButton = container.querySelector("#draft")
    expect(draftButton?.classList).not.toContain("active")
    expect(container.querySelector("#edit-disruption-link")).toBeNull()
    expect(container.querySelector("#delete-disruption-button")).not.toBeNull()
    expect(container.textContent).toContain("8:45PM")

    if (draftButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(draftButton)
      })
    } else {
      throw new Error("draft button not found")
    }

    expect(publishedButton?.classList).not.toContain("active")
    expect(readyButton?.classList).not.toContain("active")
    expect(draftButton?.classList).toContain("active")
    expect(container.querySelector("#edit-disruption-link")).not.toBeNull()
    expect(container.querySelector("#delete-disruption-button")).not.toBeNull()
    expect(container.textContent).toContain("7:45PM")

    if (publishedButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(publishedButton)
      })
    } else {
      throw new Error("published button not found")
    }

    expect(publishedButton?.classList).toContain("active")
    expect(readyButton?.classList).not.toContain("active")
    expect(draftButton?.classList).not.toContain("active")
    expect(container.querySelector("#edit-disruption-link")).toBeNull()
    expect(container.querySelector("#delete-disruption-button")).not.toBeNull()
    expect(container.textContent).toContain("9:45PM")
  })

  test("can mark active draft revision as ready", async () => {
    const mockHistoryReplace = jest.fn()

    jest.mock("react-router-dom", () => ({
      useHistory: () => ({
        replace: mockHistoryReplace,
      }),
    }))
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
          draftRevision: new DisruptionRevision({
            id: "3",
            disruptionId: "1",
            startDate,
            endDate,
            isActive: true,
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
                startTime: "19:45:00",
                dayName: "friday",
              }),
            ],
            exceptions: [],
            tripShortNames: [],
          }),
          revisions: [],
        })
      )
    })

    const { container, findByText } = render(
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

    expect(spy).toHaveBeenCalledWith({
      url: "/api/disruptions/1",
      parser: toModelObject,
      defaultResult: "error",
    })

    const apiSendSpy = jest.spyOn(api, "apiSend").mockImplementationOnce(() => {
      return Promise.resolve({
        ok: null,
      })
    })

    const readyButton = container.querySelector("#mark-ready")
    if (!readyButton) {
      throw new Error("mark as ready button not found")
    }
    expect(readyButton.textContent).toEqual("mark as ready")
    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      fireEvent.click(readyButton)
    })
    const confirmButton = await findByText("yes, mark as ready")
    if (confirmButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(confirmButton)
      })
    } else {
      throw new Error("confirm button not found")
    }
    expect(apiSendSpy).toBeCalledWith({
      url: "/api/ready_notice/",
      method: "POST",
      json: JSON.stringify({ revision_ids: "3" }),
    })
    expect(spy).toBeCalledTimes(2)
  })

  test("can mark deleted draft revision as ready", async () => {
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
          draftRevision: new DisruptionRevision({
            id: "3",
            disruptionId: "1",
            startDate,
            endDate,
            isActive: false,
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
                startTime: "19:45:00",
                dayName: "friday",
              }),
            ],
            exceptions: [],
            tripShortNames: [],
          }),
          revisions: [],
        })
      )
    })

    const { container, findByText } = render(
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

    expect(spy).toHaveBeenCalledWith({
      url: "/api/disruptions/1",
      parser: toModelObject,
      defaultResult: "error",
    })

    const apiSendSpy = jest.spyOn(api, "apiSend").mockImplementationOnce(() => {
      return Promise.resolve({
        ok: null,
      })
    })

    const readyButton = container.querySelector("#mark-ready")
    if (!readyButton) {
      throw new Error("mark as ready button not found")
    }
    expect(readyButton.textContent).toEqual("mark as ready for deletion")
    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      fireEvent.click(readyButton)
    })
    const confirmButton = await findByText("yes, mark as ready")
    if (confirmButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(confirmButton)
      })
    } else {
      throw new Error("confirm button not found")
    }

    expect(apiSendSpy).toBeCalledWith({
      url: "/api/ready_notice/",
      method: "POST",
      json: JSON.stringify({ revision_ids: "3" }),
    })

    expect(spy).toBeCalledTimes(2)
  })

  test("can cancel marking ready", async () => {
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
          draftRevision: new DisruptionRevision({
            id: "3",
            disruptionId: "1",
            startDate,
            endDate,
            isActive: false,
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
                startTime: "19:45:00",
                dayName: "friday",
              }),
            ],
            exceptions: [],
            tripShortNames: [],
          }),
          revisions: [],
        })
      )
    })

    const { container, findByText } = render(
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

    expect(spy).toHaveBeenCalledWith({
      url: "/api/disruptions/1",
      parser: toModelObject,
      defaultResult: "error",
    })

    const apiSendSpy = jest.spyOn(api, "apiSend")

    const readyButton = container.querySelector("#mark-ready")
    if (!readyButton) {
      throw new Error("mark as ready button not found")
    }
    expect(readyButton.textContent).toEqual("mark as ready for deletion")
    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      fireEvent.click(readyButton)
    })
    const cancel = await findByText("cancel")
    if (cancel) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(cancel)
      })
    } else {
      throw new Error("cancel button not found")
    }
    expect(apiSendSpy).not.toHaveBeenCalled()
    expect(spy).toBeCalledTimes(1)
    apiSendSpy.mockClear()
  })

  test("handles error marking draft revision as ready", async () => {
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
          draftRevision: new DisruptionRevision({
            id: "3",
            disruptionId: "1",
            startDate,
            endDate,
            isActive: false,
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
                startTime: "19:45:00",
                dayName: "friday",
              }),
            ],
            exceptions: [],
            tripShortNames: [],
          }),
          revisions: [],
        })
      )
    })

    const { container, findByText } = render(
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

    expect(spy).toHaveBeenCalledWith({
      url: "/api/disruptions/1",
      parser: toModelObject,
      defaultResult: "error",
    })

    const apiSendSpy = jest.spyOn(api, "apiSend").mockImplementationOnce(() => {
      return Promise.reject()
    })

    const readyButton = container.querySelector("#mark-ready")
    if (!readyButton) {
      throw new Error("mark as ready button not found")
    }
    expect(readyButton.textContent).toEqual("mark as ready for deletion")
    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      fireEvent.click(readyButton)
    })
    const confirmButton = await findByText("yes, mark as ready")
    if (confirmButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(confirmButton)
      })
    } else {
      throw new Error("confirm button not found")
    }
    expect(apiSendSpy).toBeCalledWith({
      url: "/api/ready_notice/",
      method: "POST",
      json: JSON.stringify({ revision_ids: "3" }),
    })
    expect(spy).toBeCalledTimes(1)
  })

  test("does not display 'create new disruption' button if any revision is deleted", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          readyRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: false,
            adjustments: [],
            daysOfWeek: [],
            exceptions: [],
            tripShortNames: [],
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
              adjustments: [],
              daysOfWeek: [],
              exceptions: [],
              tripShortNames: [],
            }),
          ],
        })
      )
    })

    const history = createBrowserHistory()
    history.push("/disruptions/1?v=ready")

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
              path: "/disruptions/1?v=ready",
              url: "https://localhost/disruptions/1?v=ready",
            }}
            history={history}
            location={{
              pathname: "/disruptions/1?v=ready",
              search: "?v=ready",
              state: {},
              hash: "",
            }}
          />
        </BrowserRouter>,
        container
      )
    })

    const editButton = container.querySelector(
      "a[href='/disruptions/1/edit']"
    ) as Element
    expect(editButton).toBeNull()
  })
})
