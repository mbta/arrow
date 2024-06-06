import React from "react"
import { render, screen, within } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import DisruptionForm from "../../src/components/DisruptionForm"
import { pickDate } from "../testHelpers"

describe("DisruptionForm", () => {
  const adjustments = [
    { id: 1, label: "Alewife", kind: "red_line" as const },
    { id: 2, label: "Bowdoin", kind: "blue_line" as const },
    { id: 3, label: "Lowell", kind: "commuter_rail" as const },
    { id: 4, label: "Worcester", kind: "commuter_rail" as const },
    { id: 5, label: "Nubian", kind: "silver_line" as const },
  ]

  const blankRevision = {
    title: "",
    startDate: null,
    endDate: null,
    rowApproved: true,
    description: "",
    adjustmentKind: null,
    adjustments: [],
    daysOfWeek: {},
    exceptions: [],
    tripShortNames: "",
  }

  const withinFieldset = (name: string) =>
    within(screen.getByRole("group", { name }))

  test("allows editing the attributes of a disruption revision", () => {
    render(
      <form aria-label="test">
        <DisruptionForm
          allAdjustments={adjustments}
          disruptionRevision={{
            ...blankRevision,
            startDate: "2021-01-01",
            endDate: "2021-01-31",
            rowApproved: true,
            adjustmentKind: null,
            adjustments: [{ id: 3, label: "Lowell", kind: "commuter_rail" }],
            daysOfWeek: {
              monday: { start: null, end: null },
              tuesday: { start: "20:00:00", end: null },
            },
            exceptions: ["2021-01-11", "2021-01-12"],
            tripShortNames: "trip1,trip2",
          }}
          iconPaths={{}}
        />
      </form>
    )

    userEvent.type(
      withinFieldset("description").getByRole("textbox"),
      "Worcester test disruption"
    )
    userEvent.type(
      withinFieldset("title").getByRole("textbox"),
      "Worcester test disruption title"
    )
    const limits = withinFieldset("limits")
    userEvent.click(limits.getByRole("textbox"))
    userEvent.click(limits.getByText("Worcester"))
    userEvent.type(screen.getByLabelText("Trip short names"), "{backspace}3")
    pickDate(screen.getByLabelText("start"), "01/04/2021")
    pickDate(screen.getByLabelText("end"), "01/29/2021")
    const days = withinFieldset("Choose days of week")
    userEvent.click(days.getByText("Mon"))
    userEvent.click(days.getByText("Wed"))
    const wednesday = withinFieldset("Wednesday")
    userEvent.click(wednesday.getByLabelText("Start of service"))
    userEvent.selectOptions(wednesday.getByLabelText("start hour"), "4")
    userEvent.selectOptions(wednesday.getByLabelText("start minute"), "30")
    userEvent.selectOptions(wednesday.getByLabelText("start meridiem"), "PM")
    userEvent.click(screen.getAllByLabelText("remove")[0])
    userEvent.click(screen.getByRole("button", { name: /add an exception/ }))
    const exceptions = withinFieldset("exceptions").getAllByRole("textbox")
    pickDate(exceptions[exceptions.length - 1], "01/13/2021")

    expect(screen.getByRole("form")).toHaveFormValues({
      "revision[adjustments][id]": ["3", "4"],
      "revision[start_date]": "2021-01-04",
      "revision[end_date]": "2021-01-29",
      "revision[description]": "Worcester test disruption",
      "revision[adjustment_kind]": "",
      "revision[days_of_week][0][day_name]": "tuesday",
      "revision[days_of_week][0][start_time]": "20:00:00",
      "revision[days_of_week][0][end_time]": "",
      "revision[days_of_week][1][day_name]": "wednesday",
      "revision[days_of_week][1][start_time]": "16:30:00",
      "revision[days_of_week][1][end_time]": "",
      "revision[exceptions][0][excluded_date]": "2021-01-12",
      "revision[exceptions][1][excluded_date]": "2021-01-13",
      "revision[trip_short_names][0][trip_short_name]": "trip1",
      "revision[trip_short_names][1][trip_short_name]": "trip3",
      "revision[title]": "Worcester test disruption title",
    })
  })

  test("changes the available adjustments based on the selected mode", () => {
    render(
      <DisruptionForm
        allAdjustments={adjustments}
        disruptionRevision={blankRevision}
        iconPaths={{}}
      />
    )

    userEvent.click(screen.getByLabelText("Subway"))
    const limits = withinFieldset("limits")
    userEvent.click(limits.getByRole("textbox"))
    expect(limits.queryByText("Alewife")).toBeInTheDocument()
    expect(limits.queryByText("Lowell")).not.toBeInTheDocument()
    expect(limits.queryByText("Nubian")).not.toBeInTheDocument()

    userEvent.click(screen.getByLabelText("Commuter Rail"))
    userEvent.click(limits.getByRole("textbox"))
    expect(limits.queryByText("Alewife")).not.toBeInTheDocument()
    expect(limits.queryByText("Lowell")).toBeInTheDocument()
    expect(limits.queryByText("Nubian")).not.toBeInTheDocument()

    userEvent.click(screen.getByLabelText("Silver Line"))
    userEvent.click(limits.getByRole("textbox"))
    expect(limits.queryByText("Alewife")).not.toBeInTheDocument()
    expect(limits.queryByText("Lowell")).not.toBeInTheDocument()
    expect(limits.queryByText("Nubian")).toBeInTheDocument()

    // limits cannot be set for bus
    userEvent.click(screen.getByLabelText("Bus"))
    expect(
      screen.queryByRole("group", { name: "limits" })
    ).not.toBeInTheDocument()
  })

  test("can indicate a new adjustment is being requested", () => {
    render(
      <form aria-label="test">
        <DisruptionForm
          allAdjustments={adjustments}
          disruptionRevision={blankRevision}
          iconPaths={{}}
        />
      </form>
    )

    userEvent.click(screen.getByLabelText("Silver Line"))
    const limits = withinFieldset("limits")
    userEvent.click(limits.getByLabelText("request a new diverted route"))

    expect(screen.getByRole("form")).toHaveFormValues({
      "revision[adjustment_kind]": "silver_line",
    })
  })

  test("can request an adjustment for a specific subway line", () => {
    render(
      <form aria-label="test">
        <DisruptionForm
          allAdjustments={adjustments}
          disruptionRevision={blankRevision}
          iconPaths={{}}
        />
      </form>
    )

    userEvent.click(screen.getByLabelText("Subway"))
    const limits = withinFieldset("limits")
    userEvent.click(limits.getByLabelText("request a new diverted route"))
    userEvent.click(limits.getByLabelText("Blue Line"))

    expect(screen.getByRole("form")).toHaveFormValues({
      "revision[adjustment_kind]": "blue_line",
    })
  })

  test("defaults subway disruptions to start at 8:45PM on weekdays", () => {
    render(
      <DisruptionForm
        allAdjustments={adjustments}
        disruptionRevision={blankRevision}
        iconPaths={{}}
      />
    )

    userEvent.click(screen.getByLabelText("Subway"))
    userEvent.click(withinFieldset("Choose days of week").getByText("Mon"))
    const monday = withinFieldset("Monday")
    expect(monday.getByLabelText("start hour")).toHaveValue("8")
    expect(monday.getByLabelText("start minute")).toHaveValue("45")
    expect(monday.getByLabelText("start meridiem")).toHaveValue("PM")

    userEvent.click(screen.getByLabelText("Commuter Rail"))
    userEvent.click(withinFieldset("Choose days of week").getByText("Tue"))
    const tuesday = withinFieldset("Tuesday")
    expect(tuesday.getByLabelText("Start of service")).toBeChecked()
  })
})
