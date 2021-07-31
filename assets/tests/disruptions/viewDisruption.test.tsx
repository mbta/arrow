import * as React from "react"
import { act } from "react-dom/test-utils"
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

jest.mock("../../src/navigation", () => ({
  redirectTo: () => {
    return
  },
}))

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

    window.history.pushState({}, "title", "/disruptions/1?v=ready")
    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<ViewDisruption id="1" />, container)
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

    window.history.pushState({}, "title", "/disruptions/1?v=draft")

    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<ViewDisruption id="1" />, container)
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

    window.history.pushState({}, "title", "/disruptions/1?v=ready")
    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<ViewDisruption id="1" />, container)
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

    window.history.pushState({}, "title", "/disruptions/1?v=published")

    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<ViewDisruption id="1" />, container)
    })

    expect(container.textContent).toMatch(
      "Disruption 1 has no published revision"
    )
  })

  test("handles error on fetching / parsing", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve("error")
    })

    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<ViewDisruption id="1" />, container)
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

    window.history.pushState({}, "title", "/disruptions/1?v=published")
    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<ViewDisruption id="1" />, container)
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

    const { container } = render(<ViewDisruption id="1" />)

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

    window.history.pushState({}, "title", "/disruptions/1?v=ready")

    const { container, findByText } = render(<ViewDisruption id="1" />)

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

    window.history.pushState({}, "title", "/disruptions/1?v=ready")
    const { container, findByText } = render(<ViewDisruption id="1" />)

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

  test("can mark active draft revision as ready", async () => {
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

    window.history.pushState({}, "title", "/disruptions/1?v=draft")
    const { container, findByText } = render(<ViewDisruption id="1" />)

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

    window.history.pushState({}, "title", "/disruptions/1?v=draft")

    const { container, findByText } = render(<ViewDisruption id="1" />)

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

    window.history.pushState({}, "title", "/disruptions/1?v=draft")

    const { container, findByText } = render(<ViewDisruption id="1" />)

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

    window.history.pushState({}, "title", "/disruptions/1?v=draft")

    const { container, findByText } = render(<ViewDisruption id="1" />)

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

    window.history.pushState({}, "title", "/disruptions/1?v=ready")
    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<ViewDisruption id="1" />, container)
    })

    const editButton = container.querySelector(
      "a[href='/disruptions/1/edit']"
    ) as Element
    expect(editButton).toBeNull()
  })
})
