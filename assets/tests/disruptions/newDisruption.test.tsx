import * as React from "react"

import { MemoryRouter, Route, Switch } from "react-router-dom"
import { act } from "react-dom/test-utils"
import { render, fireEvent, screen } from "@testing-library/react"
import { waitForElementToBeRemoved } from "@testing-library/dom"
import selectEvent from "react-select-event"

import * as api from "../../src/api"
import { NewDisruption } from "../../src/disruptions/newDisruption"

import Adjustment from "../../src/models/adjustment"

const withElement = (
  container: HTMLElement,
  selector: string,
  fn: (arg0: Element) => any
) => {
  const element = container.querySelector(selector)

  if (element) {
    fn(element)
  } else {
    throw new Error(`No element found for ${selector}`)
  }
}

describe("NewDisruption", () => {
  let apiCallSpy: jest.SpyInstance
  let apiSendSpy: jest.SpyInstance

  beforeEach(() => {
    apiCallSpy = jest.spyOn(api, "apiGet").mockImplementation(() => {
      return Promise.resolve([
        new Adjustment({
          id: "1",
          routeId: "Red",
          sourceLabel: "Broadway--Kendall/MIT",
        }),
        new Adjustment({
          id: "2",
          routeId: "Green-D",
          sourceLabel: "Kenmore--Newton Highlands",
        }),
        new Adjustment({
          id: "3",
          routeId: "CR-Fairmount",
          sourceLabel: "Fairmount--Newmarket",
        }),
      ])
    })
  })

  afterAll(() => {
    apiCallSpy.mockRestore()
    apiSendSpy.mockRestore()
  })

  test("header include link to homepage", async () => {
    const { container } = render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    expect(container.querySelector("#header-home-link")).not.toBeNull()
  })

  test("selecting a mode filters the available adjustments", async () => {
    const { container } = render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const commuterRailCheck = container.querySelector("#mode-commuter-rail")

    if (commuterRailCheck) {
      fireEvent.click(commuterRailCheck)
    } else {
      throw new Error("commuter rail check not found")
    }

    const adjustmentSelect = container.querySelector(
      "#adjustment-select"
    ) as HTMLElement

    if (adjustmentSelect) {
      selectEvent.openMenu(adjustmentSelect)
    } else {
      throw new Error("subway check not found")
    }

    let adjustmentOptions = container.querySelectorAll(
      ".adjustment-select__option"
    )
    expect(adjustmentOptions.length).toEqual(1)

    expect(adjustmentOptions.length).toBe(1)
    expect(adjustmentOptions[0].textContent).toEqual("Fairmount--Newmarket")

    const subwayCheck = container.querySelector("#mode-subway")

    if (subwayCheck) {
      fireEvent.click(subwayCheck)
    } else {
      throw new Error("subway check not found")
    }

    selectEvent.openMenu(adjustmentSelect)

    adjustmentOptions = container.querySelectorAll(".adjustment-select__option")

    expect(adjustmentOptions.length).toBe(2)
    expect(adjustmentOptions[0].textContent).toEqual("Broadway--Kendall/MIT")
    expect(adjustmentOptions[1].textContent).toEqual(
      "Kenmore--Newton Highlands"
    )
  })

  test("add another adjustment link not enabled by default", async () => {
    const { container } = render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const addAnotherLink = container.querySelector(
      "#add-another-adjustment-link"
    )
    expect(addAnotherLink).toBeNull()
  })

  test("ability to delete the only adjustment", async () => {
    const { container } = render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const adjustmentSelect = container.querySelector("#adjustment-select")

    if (adjustmentSelect) {
      await selectEvent.select(
        adjustmentSelect as HTMLElement,
        "Kenmore--Newton Highlands"
      )
    } else {
      throw new Error("adjustment selector not found")
    }

    expect(
      container.querySelectorAll(".adjustment-select__multi-value").length
    ).toEqual(1)

    const adjustmentDelete = container.querySelector(
      ".adjustment-select__multi-value__remove"
    )

    if (adjustmentDelete) {
      fireEvent.click(adjustmentDelete)
    } else {
      throw new Error("adjustment delete button not found")
    }

    expect(
      container.querySelectorAll(".adjustment-select__multi-value").length
    ).toEqual(0)
  })

  test("ability to delete an adjustment that isn't the only one", async () => {
    const { container } = render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const adjustmentSelect = container.querySelector("#adjustment-select")

    if (adjustmentSelect) {
      await selectEvent.select(
        adjustmentSelect as HTMLElement,
        "Kenmore--Newton Highlands"
      )
      await selectEvent.select(
        adjustmentSelect as HTMLElement,
        "Broadway--Kendall/MIT"
      )
    } else {
      throw new Error("adjustment selector not found")
    }

    let valueElements = container.querySelectorAll(
      ".adjustment-select__multi-value"
    )
    expect(valueElements.length).toEqual(2)
    expect(valueElements[0].textContent).toEqual("Kenmore--Newton Highlands")
    expect(valueElements[1].textContent).toEqual("Broadway--Kendall/MIT")

    const adjustmentDelete = container.querySelector(
      ".adjustment-select__multi-value__remove"
    )

    if (adjustmentDelete) {
      fireEvent.click(adjustmentDelete)
    } else {
      throw new Error("adjustment delete link not found")
    }

    valueElements = container.querySelectorAll(
      ".adjustment-select__multi-value"
    )

    expect(valueElements.length).toEqual(1)
    expect(valueElements[0].textContent).toEqual("Broadway--Kendall/MIT")
  })

  test("preview disruption", async () => {
    const { container } = render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const previewButton = container.querySelector("#preview-disruption-button")

    if (previewButton) {
      fireEvent.click(previewButton)
    } else {
      throw new Error("preview button not found")
    }

    expect(screen.getByText("When")).not.toBeNull()
  })

  test("can go back to edit from preview", async () => {
    const { container } = render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const previewButton = container.querySelector("#preview-disruption-button")

    if (previewButton) {
      fireEvent.click(previewButton)
    } else {
      throw new Error("preview button not found")
    }

    const backToEditLink = container.querySelector("#back-to-edit-link")

    if (backToEditLink) {
      fireEvent.click(backToEditLink)
    } else {
      throw new Error("back to edit link not found")
    }

    expect(screen.queryByText("When")).toBeNull()
  })

  test("handles error fetching / parsing adjustments", async () => {
    apiCallSpy = jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve("error")
    })

    render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    expect(
      screen.queryByText("Error loading or parsing adjustments.")
    ).not.toBeNull()
  })

  test("can create a disruption", async () => {
    apiSendSpy = jest.spyOn(api, "apiSend").mockImplementation(() => {
      return Promise.resolve({
        ok: {},
      })
    })

    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/new"]}>
        <Switch>
          <Route path="/disruptions/new" component={NewDisruption} />
          <Route path="/" render={() => <div>Success!!!</div>} />
        </Switch>
      </MemoryRouter>
    )
    await act(async () => {
      await waitForElementToBeRemoved(
        document.querySelector("#loading-indicator")
      )

      withElement(container, "#mode-commuter-rail", (el) => {
        fireEvent.click(el)
      })

      withElement(container, "#disruption-date-range-start", (el) => {
        fireEvent.change(el, { target: { value: "2020-03-31" } })
      })

      withElement(container, "#disruption-date-range-end", (el) => {
        fireEvent.change(el, { target: { value: "2020-04-30" } })
      })

      withElement(container, "#trips-some", (el) => {
        fireEvent.click(el)
      })

      withElement(container, "#trip-short-names", (el) => {
        fireEvent.change(el, { target: { value: "999,888" } })
      })

      withElement(container, "#trips-all", (el) => {
        fireEvent.click(el)
      })

      withElement(container, "#trips-some", (el) => {
        fireEvent.click(el)
      })

      withElement(container, "#trip-short-names", (el) => {
        fireEvent.change(el, { target: { value: "123,456" } })
      })
    })

    await selectEvent.select(
      container.querySelector("#adjustment-select") as HTMLElement,
      ["Fairmount--Newmarket"]
    )

    await act(async () => {
      withElement(container, "#preview-disruption-button", (el) => {
        fireEvent.click(el)
      })

      await screen.findByText("create disruption")

      withElement(container, "#disruption-preview-create", (el) => {
        fireEvent.click(el)
      })
    })

    await screen.findByText("Success!!!")
    const apiSendCall = apiSendSpy.mock.calls[0][0]
    const apiSendData = JSON.parse(apiSendCall.json)
    expect(apiSendCall.url).toEqual("/api/disruptions")
    expect(apiSendData.data.attributes.start_date).toEqual("2020-03-31")
    expect(apiSendData.data.attributes.end_date).toEqual("2020-04-30")
    expect(apiSendData.data.relationships.trip_short_names.data).toEqual([
      { attributes: { trip_short_name: "123" }, type: "trip_short_name" },
      { attributes: { trip_short_name: "456" }, type: "trip_short_name" },
    ])
    expect(
      apiSendData.data.relationships.adjustments.data[0].attributes.source_label
    ).toEqual("Fairmount--Newmarket")
  })

  test("handles errors with disruptions", async () => {
    apiSendSpy = jest.spyOn(api, "apiSend").mockImplementation(() => {
      return Promise.resolve({
        error: ["Data is all wrong"],
      })
    })

    await act(async () => {
      const { container } = render(
        <MemoryRouter initialEntries={["/disruptions/new"]}>
          <Switch>
            <Route path="/disruptions/new" component={NewDisruption} />
            <Route path="/" render={() => <div>Success!!!</div>} />
          </Switch>
        </MemoryRouter>
      )

      await waitForElementToBeRemoved(
        document.querySelector("#loading-indicator")
      )

      withElement(container, "#preview-disruption-button", (el) => {
        fireEvent.click(el)
      })

      withElement(container, "#disruption-preview-create", (el) => {
        fireEvent.click(el)
      })
    })

    await screen.findByText("Data is all wrong")
  })
})
