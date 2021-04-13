"use strict"
var __createBinding =
  (this && this.__createBinding) ||
  (Object.create
    ? function (o, m, k, k2) {
        if (k2 === undefined) k2 = k
        Object.defineProperty(o, k2, {
          enumerable: true,
          get: function () {
            return m[k]
          },
        })
      }
    : function (o, m, k, k2) {
        if (k2 === undefined) k2 = k
        o[k2] = m[k]
      })
var __setModuleDefault =
  (this && this.__setModuleDefault) ||
  (Object.create
    ? function (o, v) {
        Object.defineProperty(o, "default", { enumerable: true, value: v })
      }
    : function (o, v) {
        o["default"] = v
      })
var __importStar =
  (this && this.__importStar) ||
  function (mod) {
    if (mod && mod.__esModule) return mod
    var result = {}
    if (mod != null)
      for (var k in mod)
        if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k))
          __createBinding(result, mod, k)
    __setModuleDefault(result, mod)
    return result
  }
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var React = __importStar(require("react"))
var react_router_dom_1 = require("react-router-dom")
var react_1 = require("@testing-library/react")
var disruptionTable_1 = require("../../src/disruptions/disruptionTable")
var adjustment_1 = __importDefault(require("../../src/models/adjustment"))
var dayOfWeek_1 = __importDefault(require("../../src/models/dayOfWeek"))
var disruptionRevision_1 = __importDefault(
  require("../../src/models/disruptionRevision")
)
var disruption_1 = require("../../src/models/disruption")
var exception_1 = __importDefault(require("../../src/models/exception"))
var DisruptionTableWithRouter = function (_a) {
  var initialEntries = _a.initialEntries
  return React.createElement(
    react_router_dom_1.MemoryRouter,
    { initialEntries: initialEntries },
    React.createElement(disruptionTable_1.DisruptionTable, {
      selectEnabled: false,
      toggleRevisionSelection: function () {
        return true
      },
      disruptionRevisions: [
        new disruptionRevision_1.default({
          id: "1",
          disruptionId: "1",
          startDate: new Date("2019-10-31"),
          endDate: new Date("2019-11-15"),
          isActive: true,
          adjustments: [
            new adjustment_1.default({
              id: "1",
              routeId: "Red",
              sourceLabel: "NorthQuincyQuincyCenter",
            }),
            new adjustment_1.default({
              id: "2",
              routeId: "Green-D",
              sourceLabel: "Kenmore-Newton Highlands",
            }),
          ],
          daysOfWeek: [
            new dayOfWeek_1.default({
              id: "1",
              startTime: "20:45:00",
              dayName: "thursday",
            }),
            new dayOfWeek_1.default({
              id: "2",
              dayName: "friday",
            }),
            new dayOfWeek_1.default({
              id: "3",
              dayName: "saturday",
            }),
          ],
          exceptions: [
            new exception_1.default({ excludedDate: new Date("2019-10-30") }),
          ],
          tripShortNames: [],
          status: disruption_1.DisruptionView.Draft,
        }),
        new disruptionRevision_1.default({
          id: "4",
          disruptionId: "1",
          startDate: new Date("2019-10-31"),
          endDate: new Date("2019-11-16"),
          isActive: true,
          adjustments: [
            new adjustment_1.default({
              id: "1",
              routeId: "Red",
              sourceLabel: "NorthQuincyQuincyCenter",
            }),
            new adjustment_1.default({
              id: "2",
              routeId: "Green-D",
              sourceLabel: "Kenmore-Newton Highlands",
            }),
          ],
          daysOfWeek: [
            new dayOfWeek_1.default({
              id: "1",
              startTime: "20:45:00",
              dayName: "thursday",
            }),
            new dayOfWeek_1.default({
              id: "2",
              dayName: "friday",
            }),
            new dayOfWeek_1.default({
              id: "3",
              dayName: "saturday",
            }),
          ],
          exceptions: [
            new exception_1.default({ excludedDate: new Date("2019-10-31") }),
          ],
          tripShortNames: [],
          status: disruption_1.DisruptionView.Draft,
        }),
        new disruptionRevision_1.default({
          id: "2",
          disruptionId: "2",
          startDate: new Date("2019-10-23"),
          endDate: new Date("2019-10-24"),
          isActive: true,
          adjustments: [
            new adjustment_1.default({
              id: "2",
              routeId: "Green-D",
              sourceLabel: "Kenmore-Newton Highlands",
            }),
          ],
          daysOfWeek: [
            new dayOfWeek_1.default({
              id: "1",
              startTime: "20:45:00",
              dayName: "friday",
            }),
            new dayOfWeek_1.default({
              id: "2",
              dayName: "saturday",
            }),
            new dayOfWeek_1.default({
              id: "3",
              dayName: "sunday",
            }),
          ],
          exceptions: [],
          tripShortNames: [],
          status: disruption_1.DisruptionView.Published,
        }),
        new disruptionRevision_1.default({
          id: "3",
          disruptionId: "3",
          startDate: new Date("2019-09-22"),
          endDate: new Date("2019-10-22"),
          isActive: true,
          adjustments: [
            new adjustment_1.default({
              id: "2",
              routeId: "Green-D",
              sourceLabel: "Kenmore-Newton Highlands",
            }),
          ],
          daysOfWeek: [
            new dayOfWeek_1.default({
              id: "1",
              startTime: "20:45:00",
              dayName: "friday",
            }),
            new dayOfWeek_1.default({
              id: "2",
              dayName: "saturday",
            }),
            new dayOfWeek_1.default({
              id: "3",
              dayName: "sunday",
            }),
          ],
          exceptions: [],
          tripShortNames: [],
          status: disruption_1.DisruptionView.Ready,
        }),
      ].map(function (revision) {
        return {
          selected: false,
          selectable: false,
          selectEnabled: false,
          revision: revision,
        }
      }),
    })
  )
}
describe("DisruptionTable", function () {
  test("displays rowlette if the revision's parent shares the same label", function () {
    var container = react_1.render(
      React.createElement(DisruptionTableWithRouter, null)
    ).container
    var tableRows = container.querySelectorAll("tbody tr")
    expect(
      tableRows.item(2).querySelectorAll("td").item(0).textContent
    ).toEqual("NorthQuincyQuincyCenterKenmore-Newton Highlands")
    expect(
      tableRows.item(3).querySelectorAll("td").item(0).textContent
    ).toEqual("↘")
  })
  test("displays difference between rows", function () {
    var container = react_1.render(
      React.createElement(DisruptionTableWithRouter, null)
    ).container
    var tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(4)
    var firstRow = tableRows.item(2)
    var firstRowData = firstRow.querySelectorAll("td")
    firstRowData.forEach(function (td) {
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
    var nextRow = tableRows.item(3)
    var nextRowData = nextRow.querySelectorAll("td")
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
  test("can sort table by columns", function () {
    var container = react_1.render(
      React.createElement(DisruptionTableWithRouter, null)
    ).container
    var tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(4)
    var firstRow = tableRows.item(0)
    var firstRowData = firstRow.querySelectorAll("td")
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
    var activeSortToggle = container.querySelector(
      ".m-disruption-table__sortable.active"
    )
    if (!activeSortToggle) {
      throw new Error("active sort toggle not found")
    }
    expect(activeSortToggle.textContent).toEqual("adjustments↑")
    react_1.fireEvent.click(activeSortToggle)
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
    var dateSort = react_1.screen.getByText("date range")
    react_1.fireEvent.click(dateSort)
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
    var timePeriodSort = react_1.screen.getByText("time period")
    react_1.fireEvent.click(timePeriodSort)
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
    react_1.fireEvent.click(timePeriodSort)
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
    var disruptionIdSort = react_1.screen.getByText("ID")
    react_1.fireEvent.click(disruptionIdSort)
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
    react_1.fireEvent.click(disruptionIdSort)
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
    var statusSort = react_1.screen.getByText("status")
    react_1.fireEvent.click(statusSort)
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
    react_1.fireEvent.click(statusSort)
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
    var exceptionsSort = react_1.screen.getByText("except")
    react_1.fireEvent.click(exceptionsSort)
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
    react_1.fireEvent.click(exceptionsSort)
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
