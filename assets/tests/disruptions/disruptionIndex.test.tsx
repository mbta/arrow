import * as React from "react"
import { BrowserRouter } from "react-router-dom"
import { mount } from "enzyme"
import * as renderer from "react-test-renderer"
import DisruptionIndexConnected, {
  DisruptionIndexView as DisruptionIndex,
  RouteFilterToggle,
} from "../../src/disruptions/disruptionIndex"
import DisruptionTable from "../../src/disruptions/disruptionTable"
import DisruptionCalendar from "../../src/disruptions/disruptionCalendar"
import Header from "../../src/header"
import Disruption from "../../src/models/disruption"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Exception from "../../src/models/exception"
import * as api from "../../src/api"
import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"

const DisruptionIndexWithRouter = ({
  connected = false,
}: {
  connected?: boolean
}) => {
  return (
    <BrowserRouter>
      {connected ? (
        <DisruptionIndexConnected />
      ) : (
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
      )}
    </BrowserRouter>
  )
}

describe("DisruptionIndexView", () => {
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

describe("DisruptionIndexConnected", () => {
  test.each([
    [
      [
        new Disruption({
          id: "1",
          startDate: new Date("2020-01-15"),
          endDate: new Date("2020-01-30"),
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
          tripShortNames: [],
        }),
      ],
      [
        [
          "NewtonHighlandsKenmore",
          "1/15/2020 - 1/30/2020",
          "Friday, 8:45PM - End of service",
        ],
      ],
    ],
    [
      [
        new Disruption({
          id: "1",
          startDate: new Date("2020-01-15"),
          endDate: new Date("2020-01-30"),
          adjustments: [
            new Adjustment({
              id: "1",
              routeId: "Green-D",
              source: "gtfs_creator",
              sourceLabel: "NewtonHighlandsKenmore",
            }),
            new Adjustment({
              id: "1",
              routeId: "Red",
              source: "gtfs_creator",
              sourceLabel: "HarvardAlewife",
            }),
          ],
          daysOfWeek: [
            new DayOfWeek({
              id: "1",
              startTime: "20:45:00",
              dayName: "saturday",
            }),
            new DayOfWeek({
              id: "2",
              endTime: "20:45:00",
              dayName: "sunday",
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
      [
        [
          "NewtonHighlandsKenmore, HarvardAlewife",
          "1/15/2020 - 1/30/2020",
          "Saturday 8:45PM - Sunday 8:45PM",
        ],
      ],
    ],
  ])(`Renders the table correctly`, async (disruptions, expected) => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve(disruptions)
    })
    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<DisruptionIndexWithRouter connected />, container)
    })
    const rows = container.querySelectorAll("tbody tr")
    expect(rows.length).toEqual(disruptions.length)
    rows.forEach((row, index) => {
      const dataColumns = row.querySelectorAll("td")
      expect(dataColumns[0].textContent).toEqual(expected[index][0])
      expect(dataColumns[1].textContent).toEqual(expected[index][1])
      expect(dataColumns[2].textContent).toEqual(expected[index][2])
    })
  })

  test("renders error", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve("error")
    })
    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<DisruptionIndexWithRouter connected />, container)
    })

    expect(container.textContent).toMatch("Something went wrong")
  })
})
