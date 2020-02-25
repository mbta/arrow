import * as React from "react"
import { BrowserRouter } from "react-router-dom"
import { mount } from "enzyme"
import * as renderer from "react-test-renderer"
import DisruptionIndex, {
  RouteFilterToggle,
} from "../../src/disruptions/disruptionIndex"
import DisruptionTable from "../../src/disruptions/disruptionTable"
import DisruptionCalendar from "../../src/disruptions/disruptionCalendar"
import Header from "../../src/header"

const DisruptionIndexWithRouter = () => {
  return (
    <BrowserRouter>
      <DisruptionIndex
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
            routes: ["Green-D", "Green-E"],
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

describe("DisruptionIndex", () => {
  test("header does not include link to homepage", () => {
    const testInstance = renderer.create(<DisruptionIndexWithRouter />).root

    expect(testInstance.findByType(Header).props.includeHomeLink).toBe(false)
  })

  test("disruptions can be filtered by label", () => {
    const wrapper = mount(<DisruptionIndexWithRouter />)
    expect(wrapper.find("tbody tr").length).toEqual(2)

    wrapper
      .find('input[type="text"]')
      .simulate("change", { target: { value: "Alewife" } })

    expect(wrapper.find("tbody tr").length).toEqual(1)
    expect(
      wrapper
        .find("tbody tr")
        .at(0)
        .text()
        .includes("AlewifeHarvard")
    ).toBe(true)

    wrapper
      .find('input[type="text"]')
      .simulate("change", { target: { value: "Some other label" } })
    expect(wrapper.find("tbody tr").length).toEqual(0)
  })

  test("disruptions can be filtered by route", () => {
    const wrapper = mount(<DisruptionIndexWithRouter />)
    let tableRows = wrapper.find("tbody tr")
    expect(tableRows.length).toEqual(2)
    expect(tableRows.at(0).text()).toContain("AlewifeHarvard")
    expect(tableRows.at(1).text()).toContain("Kenmore—Newton")
    expect(wrapper.find("#clear-filter").length).toEqual(0)
    expect(
      wrapper.find(RouteFilterToggle).find({ active: true }).length
    ).toEqual(9)

    wrapper
      .find(RouteFilterToggle)
      .find({ route: "Green-D" })
      .simulate("click")
    tableRows = wrapper.find("tbody tr")
    expect(tableRows.length).toEqual(1)
    expect(tableRows.at(0).text()).toContain("Kenmore—Newton")
    expect(
      wrapper.find(RouteFilterToggle).find({ active: true }).length
    ).toEqual(1)
    expect(wrapper.find("#clear-filter").length).toEqual(1)
    wrapper.find("#clear-filter").simulate("click")
    tableRows = wrapper.find("tbody tr")
    expect(tableRows.length).toEqual(2)

    wrapper
      .find(RouteFilterToggle)
      .find({ route: "Green-E" })
      .simulate("click")
    tableRows = wrapper.find("tbody tr")
    expect(tableRows.length).toEqual(1)
    expect(tableRows.at(0).text()).toContain("Kenmore—Newton")
    expect(
      wrapper.find(RouteFilterToggle).find({ active: true }).length
    ).toEqual(1)
    expect(wrapper.find("#clear-filter").length).toEqual(1)
    wrapper.find("#clear-filter").simulate("click")
    tableRows = wrapper.find("tbody tr")
    expect(tableRows.length).toEqual(2)

    expect(tableRows.at(0).text()).toContain("AlewifeHarvard")
    expect(tableRows.at(1).text()).toContain("Kenmore—Newton")
    expect(wrapper.find("#clear-filter").length).toEqual(0)
    expect(
      wrapper.find(RouteFilterToggle).find({ active: true }).length
    ).toEqual(9)
  })

  test("can toggle between table and calendar view", () => {
    const wrapper = mount(<DisruptionIndexWithRouter />)
    expect(wrapper.exists(DisruptionTable)).toBe(true)
    expect(wrapper.exists(DisruptionCalendar)).toBe(false)
    const toggleButton = wrapper.find("#view-toggle").at(0)
    expect(toggleButton.text()).toEqual("calendar view")

    toggleButton.simulate("click")
    expect(wrapper.exists(DisruptionTable)).toBe(false)
    expect(wrapper.exists(DisruptionCalendar)).toBe(true)
    expect(toggleButton.text()).toEqual("list view")

    toggleButton.simulate("click")
    expect(wrapper.exists(DisruptionTable)).toBe(true)
    expect(wrapper.exists(DisruptionCalendar)).toBe(false)
    expect(toggleButton.text()).toEqual("calendar view")
  })
})
