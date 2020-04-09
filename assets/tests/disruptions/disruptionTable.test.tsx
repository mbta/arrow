import * as React from "react"
import { BrowserRouter } from "react-router-dom"
import { mount } from "enzyme"
import {
  DisruptionTable,
  DisruptionTableHeader,
} from "../../src/disruptions/disruptionTable"

const DisruptionTableWithRouter = () => {
  return (
    <BrowserRouter>
      <DisruptionTable
        disruptions={[
          {
            id: "1",
            routes: ["Red"],
            label: "AlewifeHarvard",
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
    const wrapper = mount(<DisruptionTableWithRouter />)
    let tableRows = wrapper.find("tbody tr")
    expect(tableRows.length).toEqual(3)
    let firstRow = tableRows.at(0)
    let firstRowData = firstRow.find("td")
    expect(firstRowData.at(0).text()).toEqual("AlewifeHarvard")
    expect(firstRowData.at(1).text()).toEqual("10/31/2019 - 11/15/2019")
    expect(firstRowData.at(2).text()).toEqual("Weekends, starting Friday 845")
    expect(firstRowData.at(3).find("a[href='/disruptions/1']").length).toEqual(
      1
    )
    let activeSortToggle = wrapper
      .find(DisruptionTableHeader)
      .find({ active: true })
    expect(activeSortToggle.text()).toEqual("stops")
    expect(activeSortToggle.props().sortOrder).toEqual("asc")

    activeSortToggle.find(".m-disruption-table__sortable").simulate("click")
    tableRows = wrapper.find("tbody tr")
    firstRow = tableRows.at(0)
    firstRowData = firstRow.find("td")

    activeSortToggle = wrapper
      .find(DisruptionTableHeader)
      .find({ active: true })
    expect(activeSortToggle.text()).toEqual("stops")
    expect(activeSortToggle.props().sortOrder).toEqual("desc")
    expect(firstRowData.at(0).text()).toEqual("Kenmore—Newton Highlands")

    wrapper
      .find(".m-disruption-table__sortable[children='dates']")
      .simulate("click")
    activeSortToggle = wrapper
      .find(DisruptionTableHeader)
      .find({ active: true })
    tableRows = wrapper.find("tbody tr")
    firstRow = tableRows.at(0)
    firstRowData = firstRow.find("td")
    expect(activeSortToggle.text()).toEqual("dates")
    expect(activeSortToggle.props().sortOrder).toEqual("asc")
    expect(firstRowData.at(0).text()).toEqual("Kenmore—Newton Highlands")
    expect(firstRowData.at(1).text()).toEqual("9/22/2019 - 10/22/2019")
  })
})
