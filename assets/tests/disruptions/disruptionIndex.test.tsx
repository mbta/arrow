import * as React from "react"
import {
  render,
  fireEvent,
  getByText,
  getAllByText,
  queryByAttribute,
  queryByText,
} from "@testing-library/react"

import {
  DisruptionIndexView,
  DisruptionIndex,
  getRouteColor,
  revisionMatchesFilters,
  FilterGroup,
  Routes,
} from "../../src/disruptions/disruptionIndex"
import Disruption from "../../src/models/disruption"
import DisruptionRevision from "../../src/models/disruptionRevision"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Exception from "../../src/models/exception"
import * as api from "../../src/api"

import ReactDOM from "react-dom"
import { act } from "react-dom/test-utils"
import { DisruptionView } from "../../src/models/disruption"

const fakeNow = new Date("2019-10-01")

const DisruptionIndexWithRouter = ({
  connected = false,
  fetchDisruption = jest.fn(),
  disruptions,
}: {
  connected?: boolean
  fetchDisruption?: () => void
  disruptions?: Disruption[]
}) => {
  return (
    <>
      {connected ? (
        <DisruptionIndex now={fakeNow} />
      ) : (
        <DisruptionIndexView
          now={fakeNow}
          fetchDisruptions={fetchDisruption}
          disruptions={
            disruptions || [
              new Disruption({
                publishedRevision: new DisruptionRevision({
                  id: "1",
                  disruptionId: "1",
                  startDate: new Date("2019-10-31"),
                  endDate: new Date("2019-11-15"),
                  isActive: true,
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
                  status: DisruptionView.Published,
                }),
                revisions: [
                  new DisruptionRevision({
                    id: "1",
                    disruptionId: "1",
                    startDate: new Date("2019-10-31"),
                    endDate: new Date("2019-11-15"),
                    isActive: true,
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
                    status: DisruptionView.Published,
                  }),
                ],
              }),

              new Disruption({
                id: "3",
                readyRevision: new DisruptionRevision({
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
                }),
                revisions: [
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
                  }),
                ],
              }),

              new Disruption({
                publishedRevision: new DisruptionRevision({
                  id: "4",
                  disruptionId: "4",
                  startDate: new Date("2019-09-01"),
                  endDate: new Date("2019-09-15"),
                  isActive: true,
                  adjustments: [
                    new Adjustment({
                      id: "3",
                      routeId: "Orange",
                      sourceLabel: "ForestHillsRuggles",
                    }),
                  ],
                  daysOfWeek: [
                    new DayOfWeek({ id: "1", dayName: "saturday" }),
                    new DayOfWeek({ id: "2", dayName: "sunday" }),
                  ],
                  exceptions: [],
                  tripShortNames: [],
                  status: DisruptionView.Published,
                }),
                revisions: [
                  new DisruptionRevision({
                    id: "4",
                    disruptionId: "4",
                    startDate: new Date("2019-09-01"),
                    endDate: new Date("2019-09-15"),
                    isActive: true,
                    adjustments: [
                      new Adjustment({
                        id: "3",
                        routeId: "Orange",
                        sourceLabel: "ForestHillsRuggles",
                      }),
                    ],
                    daysOfWeek: [
                      new DayOfWeek({ id: "1", dayName: "saturday" }),
                      new DayOfWeek({ id: "2", dayName: "sunday" }),
                    ],
                    exceptions: [],
                    tripShortNames: [],
                    status: DisruptionView.Published,
                  }),
                ],
              }),
            ]
          }
        />
      )}
    </>
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

  test("disruptions can be filtered by status", () => {
    const { container } = render(<DisruptionIndexWithRouter />)

    expect(container.querySelectorAll("tbody tr").length).toEqual(2)

    const draftStatusToggle = container.querySelector(
      "#status-filter-toggle-needs-review"
    )

    if (!draftStatusToggle) {
      throw new Error("search input not found")
    }

    fireEvent.click(draftStatusToggle)

    expect(container.querySelectorAll("tbody tr").length).toEqual(1)
    expect(container.querySelectorAll("tbody tr").item(0).innerHTML).toMatch(
      "Kenmore-Newton Highlands"
    )
  })

  test("can be filtered to include past disruptions", () => {
    const { container } = render(<DisruptionIndexWithRouter />)
    expect(container.querySelectorAll("tbody tr").length).toEqual(2)
    expect(container.querySelector("tbody")?.innerHTML).not.toMatch(
      "ForestHillsRuggles"
    )

    const pastFilterToggle = container.querySelector(
      "#date-filter-toggle-include-past"
    )
    if (!pastFilterToggle) throw new Error("past filter toggle not found")
    fireEvent.click(pastFilterToggle)

    expect(container.querySelectorAll("tbody tr").length).toEqual(3)
    expect(container.querySelector("tbody")?.innerHTML).toMatch(
      "ForestHillsRuggles"
    )
  })

  test("can toggle between table and calendar view", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve([
        new Disruption({
          id: "1",
          draftRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2019-10-31"),
            endDate: new Date("2019-11-15"),
            isActive: true,
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
            status: DisruptionView.Draft,
          }),
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2019-10-31"),
              endDate: new Date("2019-11-15"),
              isActive: true,
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
              status: DisruptionView.Draft,
            }),
          ],
        }),
      ])
    })

    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<DisruptionIndexWithRouter connected />, container)
    })
    expect(queryByText(container, "time period")).not.toBeNull()
    expect(queryByAttribute("id", container, "calendar")).toBeNull()
    expect(
      container.querySelector("#actions")?.hasAttribute("disabled")
    ).toEqual(false)

    const toggleButton = container.querySelector("#view-toggle")
    if (!toggleButton) {
      throw new Error("toggle button not found")
    }
    expect(toggleButton.textContent).toEqual("⬒ calendar view")

    fireEvent.click(toggleButton)
    expect(queryByText(container, "time period")).toBeNull()
    expect(queryByAttribute("id", container, "calendar")).not.toBeNull()
    expect(toggleButton.textContent).toEqual("⬒ list view")
    expect(
      container.querySelector("#actions")?.hasAttribute("disabled")
    ).toEqual(true)

    fireEvent.click(toggleButton)
    expect(queryByText(container, "time period")).not.toBeNull()
    expect(queryByAttribute("id", container, "calendar")).toBeNull()
    expect(toggleButton.textContent).toEqual("⬒ calendar view")
    expect(
      container.querySelector("#actions")?.hasAttribute("disabled")
    ).toEqual(false)
  })
})

describe("DisruptionIndexConnected", () => {
  test.each([
    [
      [
        new Disruption({
          id: "1",
          readyRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
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
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
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
        }),
      ],
      [
        [
          "NewtonHighlandsKenmore",
          "01/15/202001/30/2020",
          "Friday, 8:45PM - End of service",
        ],
      ],
    ],
    [
      [
        new Disruption({
          id: "1",
          readyRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
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
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
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
        }),
      ],
      [
        [
          "NewtonHighlandsKenmoreHarvardAlewifeFairmount--Newmarket",
          "01/15/202001/30/2020",
          "Saturday 8:45PM - Sunday 8:45PM",
        ],
      ],
    ],
    [
      [
        new Disruption({
          id: "1",
          readyRevision: new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
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
          revisions: [
            new DisruptionRevision({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
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
        }),
      ],
      [["NewtonHighlandsKenmore", "01/15/202001/30/2020", ""]],
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
    expect(rows.length).toEqual(
      disruptions.reduce((acc, curr) => {
        return acc + curr.revisions.length
      }, 0)
    )
    rows.forEach((row, index) => {
      const dataColumns = row.querySelectorAll("td")
      expect(dataColumns[0].textContent).toEqual(expected[index][0])
      expect(dataColumns[1].textContent).toEqual(expected[index][1])
    })
  })

  test("can mark multiple revisions as ready", async () => {
    const disruptions = [
      new Disruption({
        id: "1",
        publishedRevision: new DisruptionRevision({
          id: "1",
          disruptionId: "1",
          startDate: new Date("2020-01-15"),
          endDate: new Date("2020-01-30"),
          isActive: false,
          adjustments: [
            new Adjustment({
              id: "1",
              routeId: "Green-D",
              source: "gtfs_creator",
              sourceLabel: "NewtonHighlandsKenmore",
            }),
          ],
          daysOfWeek: [],
          exceptions: [],
          tripShortNames: [],
          status: DisruptionView.Published,
        }),
        revisions: [
          new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: false,
            adjustments: [
              new Adjustment({
                id: "1",
                routeId: "Green-D",
                source: "gtfs_creator",
                sourceLabel: "NewtonHighlandsKenmore",
              }),
            ],
            daysOfWeek: [],
            exceptions: [],
            tripShortNames: [],
          }),
        ],
      }),
      new Disruption({
        id: "2",
        readyRevision: new DisruptionRevision({
          id: "2",
          disruptionId: "2",
          startDate: new Date("2020-01-20"),
          endDate: new Date("2020-01-25"),
          isActive: false,
          adjustments: [
            new Adjustment({
              id: "1",
              routeId: "Red",
              source: "gtfs_creator",
              sourceLabel: "AlewifeHarvard",
            }),
          ],
          daysOfWeek: [],
          exceptions: [],
          tripShortNames: [],
          status: DisruptionView.Published,
        }),
        draftRevision: new DisruptionRevision({
          id: "3",
          disruptionId: "2",
          startDate: new Date("2020-01-20"),
          endDate: new Date("2020-01-28"),
          isActive: true,
          adjustments: [
            new Adjustment({
              id: "1",
              routeId: "Red",
              source: "gtfs_creator",
              sourceLabel: "AlewifeHarvard",
            }),
          ],
          daysOfWeek: [],
          exceptions: [],
          tripShortNames: [],
        }),
        revisions: [],
      }),
      new Disruption({
        id: "3",
        readyRevision: new DisruptionRevision({
          id: "4",
          disruptionId: "3",
          startDate: new Date("2020-02-20"),
          endDate: new Date("2020-02-25"),
          isActive: false,
          adjustments: [
            new Adjustment({
              id: "1",
              routeId: "Orange",
              source: "gtfs_creator",
              sourceLabel: "Wellington",
            }),
          ],
          daysOfWeek: [],
          exceptions: [],
          tripShortNames: [],
          status: DisruptionView.Ready,
        }),
        draftRevision: new DisruptionRevision({
          id: "5",
          disruptionId: "3",
          startDate: new Date("2020-02-21"),
          endDate: new Date("2020-02-25"),
          isActive: true,
          adjustments: [
            new Adjustment({
              id: "1",
              routeId: "Orange",
              source: "gtfs_creator",
              sourceLabel: "Wellington",
            }),
          ],
          daysOfWeek: [],
          exceptions: [],
          tripShortNames: [],
        }),
        revisions: [],
      }),
    ]
    const getSpy = jest.fn()
    const sendSpy = jest.spyOn(api, "apiSend").mockImplementation(() => {
      return Promise.resolve({
        ok: {},
      })
    })
    const { container, findByText } = render(
      <DisruptionIndexWithRouter
        disruptions={disruptions}
        fetchDisruption={getSpy}
      />
    )
    const actionsButton = container.querySelector("#actions")
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    fireEvent.click(actionsButton!)
    let checkboxes: NodeListOf<HTMLInputElement> = container.querySelectorAll(
      "tr input[type=checkbox]"
    )
    expect(checkboxes.length).toEqual(2)
    checkboxes.forEach((x: HTMLInputElement) => {
      expect(x.checked).toEqual(false)
    })
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    fireEvent.click(container.querySelector('tr[data-revision-id="5"] input')!)
    expect(
      (
        container.querySelector(
          'tr[data-revision-id="5"] input[type=checkbox]'
        ) as HTMLInputElement
      ).checked
    ).toEqual(true)

    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    fireEvent.click(container.querySelector("#toggle-all")!)
    checkboxes.forEach((x: HTMLInputElement) => {
      expect(x.checked).toEqual(false)
    })
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    fireEvent.click(container.querySelector("#toggle-all")!)
    expect(container.querySelectorAll("tr input:checked").length).toEqual(2)
    checkboxes.forEach((x: HTMLInputElement) => {
      expect(x.checked).toEqual(true)
    })
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    fireEvent.click(container.querySelector("#actions")!)
    expect(container.querySelectorAll("tr input").length).toEqual(0)
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    fireEvent.click(container.querySelector("#actions")!)
    checkboxes = container.querySelectorAll("tr input")
    expect(checkboxes.length).toEqual(2)
    checkboxes.forEach((x: HTMLInputElement) => {
      expect(x.checked).toEqual(false)
    })
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    fireEvent.click(container.querySelector("#toggle-all")!)
    expect(container.querySelectorAll("tr input:checked").length).toEqual(2)
    checkboxes.forEach((x: HTMLInputElement) => {
      expect(x.checked).toEqual(true)
    })
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    fireEvent.click(container.querySelector("#route-filter-toggle-Orange")!)
    expect(container.querySelectorAll("tr input:checked").length).toEqual(1)
    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      fireEvent.click(container.querySelector("#mark-ready")!)
    })
    let confirmButton = await findByText("yes, mark as ready")
    if (confirmButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(confirmButton)
      })
    } else {
      throw new Error("confirm button not found")
    }
    expect(sendSpy).toHaveBeenCalledWith(
      expect.objectContaining({
        url: "/api/ready_notice/",
        json: JSON.stringify({ revision_ids: "5" }),
        method: "POST",
      })
    )

    expect(getSpy).toHaveBeenCalledTimes(1)
    sendSpy.mockClear()
    const sendSpyFail = jest.spyOn(api, "apiSend").mockImplementation(() => {
      return Promise.reject()
    })
    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      fireEvent.click(container.querySelector("#mark-ready")!)
    })
    confirmButton = await findByText("yes, mark as ready")
    if (confirmButton) {
      // eslint-disable-next-line @typescript-eslint/require-await
      await act(async () => {
        fireEvent.click(confirmButton)
      })
    } else {
      throw new Error("confirm button not found")
    }
    expect(sendSpyFail).toBeCalledTimes(1)
    expect(getSpy).toHaveBeenCalledTimes(1)
  })

  test("doesn't render deleted published disruption", async () => {
    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve([
        new Disruption({
          id: "1",
          publishedRevision: new DisruptionRevision({
            id: "2",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: false,
            adjustments: [
              new Adjustment({
                id: "1",
                routeId: "Green-D",
                source: "gtfs_creator",
                sourceLabel: "NewtonHighlandsKenmore",
              }),
            ],
            daysOfWeek: [],
            exceptions: [],
            tripShortNames: [],
            status: DisruptionView.Published,
          }),
          revisions: [
            new DisruptionRevision({
              id: "2",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: false,
              adjustments: [
                new Adjustment({
                  id: "1",
                  routeId: "Green-D",
                  source: "gtfs_creator",
                  sourceLabel: "NewtonHighlandsKenmore",
                }),
              ],
              daysOfWeek: [],
              exceptions: [],
              tripShortNames: [],
            }),
          ],
        }),
      ])
    })
    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<DisruptionIndexWithRouter connected />, container)
    })
    const rows = container.querySelectorAll("tbody tr")
    expect(rows.length).toEqual(0)
  })

  test("displays only published revisions on the calendar view", async () => {
    const today = new Date()
    today.setUTCHours(0, 0, 0, 0)
    const nextWeek = new Date(
      Date.UTC(
        today.getUTCFullYear(),
        today.getUTCMonth(),
        today.getUTCDate() + 7
      )
    )

    const published = new DisruptionRevision({
      id: "1",
      disruptionId: "1",
      startDate: today,
      endDate: nextWeek,
      isActive: true,
      adjustments: [
        new Adjustment({
          id: "1",
          routeId: "Red",
          sourceLabel: "AlewifeHarvard",
        }),
      ],
      daysOfWeek: [new DayOfWeek({ dayName: "monday" })],
      exceptions: [],
      tripShortNames: [],
      status: DisruptionView.Published,
    })
    const ready = new DisruptionRevision({
      ...published,
      id: "2",
      status: DisruptionView.Ready,
      daysOfWeek: [new DayOfWeek({ dayName: "tuesday" })],
    })
    const draft = new DisruptionRevision({
      ...ready,
      id: "3",
      status: DisruptionView.Draft,
      isActive: false,
    })

    jest.spyOn(api, "apiGet").mockImplementationOnce(() => {
      return Promise.resolve([
        new Disruption({
          id: "1",
          publishedRevision: published,
          readyRevision: ready,
          draftRevision: draft,
          revisions: [published, ready, draft],
        }),
      ])
    })

    const container = document.createElement("div")
    document.body.appendChild(container)

    // eslint-disable-next-line @typescript-eslint/require-await
    await act(async () => {
      ReactDOM.render(<DisruptionIndexWithRouter connected />, container)
    })
    fireEvent.click(getByText(container, /calendar view/i))

    expect(getAllByText(container, /AlewifeHarvard/).length).toBe(1)
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

describe("revisionMatchesFilters", () => {
  const today = new Date(2020, 6, 15)
  const oneWeekAgo = new Date(2020, 6, 8)
  const twoWeeksAgo = new Date(2020, 6, 1)
  const oneWeekHence = new Date(2020, 6, 22)

  const published = new DisruptionRevision({
    id: "1",
    isActive: true,
    adjustments: [
      new Adjustment({ id: "1", routeId: "Red", sourceLabel: "Adj 1" }),
    ],
    startDate: today,
    endDate: oneWeekHence,
    daysOfWeek: [],
    exceptions: [],
    tripShortNames: [],
    status: DisruptionView.Published,
  })

  const ready = new DisruptionRevision({
    id: "2",
    isActive: true,
    adjustments: [
      new Adjustment({ id: "2", routeId: "Blue", sourceLabel: "Adj 2" }),
    ],
    startDate: today,
    endDate: oneWeekHence,
    daysOfWeek: [],
    exceptions: [],
    tripShortNames: [],
    status: DisruptionView.Ready,
  })

  const draft = new DisruptionRevision({
    id: "3",
    isActive: true,
    adjustments: [
      new Adjustment({ id: "3", routeId: "Orange", sourceLabel: "Adj 3" }),
    ],
    startDate: today,
    endDate: oneWeekHence,
    daysOfWeek: [],
    exceptions: [],
    tripShortNames: [],
    status: DisruptionView.Draft,
  })

  const past = new DisruptionRevision({
    id: "4",
    isActive: true,
    adjustments: [
      new Adjustment({ id: "1", routeId: "Red", sourceLabel: "Adj 1" }),
    ],
    startDate: twoWeeksAgo,
    endDate: oneWeekAgo,
    daysOfWeek: [],
    exceptions: [],
    tripShortNames: [],
    status: DisruptionView.Published,
  })

  const publishedDeleted = new DisruptionRevision({
    ...published,
    isActive: false,
  })
  const readyDeleted = new DisruptionRevision({ ...ready, isActive: false })
  const draftDeleted = new DisruptionRevision({ ...draft, isActive: false })

  const noRouteFilters = { state: {}, anyActive: false }
  const noStatusFilters = { state: {}, anyActive: false }
  const noDateFilters = { state: {}, anyActive: false }

  const onlyPublished = { state: { published: true }, anyActive: true }
  const onlyReady = { state: { ready: true }, anyActive: true }
  const onlyDraft = { state: { needs_review: true }, anyActive: true }
  const onlyRed = { state: { Red: true }, anyActive: true }
  const includePast = { state: { include_past: true }, anyActive: true }

  test.each([
    // no filters
    [
      published,
      "",
      noRouteFilters,
      noStatusFilters,
      noDateFilters,
      oneWeekAgo,
      true,
    ],
    [
      ready,
      "",
      noRouteFilters,
      noStatusFilters,
      noDateFilters,
      oneWeekAgo,
      true,
    ],
    [
      draft,
      "",
      noRouteFilters,
      noStatusFilters,
      noDateFilters,
      oneWeekAgo,
      true,
    ],
    // published status filter
    [
      published,
      "",
      noRouteFilters,
      onlyPublished,
      noDateFilters,
      oneWeekAgo,
      true,
    ],
    [
      ready,
      "",
      noRouteFilters,
      onlyPublished,
      noDateFilters,
      oneWeekAgo,
      false,
    ],
    [
      draft,
      "",
      noRouteFilters,
      onlyPublished,
      noDateFilters,
      oneWeekAgo,
      false,
    ],
    // ready status filter
    [
      published,
      "",
      noRouteFilters,
      onlyReady,
      noDateFilters,
      oneWeekAgo,
      false,
    ],
    [ready, "", noRouteFilters, onlyReady, noDateFilters, oneWeekAgo, true],
    [
      published,
      "",
      noRouteFilters,
      onlyReady,
      noDateFilters,
      oneWeekAgo,
      false,
    ],
    // needs review status filter
    [
      published,
      "",
      noRouteFilters,
      onlyDraft,
      noDateFilters,
      oneWeekAgo,
      false,
    ],
    [ready, "", noRouteFilters, onlyDraft, noDateFilters, oneWeekAgo, false],
    [draft, "", noRouteFilters, onlyDraft, noDateFilters, oneWeekAgo, true],
    // route filter
    [published, "", onlyRed, noStatusFilters, noDateFilters, oneWeekAgo, true],
    [ready, "", onlyRed, noStatusFilters, noDateFilters, oneWeekAgo, false],
    [draft, "", onlyRed, noStatusFilters, noDateFilters, oneWeekAgo, false],
    // include past filter
    [
      past,
      "",
      noRouteFilters,
      noStatusFilters,
      noDateFilters,
      oneWeekAgo,
      false,
    ],
    [past, "", noRouteFilters, noStatusFilters, includePast, oneWeekAgo, true],
    // deleted revisions
    [
      publishedDeleted,
      "",
      noRouteFilters,
      onlyPublished,
      noDateFilters,
      oneWeekAgo,
      false,
    ],
    [
      readyDeleted,
      "",
      noRouteFilters,
      onlyReady,
      noDateFilters,
      oneWeekAgo,
      true,
    ],
    [
      draftDeleted,
      "",
      noRouteFilters,
      onlyDraft,
      noDateFilters,
      oneWeekAgo,
      true,
    ],
  ])(
    "%o with filters (%p, %o, %o, %o, %p)",
    (
      revision,
      query,
      routeFiltersArg,
      statusFiltersArg,
      dateFiltersArg,
      pastThreshold,
      expected
    ) => {
      expect(
        revisionMatchesFilters(
          revision,
          query,
          routeFiltersArg as FilterGroup<Routes>,
          statusFiltersArg as FilterGroup<
            "published" | "ready" | "needs_review"
          >,
          dateFiltersArg as FilterGroup<"include_past">,
          pastThreshold
        )
      ).toBe(expected)
    }
  )
})
