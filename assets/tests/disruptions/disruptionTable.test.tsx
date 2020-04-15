import * as React from "react"
import { BrowserRouter } from "react-router-dom"
import { render, fireEvent, screen } from "@testing-library/react"
import { DisruptionTable } from "../../src/disruptions/disruptionTable"

const DisruptionTableWithRouter = () => {
  return (
    <BrowserRouter>
      <DisruptionTable
        disruptions={[
          {
            id: "1",
            routes: ["Red"],
            startDate: new Date("2019-10-31"),
            endDate: new Date("2019-11-15"),
            daysAndTimes: "Weekends, starting Friday 845",
          },
          {
            id: "2",
            routes: ["Green-D"],
            label: "Kenmore—Newton Highlands",
            startDate: new Date("2019-10-23"),
            endDate: new Date("2019-10-24"),
            daysAndTimes: "Weekends, starting Friday 845",
          },
          {
            id: "3",
            routes: ["Green-D"],
            label: "Kenmore—Newton Highlands",
            startDate: new Date("2019-09-22"),
            endDate: new Date("2019-10-22"),
            daysAndTimes: "Weekends, starting Friday 845",
          },
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
    expect(firstRowData.item(0).textContent).toEqual("Kenmore—Newton Highlands")
    expect(firstRowData.item(1).textContent).toEqual("10/23/2019 - 10/24/2019")
    expect(firstRowData.item(2).textContent).toEqual(
      "Weekends, starting Friday 845"
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
    expect(firstRowData.item(0).textContent).toEqual("Kenmore—Newton Highlands")
    expect(firstRowData.item(1).textContent).toEqual("9/22/2019 - 10/22/2019")
  })
})
