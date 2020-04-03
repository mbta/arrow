import * as React from "react"

import { render, fireEvent, screen } from "@testing-library/react"
import { waitForElementToBeRemoved } from "@testing-library/dom"

import * as api from "../../src/api"
import { NewDisruption } from "../../src/disruptions/newDisruption"

import Adjustment from "../../src/models/adjustment"

describe("NewDisruption", () => {
  let apiCallSpy: jest.SpyInstance

  beforeEach(() => {
    apiCallSpy = jest.spyOn(api, "apiCall").mockImplementation(() => {
      return Promise.resolve([
        new Adjustment({
          routeId: "Red",
          sourceLabel: "Broadway--Kendall/MIT",
        }),
        new Adjustment({
          routeId: "Green-D",
          sourceLabel: "Kenmore--Newton Highlands",
        }),
        new Adjustment({
          routeId: "CR-Fairmount",
          sourceLabel: "Fairmount--Newmarket",
        }),
      ])
    })
  })

  afterAll(() => {
    apiCallSpy.mockRestore()
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

    let adjustmentOptions = container
      .querySelector("#adjustment-select-0")
      ?.querySelectorAll("option") as NodeList

    let fairmountOptions: Node[] = []
    let redOptions: Node[] = []

    adjustmentOptions.forEach((option: Node) => {
      if (option.textContent === "Fairmount--Newmarket") {
        fairmountOptions = fairmountOptions.concat([option])
      } else if (option.textContent === "Broadway--Kendall/MIT") {
        redOptions = redOptions.concat([option])
      }
    })

    expect(fairmountOptions.length).toBe(1)
    expect(redOptions.length).toBe(0)

    const subwayCheck = container.querySelector("#mode-subway")

    if (subwayCheck) {
      fireEvent.click(subwayCheck)
    } else {
      throw new Error("subway check not found")
    }

    adjustmentOptions = container
      .querySelector("#adjustment-select-0")
      ?.querySelectorAll("option") as NodeList

    fairmountOptions = []
    redOptions = []

    adjustmentOptions.forEach((option: Node) => {
      if (option.textContent === "Fairmount--Newmarket") {
        fairmountOptions = fairmountOptions.concat([option])
      } else if (option.textContent === "Broadway--Kendall/MIT") {
        redOptions = redOptions.concat([option])
      }
    })

    expect(fairmountOptions.length).toBe(0)
    expect(redOptions.length).toBe(1)
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

  test("choosing one adjustment enabled link to choose another", async () => {
    const { container } = render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const adjustmentSelect = container.querySelector("#adjustment-select-0")

    if (adjustmentSelect) {
      fireEvent.change(adjustmentSelect, {
        target: { value: "Kenmore--Newton Highlands" },
      })
    } else {
      throw new Error("adjustment selector not found")
    }

    const addAnotherLink = container.querySelector(
      "#add-another-adjustment-link"
    )

    expect(addAnotherLink).not.toBeNull()
  })

  test("ability to delete the only adjustment", async () => {
    const { container } = render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const adjustmentSelect = container.querySelector("#adjustment-select-0")

    if (adjustmentSelect) {
      fireEvent.change(adjustmentSelect, {
        target: { value: "Kenmore--Newton Highlands" },
      })
    } else {
      throw new Error("adjustment selector not found")
    }

    const adjustmentDelete = container.querySelector("#adjustment-delete-0")

    if (adjustmentDelete) {
      fireEvent.click(adjustmentDelete)
    } else {
      throw new Error("adjustment delete link not found")
    }

    expect(container.querySelector("#adjustment-select-0")).toBeNull()
  })

  test("ability to delete an adjustment that isn't the only one", async () => {
    const { container } = render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const adjustmentSelect0 = container.querySelector("#adjustment-select-0")

    if (adjustmentSelect0) {
      fireEvent.change(adjustmentSelect0, {
        target: { value: "Kenmore--Newton Highlands" },
      })
    } else {
      throw new Error("adjustment selector not found")
    }

    const addAnotherLink = container.querySelector(
      "#add-another-adjustment-link"
    )

    if (addAnotherLink) {
      fireEvent.click(addAnotherLink)
    } else {
      throw new Error("add another adjustment link not found")
    }

    const adjustmentSelect1 = container.querySelector("#adjustment-select-1")

    if (adjustmentSelect1) {
      fireEvent.change(adjustmentSelect1, {
        target: { value: "Broadway--Kendall/MIT" },
      })
    } else {
      throw new Error("adjustment selector not found")
    }

    const adjustmentDelete1 = container.querySelector("#adjustment-delete-1")

    if (adjustmentDelete1) {
      fireEvent.click(adjustmentDelete1)
    } else {
      throw new Error("adjustment delete link not found")
    }

    expect(container.querySelector("#adjustment-select-1")).toBeNull()

    expect(
      container.querySelector("#add-another-adjustment-link")
    ).toBeDefined()
  })

  test("ability to update a chosen adjustment", async () => {
    const { container } = render(<NewDisruption />)

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    let adjustmentSelect0 = container.querySelector("#adjustment-select-0")

    if (adjustmentSelect0) {
      fireEvent.change(adjustmentSelect0, {
        target: { value: "Safely ignores this event" },
      })
      fireEvent.change(adjustmentSelect0, {
        target: { value: "Kenmore--Newton Highlands" },
      })
      fireEvent.change(adjustmentSelect0, {
        target: { value: "Safely ignores this one, too" },
      })
    } else {
      throw new Error("adjustment selector not found")
    }

    expect(
      (container?.querySelector("#adjustment-select-0") as HTMLSelectElement)
        .value
    ).toBe("Kenmore--Newton Highlands")

    adjustmentSelect0 = container.querySelector("#adjustment-select-0")

    if (adjustmentSelect0) {
      fireEvent.change(adjustmentSelect0, {
        target: { value: "Broadway--Kendall/MIT" },
      })
    } else {
      throw new Error("adjustment selector not found")
    }

    expect(
      (container?.querySelector("#adjustment-select-0") as HTMLSelectElement)
        .value
    ).toBe("Broadway--Kendall/MIT")
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
    apiCallSpy = jest.spyOn(api, "apiCall").mockImplementationOnce(() => {
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
})
