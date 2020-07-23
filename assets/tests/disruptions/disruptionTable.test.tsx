import * as React from "react"
import { BrowserRouter } from "react-router-dom"
import { render, fireEvent, screen } from "@testing-library/react"
import { DisruptionTable } from "../../src/disruptions/disruptionTable"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Disruption from "../../src/models/disruption"

const DisruptionTableWithRouter = () => {
  return (
    <BrowserRouter>
      <DisruptionTable
        disruptions={[
          new Disruption({
            id: "1",
            startDate: new Date("2019-10-31"),
            endDate: new Date("2019-11-15"),
            adjustments: [new Adjustment({ routeId: "Red" })],
            daysOfWeek: [
              new DayOfWeek({
                id: "1",
                startTime: "20:45:00",
                dayName: "friday",
              }),
              new DayOfWeek({
                id: "2",
                dayName: "saturday",
              }),
              new DayOfWeek({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [],
            tripShortNames: [],
          }),
          new Disruption({
            id: "2",
            startDate: new Date("2019-10-23"),
            endDate: new Date("2019-10-24"),
            adjustments: [
              new Adjustment({
                routeId: "Green-D",
                sourceLabel: "Kenmore-Newton Highlands",
              }),
            ],
            daysOfWeek: [
              new DayOfWeek({
                id: "1",
                startTime: "20:45:00",
                dayName: "friday",
              }),
              new DayOfWeek({
                id: "2",
                dayName: "saturday",
              }),
              new DayOfWeek({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [],
            tripShortNames: [],
          }),
          new Disruption({
            id: "3",
            startDate: new Date("2019-09-22"),
            endDate: new Date("2019-10-22"),
            adjustments: [
              new Adjustment({
                routeId: "Green-D",
                sourceLabel: "Kenmore-Newton Highlands",
              }),
            ],
            daysOfWeek: [
              new DayOfWeek({
                id: "1",
                startTime: "20:45:00",
                dayName: "friday",
              }),
              new DayOfWeek({
                id: "2",
                dayName: "saturday",
              }),
              new DayOfWeek({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [],
            tripShortNames: [],
          }),
        ]}
      />
    </BrowserRouter>
  )
}

describe("DisruptionTable", () => {
  test("can sort table by 'stops' or 'dates'", () => {
    const { container } = render(<DisruptionTableWithRouter />)
    let tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(3)
    let firstRow = tableRows.item(0)
    let firstRowData = firstRow.querySelectorAll("td")
    expect(firstRowData.item(0).textContent).toEqual("Kenmore-Newton Highlands")
    expect(firstRowData.item(1).textContent).toEqual("10/23/2019 - 10/24/2019")
    expect(firstRowData.item(2).textContent).toEqual(
      "Friday 8:45PM - Sunday End of service"
    )
    expect(
      firstRowData.item(3).querySelectorAll("a[href='/disruptions/2']").length
    ).toEqual(1)
    let activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.asc, .m-disruption-table__sortable.desc"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    expect(activeSortToggle.textContent).toEqual("stops")
    expect(activeSortToggle.className).toMatch("asc")

    fireEvent.click(activeSortToggle)
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")

    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.asc, .m-disruption-table__sortable.desc"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    expect(activeSortToggle.textContent).toEqual("stops")
    expect(activeSortToggle.className).toMatch("desc")
    expect(firstRowData.item(0).textContent).toEqual("")

    const dateSort = screen.getByText("dates")
    fireEvent.click(dateSort)
    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.asc, .m-disruption-table__sortable.desc"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")
    expect(activeSortToggle.textContent).toEqual("dates")
    expect(activeSortToggle.className).toMatch("asc")
    expect(firstRowData.item(0).textContent).toEqual("Kenmore-Newton Highlands")
    expect(firstRowData.item(1).textContent).toEqual("9/22/2019 - 10/22/2019")
  })
})
