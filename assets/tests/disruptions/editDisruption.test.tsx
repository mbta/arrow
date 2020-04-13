import * as React from "react"
import { act } from "react-dom/test-utils"
import { MemoryRouter, Route, Switch } from "react-router-dom"
import { render, fireEvent, screen } from "@testing-library/react"
import { waitForElementToBeRemoved } from "@testing-library/dom"

import * as api from "../../src/api"
import EditDisruption from "../../src/disruptions/editDisruption"

import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Disruption from "../../src/models/disruption"
import Exception from "../../src/models/exception"

describe("EditDisruption", () => {
  let apiCallSpy: jest.SpyInstance
  let apiSendSpy: jest.SpyInstance

  beforeEach(() => {
    apiCallSpy = jest.spyOn(api, "apiGet").mockImplementation(() => {
      return Promise.resolve(
        new Disruption({
          id: "1",
          startDate: new Date("2020-01-15T00:00:00"),
          endDate: new Date("2020-01-30T00:00:00"),
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
              excludedDate: new Date("2020-01-20T00:00:00"),
            }),
          ],
          tripShortNames: [],
        })
      )
    })
  })

  afterAll(() => {
    apiCallSpy.mockRestore()
    apiSendSpy.mockRestore()
  })

  test("header include link to homepage", async () => {
    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    expect(container.querySelector("#header-home-link")).not.toBeNull()
  })

  test("cancel link redirects back to view page", async () => {
    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id"
            render={() => <div>Success!!!</div>}
          />
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const cancelButton = container.querySelector("#cancel-button")

    if (cancelButton) {
      fireEvent.click(cancelButton)
    } else {
      throw new Error("cancel button not found")
    }

    expect(screen.queryByText("Success!!!")).not.toBeNull()
  })

  test("handles error fetching disruption", async () => {
    apiCallSpy = jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve("error")
    })

    render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    expect(screen.getByText("Error loading disruption.")).not.toBeNull()
  })

  test("handles error with day of week information", async () => {
    apiCallSpy = jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve(
        new Disruption({
          adjustments: [],
          daysOfWeek: [
            new DayOfWeek({
              startTime: "20:37:00",
              dayName: "friday",
            }),
          ],
          exceptions: [],
          tripShortNames: [],
        })
      )
    })

    render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    expect(
      screen.queryByText("Error parsing day of week information.")
    ).not.toBeNull()
  })

  test("update start date", async () => {
    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const startDateInput = container.querySelector(
      "#disruption-date-range-start"
    )

    if (startDateInput) {
      fireEvent.change(startDateInput, { target: { value: "01/14/2020" } })
    } else {
      throw new Error("disruption date range start input not found")
    }

    expect(screen.queryByDisplayValue("01/14/2020")).not.toBeNull()
  })

  test("clear start date", async () => {
    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const startDateInput = container.querySelector(
      "#disruption-date-range-start"
    )

    if (startDateInput) {
      fireEvent.change(startDateInput, { target: { value: "" } })
    } else {
      throw new Error("disruption date range start input not found")
    }

    expect((startDateInput as HTMLInputElement).value).toEqual("")
  })

  test("update end date", async () => {
    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const startDateInput = container.querySelector("#disruption-date-range-end")

    if (startDateInput) {
      fireEvent.change(startDateInput, { target: { value: "01/19/2020" } })
    } else {
      throw new Error("disruption date range end input not found")
    }

    expect(screen.queryByDisplayValue("01/19/2020")).not.toBeNull()
  })

  test("clear end date", async () => {
    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const endDateInput = container.querySelector("#disruption-date-range-end")

    if (endDateInput) {
      fireEvent.change(endDateInput, { target: { value: "" } })
    } else {
      throw new Error("disruption date range start input not found")
    }

    expect((endDateInput as HTMLInputElement).value).toEqual("")
  })

  test("adding exception date", async () => {
    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const addExceptionLink = container.querySelector("#date-exception-add-link")

    if (addExceptionLink) {
      fireEvent.click(addExceptionLink)
    } else {
      throw new Error("add exception link not found")
    }

    const exceptionDateInput = container.querySelector(
      "#date-exception-new input"
    )

    if (exceptionDateInput) {
      fireEvent.change(exceptionDateInput, { target: { value: "01/21/2020" } })
    } else {
      throw new Error("new exception input not found")
    }

    expect(screen.queryByDisplayValue("01/21/2020")).not.toBeNull()
  })

  test("removing exception date", async () => {
    render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    fireEvent.click(screen.getByText("delete exception"))

    expect(screen.queryByDisplayValue("01/20/2020")).toBeNull()
  })

  test("adding and updating day of week", async () => {
    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const dayOfWeekMCheck = container.querySelector("#day-of-week-M")

    if (dayOfWeekMCheck) {
      fireEvent.click(dayOfWeekMCheck)
    } else {
      throw new Error("Monday checkbox not found")
    }

    const startOfServiceCheck = container.querySelector(
      "#time-of-day-start-type-0"
    )
    const endOfServiceCheck = container.querySelector("#time-of-day-end-type-0")
    const startHour = container.querySelector("#time-of-day-start-hour-0")
    const startMinute = container.querySelector("#time-of-day-start-minute-0")
    const startPeriod = container.querySelector("#time-of-day-start-period-0")
    const endHour = container.querySelector("#time-of-day-end-hour-0")
    const endMinute = container.querySelector("#time-of-day-end-minute-0")
    const endPeriod = container.querySelector("#time-of-day-end-period-0")

    if (
      startOfServiceCheck &&
      endOfServiceCheck &&
      startHour &&
      startMinute &&
      startPeriod &&
      endHour &&
      endMinute &&
      endPeriod
    ) {
      fireEvent.click(startOfServiceCheck)
      fireEvent.click(endOfServiceCheck)
      fireEvent.change(startHour, { target: { value: "8" } })
      fireEvent.change(startMinute, { target: { value: "30" } })
      fireEvent.change(startPeriod, { target: { value: "AM" } })
      fireEvent.change(endHour, { target: { value: "8" } })
      fireEvent.change(endMinute, { target: { value: "30" } })
      fireEvent.change(endPeriod, { target: { value: "PM" } })
    } else {
      throw new Error("day of week time range inputs not found")
    }

    expect((startHour as HTMLInputElement).value).toBe("8")
    expect((startMinute as HTMLInputElement).value).toBe("30")
    expect((startPeriod as HTMLInputElement).value).toBe("AM")
    expect((endHour as HTMLInputElement).value).toBe("8")
    expect((endMinute as HTMLInputElement).value).toBe("30")
    expect((endPeriod as HTMLInputElement).value).toBe("PM")
  })

  test("successfully creating disruption", async () => {
    apiSendSpy = jest.spyOn(api, "apiSend").mockImplementation(() => {
      return Promise.resolve({
        ok: {},
      })
    })

    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id"
            render={() => <div>Success!!!</div>}
          />
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const saveButton = container.querySelector("#save-changes-button")

    if (saveButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(saveButton)
      })
    } else {
      throw new Error("save button not found")
    }

    expect(screen.queryByText("Success!!!")).not.toBeNull()
  })

  test("handles error with saving disruption", async () => {
    apiSendSpy = jest.spyOn(api, "apiSend").mockImplementation(() => {
      return Promise.resolve({
        error: ["Data is all wrong"],
      })
    })

    const { container } = render(
      <MemoryRouter initialEntries={["/disruptions/foo/edit"]}>
        <Switch>
          <Route
            exact={true}
            path="/disruptions/:id"
            render={() => <div>Success!!!</div>}
          />
          <Route
            exact={true}
            path="/disruptions/:id/edit"
            component={EditDisruption}
          />
        </Switch>
      </MemoryRouter>
    )

    await waitForElementToBeRemoved(
      document.querySelector("#loading-indicator")
    )

    const saveButton = container.querySelector("#save-changes-button")

    if (saveButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(saveButton)
      })
    } else {
      throw new Error("save button not found")
    }

    expect(screen.getByText("Data is all wrong")).not.toBeNull()
  })
})
