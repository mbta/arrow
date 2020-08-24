import * as React from "react"
import { BrowserRouter, MemoryRouter, Switch, Route } from "react-router-dom"
import {
  render,
  fireEvent,
  screen,
  queryByAttribute,
} from "@testing-library/react"

import {
  DisruptionIndexView,
  DisruptionIndex,
  getRouteColor,
} from "../../src/disruptions/disruptionIndex"
import Disruption from "../../src/models/disruption"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Exception from "../../src/models/exception"
import * as api from "../../src/api"

import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { toModelObject } from "../../src/jsonApi"

const DisruptionIndexWithRouter = ({
  connected = false,
}: {
  connected?: boolean
}) => {
  return (
    <BrowserRouter>
      {connected ? (
        <DisruptionIndex />
      ) : (
        <DisruptionIndexView
          disruptions={[
            new Disruption({
              id: "1",
              startDate: new Date("2019-10-31"),
              endDate: new Date("2019-11-15"),
              adjustments: [
                new Adjustment({
                  id: "1",
                  routeId: "Red",
                  sourceLabel: "AlewifeHarvard",
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
            }),
          ]}
        />
      )}
    </BrowserRouter>
  )
}

describe("DisruptionIndexView", () => {
  test("header does not include link to homepage", () => {
    const { container } = render(<DisruptionIndexWithRouter />)

    expect(container.querySelector("#header-home-link")).toBeNull()
  })

  test("disruptions can be filtered by label", () => {
    const { container } = render(<DisruptionIndexWithRouter />)

    expect(container.querySelectorAll("tbody tr").length).toEqual(2)

    const searchInput = container.querySelector('input[type="text"]')

    if (!searchInput) {
      throw new Error("search input not found")
    }

    fireEvent.change(searchInput, { target: { value: "Alewife" } })

    expect(container.querySelectorAll("tbody tr").length).toEqual(1)
    expect(container.querySelectorAll("tbody tr").item(0).innerHTML).toMatch(
      "AlewifeHarvard"
    )

    fireEvent.change(searchInput, { target: { value: "Some other label" } })

    expect(container.querySelectorAll("tbody tr").length).toEqual(0)
  })

  test("disruptions can be filtered by route", () => {
    const { container } = render(<DisruptionIndexWithRouter />)
    let tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(2)
    expect(tableRows.item(0).innerHTML).toContain("AlewifeHarvard")
    expect(tableRows.item(1).innerHTML).toContain("Kenmore-Newton")
    expect(container.querySelectorAll("#clear-filter").length).toEqual(0)
    expect(
      container.querySelectorAll(".m-disruption-index__route_filter.active")
        .length
    ).toEqual(9)

    const greenDselector = container.querySelector(
      "#route-filter-toggle-Green-D"
    )

    if (!greenDselector) {
      throw new Error("Green-D selector not found")
    }

    fireEvent.click(greenDselector)

    tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(1)
    expect(tableRows.item(0).innerHTML).toContain("Kenmore-Newton")
    expect(
      container.querySelectorAll(".m-disruption-index__route_filter.active")
        .length
    ).toEqual(1)

    let clearFilterLink = container.querySelector("#clear-filter")

    if (!clearFilterLink) {
      throw new Error("clear filter link not found")
    }

    fireEvent.click(clearFilterLink)

    tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(2)

    const greenEselector = container.querySelector(
      "#route-filter-toggle-Green-E"
    )

    if (!greenEselector) {
      throw new Error("Green-E selector not found")
    }

    fireEvent.click(greenEselector)
    tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(0)
    expect(
      container.querySelectorAll(".m-disruption-index__route_filter.active")
        .length
    ).toEqual(1)

    clearFilterLink = container.querySelector("#clear-filter")

    if (!clearFilterLink) {
      throw new Error("clear filter link not found")
    }

    fireEvent.click(clearFilterLink)

    tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(2)

    expect(tableRows.item(0).innerHTML).toContain("AlewifeHarvard")
    expect(tableRows.item(1).innerHTML).toContain("Kenmore-Newton")

    clearFilterLink = container.querySelector("#clear-filter")
    expect(clearFilterLink).toBeNull()

    expect(
      container.querySelectorAll(".m-disruption-index__route_filter.active")
        .length
    ).toEqual(9)
  })

  test("can toggle between table and calendar view", () => {
    const { container } = render(<DisruptionIndexWithRouter />)
    expect(screen.queryByText("days + times")).not.toBeNull()
    expect(queryByAttribute("id", container, "calendar")).toBeNull()

    const toggleButton = container.querySelector("#view-toggle")
    if (!toggleButton) {
      throw new Error("toggle button not found")
    }
    expect(toggleButton.textContent).toEqual("calendar view")

    fireEvent.click(toggleButton)
    expect(screen.queryByText("days + times")).toBeNull()
    expect(queryByAttribute("id", container, "calendar")).not.toBeNull()
    expect(toggleButton.textContent).toEqual("list view")

    fireEvent.click(toggleButton)
    expect(screen.queryByText("days + times")).not.toBeNull()
    expect(queryByAttribute("id", container, "calendar")).toBeNull()
    expect(toggleButton.textContent).toEqual("calendar view")
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
              id: "2",
              routeId: "Red",
              source: "gtfs_creator",
              sourceLabel: "HarvardAlewife",
            }),
            new Adjustment({
              id: "3",
              routeId: "CR-Fairmount",
              source: "arrow",
              sourceLabel: "Fairmount--Newmarket",
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
          "NewtonHighlandsKenmore, HarvardAlewife, Fairmount--Newmarket",
          "1/15/2020 - 1/30/2020",
          "Saturday 8:45PM - Sunday 8:45PM",
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
          ],
          daysOfWeek: [],
          exceptions: [
            new Exception({
              id: "1",
              excludedDate: new Date("2020-01-20"),
            }),
          ],
          tripShortNames: [],
        }),
      ],
      [["NewtonHighlandsKenmore", "1/15/2020 - 1/30/2020", ""]],
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

  test("can toggle between published and draft view", async () => {
    const spy = jest.spyOn(api, "apiGet").mockImplementation(() => {
      return Promise.resolve([])
    })
    const { container } = render(
      <MemoryRouter initialEntries={["/"]}>
        <Switch>
          <Route exact={true} path="/" component={DisruptionIndex} />
        </Switch>
      </MemoryRouter>
    )

    expect(spy).toHaveBeenCalledWith({
      url: "/api/disruptions?published_only=true",
      parser: toModelObject,
      defaultResult: "error",
    })

    const publishedButton = container.querySelector("#published")
    expect(publishedButton?.classList).toContain("active")
    const draftButton = container.querySelector("#draft")
    expect(draftButton?.classList).not.toContain("active")
    expect(container.querySelector("#new-disruption-link")).toBeNull()

    if (draftButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(draftButton)
      })
    } else {
      throw new Error("draft button not found")
    }

    expect(spy).toHaveBeenCalledWith({
      url: "/api/disruptions?published_only=false",
      parser: toModelObject,
      defaultResult: "error",
    })
    expect(publishedButton?.classList).not.toContain("active")
    expect(draftButton?.classList).toContain("active")
    expect(container.querySelector("#new-disruption-link")).not.toBeNull()
  })
})

describe("getRouteColor", () => {
  test("returns the correct color", () => {
    ;[
      ["Red", "#da291c"],
      ["Blue", "#003da5"],
      ["Mattapan", "#da291c"],
      ["Orange", "#ed8b00"],
      ["Green-B", "#00843d"],
      ["Green-C", "#00843d"],
      ["Green-D", "#00843d"],
      ["Green-E", "#00843d"],
      ["CR-Fairmont", "#80276c"],
    ].forEach(([route, color]) => {
      expect(getRouteColor(route)).toEqual(color)
    })
  })
})
