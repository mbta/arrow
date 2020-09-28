import * as React from "react"
import { MemoryRouter } from "react-router-dom"
import { render, fireEvent, screen } from "@testing-library/react"
import { DisruptionTable } from "../../src/disruptions/disruptionTable"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import DisruptionRevision from "../../src/models/disruptionRevision"
import { DisruptionView } from "../../src/models/disruption"
import Exception from "../../src/models/exception"

const DisruptionTableWithRouter = ({
  initialEntries,
}: {
  initialEntries?: string[]
}) => {
  return (
    <MemoryRouter initialEntries={initialEntries}>
      <DisruptionTable
        selectEnabled={false}
        toggleRevisionSelection={() => true}
        disruptionRevisions={[
          new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2019-10-31"),
            endDate: new Date("2019-11-15"),
            isActive: false,
            adjustments: [
              new Adjustment({
                id: "1",
                routeId: "Red",
                sourceLabel: "NorthQuincyQuincyCenter",
              }),
              new Adjustment({
                id: "2",
                routeId: "Green-D",
                sourceLabel: "Kenmore-Newton Highlands",
              }),
            ],
            daysOfWeek: [
              new DayOfWeek({
                id: "1",
                startTime: "20:45:00",
                dayName: "thursday",
              }),
              new DayOfWeek({
                id: "2",
                dayName: "friday",
              }),
              new DayOfWeek({
                id: "3",
                dayName: "saturday",
              }),
            ],
            exceptions: [
              new Exception({ excludedDate: new Date("2019-10-30") }),
            ],
            tripShortNames: [],
            status: DisruptionView.Draft,
          }),
          new DisruptionRevision({
            id: "4",
            disruptionId: "1",
            startDate: new Date("2019-10-31"),
            endDate: new Date("2019-11-16"),
            isActive: false,
            adjustments: [
              new Adjustment({
                id: "1",
                routeId: "Red",
                sourceLabel: "NorthQuincyQuincyCenter",
              }),
              new Adjustment({
                id: "2",
                routeId: "Green-D",
                sourceLabel: "Kenmore-Newton Highlands",
              }),
            ],
            daysOfWeek: [
              new DayOfWeek({
                id: "1",
                startTime: "20:45:00",
                dayName: "thursday",
              }),
              new DayOfWeek({
                id: "2",
                dayName: "friday",
              }),
              new DayOfWeek({
                id: "3",
                dayName: "saturday",
              }),
            ],
            exceptions: [
              new Exception({ excludedDate: new Date("2019-10-31") }),
            ],
            tripShortNames: [],
            status: DisruptionView.Draft,
          }),
          new DisruptionRevision({
            id: "2",
            disruptionId: "2",
            startDate: new Date("2019-10-23"),
            endDate: new Date("2019-10-24"),
            isActive: true,
            adjustments: [
              new Adjustment({
                id: "2",
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
            status: DisruptionView.Published,
          }),
          new DisruptionRevision({
            id: "3",
            disruptionId: "3",
            startDate: new Date("2019-09-22"),
            endDate: new Date("2019-10-22"),
            isActive: true,
            adjustments: [
              new Adjustment({
                id: "2",
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
            status: DisruptionView.Ready,
          }),
        ].map((revision) => {
          return {
            selected: false,
            selectable: false,
            selectEnabled: false,
            revision,
          }
        })}
      />
    </MemoryRouter>
  )
}

describe("DisruptionTable", () => {
  test("displays rowlette if the revision's parent shares the same label", () => {
    const { container } = render(<DisruptionTableWithRouter />)
    const tableRows = container.querySelectorAll("tbody tr")
    expect(
      tableRows.item(2).querySelectorAll("td").item(0).textContent
    ).toEqual("NorthQuincyQuincyCenterKenmore-Newton Highlands")
    expect(
      tableRows.item(3).querySelectorAll("td").item(0).textContent
    ).toEqual("↘")
  })

  test("displays difference between rows", () => {
    const { container } = render(<DisruptionTableWithRouter />)
    const tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(4)
    const firstRow = tableRows.item(2)
    const firstRowData = firstRow.querySelectorAll("td")
    firstRowData.forEach((td) => {
      expect(td.classList.contains("text-muted")).toEqual(false)
    })
    expect(firstRowData.item(0).textContent).toEqual(
      "NorthQuincyQuincyCenterKenmore-Newton Highlands"
    )
    expect(firstRowData.item(1).textContent).toEqual("10/31/201911/15/2019")
    expect(firstRowData.item(2).textContent).toEqual("1")
    expect(
      firstRowData.item(1).querySelectorAll("div").item(0).textContent
    ).toEqual("10/31/2019")
    expect(
      firstRowData
        .item(1)
        .querySelectorAll("div")
        .item(0)
        .classList.contains("text-muted")
    ).toEqual(false)
    expect(
      firstRowData.item(1).querySelectorAll("div").item(1).textContent
    ).toEqual("11/15/2019")
    expect(
      firstRowData
        .item(1)
        .querySelectorAll("div")
        .item(1)
        .classList.contains("text-muted")
    ).toEqual(false)

    const nextRow = tableRows.item(3)
    const nextRowData = nextRow.querySelectorAll("td")
    expect(nextRowData.item(0).textContent).toEqual("↘")
    expect(
      nextRowData.item(1).querySelectorAll("div").item(0).textContent
    ).toEqual("10/31/2019")
    expect(
      nextRowData
        .item(1)
        .querySelectorAll("div")
        .item(0)
        .classList.contains("text-muted")
    ).toEqual(true)
    expect(
      nextRowData.item(1).querySelectorAll("div").item(1).textContent
    ).toEqual("11/16/2019")
    expect(
      nextRowData
        .item(1)
        .querySelectorAll("div")
        .item(1)
        .classList.contains("text-muted")
    ).toEqual(false)
    expect(nextRowData.item(2).textContent).toEqual("1")
    expect(nextRowData.item(2).classList.contains("text-muted")).toEqual(false)
  })

  test("can sort table by columns", () => {
    const { container } = render(<DisruptionTableWithRouter />)
    let tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(4)
    let firstRow = tableRows.item(0)
    let firstRowData = firstRow.querySelectorAll("td")
    expect(firstRowData.item(0).textContent).toEqual("Kenmore-Newton Highlands")
    expect(firstRowData.item(1).textContent).toContain("10/23/2019")
    expect(firstRowData.item(1).textContent).toContain("10/24/2019")
    expect(firstRowData.item(2).textContent).toEqual("0")
    expect(firstRowData.item(3).textContent).toEqual(
      "Fri 8:45PM - Sun End of service"
    )
    expect(firstRowData.item(4).textContent).toEqual("published")
    expect(
      firstRowData
        .item(5)
        .querySelectorAll("a[href='/disruptions/2?v=published']").length
    ).toEqual(1)
    let activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    expect(activeSortToggle.textContent).toEqual("adjustments↑")

    fireEvent.click(activeSortToggle)
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")

    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    expect(activeSortToggle.textContent).toEqual("adjustments↓")
    expect(firstRowData.item(0).textContent).toEqual(
      "NorthQuincyQuincyCenterKenmore-Newton Highlands"
    )

    const dateSort = screen.getByText("date range")
    fireEvent.click(dateSort)
    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")
    expect(activeSortToggle.textContent).toEqual("date range↑")
    expect(firstRowData.item(0).textContent).toEqual("Kenmore-Newton Highlands")
    expect(firstRowData.item(1).textContent).toContain("9/22/2019")
    expect(firstRowData.item(1).textContent).toContain("10/22/2019")

    const timePeriodSort = screen.getByText("time period")
    fireEvent.click(timePeriodSort)
    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")
    expect(activeSortToggle.textContent).toEqual("time period↑")
    expect(firstRowData.item(0).textContent).toEqual(
      "NorthQuincyQuincyCenterKenmore-Newton Highlands"
    )
    expect(firstRowData.item(1).textContent).toContain("10/31/2019")
    expect(firstRowData.item(1).textContent).toContain("11/15/2019")

    fireEvent.click(timePeriodSort)
    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")
    expect(activeSortToggle.textContent).toEqual("time period↓")
    expect(firstRowData.item(0).textContent).toEqual("Kenmore-Newton Highlands")
    expect(firstRowData.item(1).textContent).toContain("9/22/2019")
    expect(firstRowData.item(1).textContent).toContain("10/22/2019")

    const disruptionIdSort = screen.getByText("ID")
    fireEvent.click(disruptionIdSort)
    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")
    expect(activeSortToggle.textContent).toEqual("ID↑")
    expect(firstRowData.item(0).textContent).toEqual(
      "NorthQuincyQuincyCenterKenmore-Newton Highlands"
    )
    expect(firstRowData.item(1).textContent).toContain("10/31/2019")
    expect(firstRowData.item(1).textContent).toContain("11/15/2019")

    fireEvent.click(disruptionIdSort)
    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")
    expect(activeSortToggle.textContent).toEqual("ID↓")
    expect(firstRowData.item(0).textContent).toEqual("Kenmore-Newton Highlands")
    expect(firstRowData.item(1).textContent).toContain("9/22/2019")
    expect(firstRowData.item(1).textContent).toContain("10/22/2019")

    const statusSort = screen.getByText("status")
    fireEvent.click(statusSort)
    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")
    expect(activeSortToggle.textContent).toEqual("status↑")
    expect(firstRowData.item(0).textContent).toEqual(
      "NorthQuincyQuincyCenterKenmore-Newton Highlands"
    )
    expect(firstRowData.item(1).textContent).toContain("10/31/2019")
    expect(firstRowData.item(1).textContent).toContain("11/15/2019")

    fireEvent.click(statusSort)
    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")
    expect(activeSortToggle.textContent).toEqual("status↓")
    expect(firstRowData.item(0).textContent).toEqual("Kenmore-Newton Highlands")
    expect(firstRowData.item(1).textContent).toContain("10/23/2019")
    expect(firstRowData.item(1).textContent).toContain("10/24/2019")

    const exceptionsSort = screen.getByText("except")
    fireEvent.click(exceptionsSort)
    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")
    expect(activeSortToggle.textContent).toEqual("except↑")
    expect(firstRowData.item(0).textContent).toEqual("Kenmore-Newton Highlands")
    expect(firstRowData.item(1).textContent).toContain("10/23/2019")
    expect(firstRowData.item(1).textContent).toContain("10/24/2019")

    fireEvent.click(exceptionsSort)
    activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    tableRows = container.querySelectorAll("tbody tr")
    firstRow = tableRows.item(0)
    firstRowData = firstRow.querySelectorAll("td")
    expect(activeSortToggle.textContent).toEqual("except↓")
    expect(firstRowData.item(0).textContent).toEqual(
      "NorthQuincyQuincyCenterKenmore-Newton Highlands"
    )
    expect(firstRowData.item(1).textContent).toContain("10/31/2019")
    expect(firstRowData.item(1).textContent).toContain("11/15/2019")
  })
})
