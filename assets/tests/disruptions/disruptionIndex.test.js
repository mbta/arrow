"use strict"
var __assign =
  (this && this.__assign) ||
  function () {
    __assign =
      Object.assign ||
      function (t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
          s = arguments[i]
          for (var p in s)
            if (Object.prototype.hasOwnProperty.call(s, p)) t[p] = s[p]
        }
        return t
      }
    return __assign.apply(this, arguments)
  }
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
var __awaiter =
  (this && this.__awaiter) ||
  function (thisArg, _arguments, P, generator) {
    function adopt(value) {
      return value instanceof P
        ? value
        : new P(function (resolve) {
            resolve(value)
          })
    }
    return new (P || (P = Promise))(function (resolve, reject) {
      function fulfilled(value) {
        try {
          step(generator.next(value))
        } catch (e) {
          reject(e)
        }
      }
      function rejected(value) {
        try {
          step(generator["throw"](value))
        } catch (e) {
          reject(e)
        }
      }
      function step(result) {
        result.done
          ? resolve(result.value)
          : adopt(result.value).then(fulfilled, rejected)
      }
      step((generator = generator.apply(thisArg, _arguments || [])).next())
    })
  }
var __generator =
  (this && this.__generator) ||
  function (thisArg, body) {
    var _ = {
        label: 0,
        sent: function () {
          if (t[0] & 1) throw t[1]
          return t[1]
        },
        trys: [],
        ops: [],
      },
      f,
      y,
      t,
      g
    return (
      (g = { next: verb(0), throw: verb(1), return: verb(2) }),
      typeof Symbol === "function" &&
        (g[Symbol.iterator] = function () {
          return this
        }),
      g
    )
    function verb(n) {
      return function (v) {
        return step([n, v])
      }
    }
    function step(op) {
      if (f) throw new TypeError("Generator is already executing.")
      while (_)
        try {
          if (
            ((f = 1),
            y &&
              (t =
                op[0] & 2
                  ? y["return"]
                  : op[0]
                  ? y["throw"] || ((t = y["return"]) && t.call(y), 0)
                  : y.next) &&
              !(t = t.call(y, op[1])).done)
          )
            return t
          if (((y = 0), t)) op = [op[0] & 2, t.value]
          switch (op[0]) {
            case 0:
            case 1:
              t = op
              break
            case 4:
              _.label++
              return { value: op[1], done: false }
            case 5:
              _.label++
              y = op[1]
              op = [0]
              continue
            case 7:
              op = _.ops.pop()
              _.trys.pop()
              continue
            default:
              if (
                !((t = _.trys), (t = t.length > 0 && t[t.length - 1])) &&
                (op[0] === 6 || op[0] === 2)
              ) {
                _ = 0
                continue
              }
              if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) {
                _.label = op[1]
                break
              }
              if (op[0] === 6 && _.label < t[1]) {
                _.label = t[1]
                t = op
                break
              }
              if (t && _.label < t[2]) {
                _.label = t[2]
                _.ops.push(op)
                break
              }
              if (t[2]) _.ops.pop()
              _.trys.pop()
              continue
          }
          op = body.call(thisArg, _)
        } catch (e) {
          op = [6, e]
          y = 0
        } finally {
          f = t = 0
        }
      if (op[0] & 5) throw op[1]
      return { value: op[0] ? op[1] : void 0, done: true }
    }
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
var disruptionIndex_1 = require("../../src/disruptions/disruptionIndex")
var disruption_1 = __importDefault(require("../../src/models/disruption"))
var disruptionRevision_1 = __importDefault(
  require("../../src/models/disruptionRevision")
)
var adjustment_1 = __importDefault(require("../../src/models/adjustment"))
var dayOfWeek_1 = __importDefault(require("../../src/models/dayOfWeek"))
var exception_1 = __importDefault(require("../../src/models/exception"))
var api = __importStar(require("../../src/api"))
var react_dom_1 = __importDefault(require("react-dom"))
var test_utils_1 = require("react-dom/test-utils")
var disruption_2 = require("../../src/models/disruption")
var fakeNow = new Date("2019-10-01")
var DisruptionIndexWithRouter = function (_a) {
  var _b = _a.connected,
    connected = _b === void 0 ? false : _b,
    _c = _a.fetchDisruption,
    fetchDisruption = _c === void 0 ? jest.fn() : _c,
    disruptions = _a.disruptions
  return React.createElement(
    react_router_dom_1.BrowserRouter,
    null,
    connected
      ? React.createElement(disruptionIndex_1.DisruptionIndex, { now: fakeNow })
      : React.createElement(disruptionIndex_1.DisruptionIndexView, {
          now: fakeNow,
          fetchDisruptions: fetchDisruption,
          disruptions: disruptions || [
            new disruption_1.default({
              publishedRevision: new disruptionRevision_1.default({
                id: "1",
                disruptionId: "1",
                startDate: new Date("2019-10-31"),
                endDate: new Date("2019-11-15"),
                isActive: true,
                adjustments: [
                  new adjustment_1.default({
                    id: "1",
                    routeId: "Red",
                    sourceLabel: "AlewifeHarvard",
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
                status: disruption_2.DisruptionView.Published,
              }),
              revisions: [
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
                      sourceLabel: "AlewifeHarvard",
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
                  status: disruption_2.DisruptionView.Published,
                }),
              ],
            }),
            new disruption_1.default({
              id: "3",
              readyRevision: new disruptionRevision_1.default({
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
              }),
              revisions: [
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
                }),
              ],
            }),
            new disruption_1.default({
              publishedRevision: new disruptionRevision_1.default({
                id: "4",
                disruptionId: "4",
                startDate: new Date("2019-09-01"),
                endDate: new Date("2019-09-15"),
                isActive: true,
                adjustments: [
                  new adjustment_1.default({
                    id: "3",
                    routeId: "Orange",
                    sourceLabel: "ForestHillsRuggles",
                  }),
                ],
                daysOfWeek: [
                  new dayOfWeek_1.default({ id: "1", dayName: "saturday" }),
                  new dayOfWeek_1.default({ id: "2", dayName: "sunday" }),
                ],
                exceptions: [],
                tripShortNames: [],
                status: disruption_2.DisruptionView.Published,
              }),
              revisions: [
                new disruptionRevision_1.default({
                  id: "4",
                  disruptionId: "4",
                  startDate: new Date("2019-09-01"),
                  endDate: new Date("2019-09-15"),
                  isActive: true,
                  adjustments: [
                    new adjustment_1.default({
                      id: "3",
                      routeId: "Orange",
                      sourceLabel: "ForestHillsRuggles",
                    }),
                  ],
                  daysOfWeek: [
                    new dayOfWeek_1.default({ id: "1", dayName: "saturday" }),
                    new dayOfWeek_1.default({ id: "2", dayName: "sunday" }),
                  ],
                  exceptions: [],
                  tripShortNames: [],
                  status: disruption_2.DisruptionView.Published,
                }),
              ],
            }),
          ],
        })
  )
}
describe("DisruptionIndexView", function () {
  test("header does not include link to homepage", function () {
    var container = react_1.render(
      React.createElement(DisruptionIndexWithRouter, null)
    ).container
    expect(container.querySelector("#header-home-link")).toBeNull()
  })
  test("disruptions can be filtered by label", function () {
    var container = react_1.render(
      React.createElement(DisruptionIndexWithRouter, null)
    ).container
    expect(container.querySelectorAll("tbody tr").length).toEqual(2)
    var searchInput = container.querySelector('input[type="text"]')
    if (!searchInput) {
      throw new Error("search input not found")
    }
    react_1.fireEvent.change(searchInput, { target: { value: "Alewife" } })
    expect(container.querySelectorAll("tbody tr").length).toEqual(1)
    expect(container.querySelectorAll("tbody tr").item(0).innerHTML).toMatch(
      "AlewifeHarvard"
    )
    react_1.fireEvent.change(searchInput, {
      target: { value: "Some other label" },
    })
    expect(container.querySelectorAll("tbody tr").length).toEqual(0)
  })
  test("disruptions can be filtered by route", function () {
    var container = react_1.render(
      React.createElement(DisruptionIndexWithRouter, null)
    ).container
    var tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(2)
    expect(tableRows.item(0).innerHTML).toContain("AlewifeHarvard")
    expect(tableRows.item(1).innerHTML).toContain("Kenmore-Newton")
    expect(container.querySelectorAll("#clear-filter").length).toEqual(0)
    expect(
      container.querySelectorAll(".m-disruption-index__route_filter.active")
        .length
    ).toEqual(9)
    var greenDselector = container.querySelector("#route-filter-toggle-Green-D")
    if (!greenDselector) {
      throw new Error("Green-D selector not found")
    }
    react_1.fireEvent.click(greenDselector)
    tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(1)
    expect(tableRows.item(0).innerHTML).toContain("Kenmore-Newton")
    expect(
      container.querySelectorAll(".m-disruption-index__route_filter.active")
        .length
    ).toEqual(1)
    var clearFilterLink = container.querySelector("#clear-filter")
    if (!clearFilterLink) {
      throw new Error("clear filter link not found")
    }
    react_1.fireEvent.click(clearFilterLink)
    tableRows = container.querySelectorAll("tbody tr")
    expect(tableRows.length).toEqual(2)
    var greenEselector = container.querySelector("#route-filter-toggle-Green-E")
    if (!greenEselector) {
      throw new Error("Green-E selector not found")
    }
    react_1.fireEvent.click(greenEselector)
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
    react_1.fireEvent.click(clearFilterLink)
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
  test("disruptions can be filtered by status", function () {
    var container = react_1.render(
      React.createElement(DisruptionIndexWithRouter, null)
    ).container
    expect(container.querySelectorAll("tbody tr").length).toEqual(2)
    var draftStatusToggle = container.querySelector(
      "#status-filter-toggle-needs-review"
    )
    if (!draftStatusToggle) {
      throw new Error("search input not found")
    }
    react_1.fireEvent.click(draftStatusToggle)
    expect(container.querySelectorAll("tbody tr").length).toEqual(1)
    expect(container.querySelectorAll("tbody tr").item(0).innerHTML).toMatch(
      "Kenmore-Newton Highlands"
    )
  })
  test("can be filtered to include past disruptions", function () {
    var _a, _b
    var container = react_1.render(
      React.createElement(DisruptionIndexWithRouter, null)
    ).container
    expect(container.querySelectorAll("tbody tr").length).toEqual(2)
    expect(
      (_a = container.querySelector("tbody")) === null || _a === void 0
        ? void 0
        : _a.innerHTML
    ).not.toMatch("ForestHillsRuggles")
    var pastFilterToggle = container.querySelector(
      "#date-filter-toggle-include-past"
    )
    if (!pastFilterToggle) throw new Error("past filter toggle not found")
    react_1.fireEvent.click(pastFilterToggle)
    expect(container.querySelectorAll("tbody tr").length).toEqual(3)
    expect(
      (_b = container.querySelector("tbody")) === null || _b === void 0
        ? void 0
        : _b.innerHTML
    ).toMatch("ForestHillsRuggles")
  })
  test("can toggle between table and calendar view", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, toggleButton
      var _a, _b, _c
      return __generator(this, function (_d) {
        switch (_d.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve([
                new disruption_1.default({
                  id: "1",
                  draftRevision: new disruptionRevision_1.default({
                    id: "1",
                    disruptionId: "1",
                    startDate: new Date("2019-10-31"),
                    endDate: new Date("2019-11-15"),
                    isActive: true,
                    adjustments: [
                      new adjustment_1.default({
                        id: "1",
                        routeId: "Red",
                        sourceLabel: "AlewifeHarvard",
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
                    status: disruption_2.DisruptionView.Draft,
                  }),
                  revisions: [
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
                          sourceLabel: "AlewifeHarvard",
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
                      status: disruption_2.DisruptionView.Draft,
                    }),
                  ],
                }),
              ])
            })
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_dom_1.default.render(
                      React.createElement(DisruptionIndexWithRouter, {
                        connected: true,
                      }),
                      container
                    )
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 1:
            // eslint-disable-next-line @typescript-eslint/require-await
            _d.sent()
            expect(react_1.queryByText(container, "time period")).not.toBeNull()
            expect(
              react_1.queryByAttribute("id", container, "calendar")
            ).toBeNull()
            expect(
              (_a = container.querySelector("#actions")) === null ||
                _a === void 0
                ? void 0
                : _a.hasAttribute("disabled")
            ).toEqual(false)
            toggleButton = container.querySelector("#view-toggle")
            if (!toggleButton) {
              throw new Error("toggle button not found")
            }
            expect(toggleButton.textContent).toEqual("⬒ calendar view")
            react_1.fireEvent.click(toggleButton)
            expect(react_1.queryByText(container, "time period")).toBeNull()
            expect(
              react_1.queryByAttribute("id", container, "calendar")
            ).not.toBeNull()
            expect(toggleButton.textContent).toEqual("⬒ list view")
            expect(
              (_b = container.querySelector("#actions")) === null ||
                _b === void 0
                ? void 0
                : _b.hasAttribute("disabled")
            ).toEqual(true)
            react_1.fireEvent.click(toggleButton)
            expect(react_1.queryByText(container, "time period")).not.toBeNull()
            expect(
              react_1.queryByAttribute("id", container, "calendar")
            ).toBeNull()
            expect(toggleButton.textContent).toEqual("⬒ calendar view")
            expect(
              (_c = container.querySelector("#actions")) === null ||
                _c === void 0
                ? void 0
                : _c.hasAttribute("disabled")
            ).toEqual(false)
            return [2 /*return*/]
        }
      })
    })
  })
})
describe("DisruptionIndexConnected", function () {
  test.each([
    [
      [
        new disruption_1.default({
          id: "1",
          readyRevision: new disruptionRevision_1.default({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
            adjustments: [
              new adjustment_1.default({
                id: "1",
                routeId: "Green-D",
                source: "gtfs_creator",
                sourceLabel: "NewtonHighlandsKenmore",
              }),
            ],
            daysOfWeek: [
              new dayOfWeek_1.default({
                id: "1",
                startTime: "20:45:00",
                dayName: "friday",
              }),
            ],
            exceptions: [
              new exception_1.default({
                id: "1",
                excludedDate: new Date("2020-01-20"),
              }),
            ],
            tripShortNames: [],
          }),
          revisions: [
            new disruptionRevision_1.default({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
              adjustments: [
                new adjustment_1.default({
                  id: "1",
                  routeId: "Green-D",
                  source: "gtfs_creator",
                  sourceLabel: "NewtonHighlandsKenmore",
                }),
              ],
              daysOfWeek: [
                new dayOfWeek_1.default({
                  id: "1",
                  startTime: "20:45:00",
                  dayName: "friday",
                }),
              ],
              exceptions: [
                new exception_1.default({
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
        new disruption_1.default({
          id: "1",
          readyRevision: new disruptionRevision_1.default({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
            adjustments: [
              new adjustment_1.default({
                id: "1",
                routeId: "Green-D",
                source: "gtfs_creator",
                sourceLabel: "NewtonHighlandsKenmore",
              }),
              new adjustment_1.default({
                id: "2",
                routeId: "Red",
                source: "gtfs_creator",
                sourceLabel: "HarvardAlewife",
              }),
              new adjustment_1.default({
                id: "3",
                routeId: "CR-Fairmount",
                source: "arrow",
                sourceLabel: "Fairmount--Newmarket",
              }),
            ],
            daysOfWeek: [
              new dayOfWeek_1.default({
                id: "1",
                startTime: "20:45:00",
                dayName: "saturday",
              }),
              new dayOfWeek_1.default({
                id: "2",
                endTime: "20:45:00",
                dayName: "sunday",
              }),
            ],
            exceptions: [
              new exception_1.default({
                id: "1",
                excludedDate: new Date("2020-01-20"),
              }),
            ],
            tripShortNames: [],
          }),
          revisions: [
            new disruptionRevision_1.default({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
              adjustments: [
                new adjustment_1.default({
                  id: "1",
                  routeId: "Green-D",
                  source: "gtfs_creator",
                  sourceLabel: "NewtonHighlandsKenmore",
                }),
                new adjustment_1.default({
                  id: "2",
                  routeId: "Red",
                  source: "gtfs_creator",
                  sourceLabel: "HarvardAlewife",
                }),
                new adjustment_1.default({
                  id: "3",
                  routeId: "CR-Fairmount",
                  source: "arrow",
                  sourceLabel: "Fairmount--Newmarket",
                }),
              ],
              daysOfWeek: [
                new dayOfWeek_1.default({
                  id: "1",
                  startTime: "20:45:00",
                  dayName: "saturday",
                }),
                new dayOfWeek_1.default({
                  id: "2",
                  endTime: "20:45:00",
                  dayName: "sunday",
                }),
              ],
              exceptions: [
                new exception_1.default({
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
        new disruption_1.default({
          id: "1",
          readyRevision: new disruptionRevision_1.default({
            id: "1",
            disruptionId: "1",
            startDate: new Date("2020-01-15"),
            endDate: new Date("2020-01-30"),
            isActive: true,
            adjustments: [
              new adjustment_1.default({
                id: "1",
                routeId: "Green-D",
                source: "gtfs_creator",
                sourceLabel: "NewtonHighlandsKenmore",
              }),
            ],
            daysOfWeek: [],
            exceptions: [
              new exception_1.default({
                id: "1",
                excludedDate: new Date("2020-01-20"),
              }),
            ],
            tripShortNames: [],
          }),
          revisions: [
            new disruptionRevision_1.default({
              id: "1",
              disruptionId: "1",
              startDate: new Date("2020-01-15"),
              endDate: new Date("2020-01-30"),
              isActive: true,
              adjustments: [
                new adjustment_1.default({
                  id: "1",
                  routeId: "Green-D",
                  source: "gtfs_creator",
                  sourceLabel: "NewtonHighlandsKenmore",
                }),
              ],
              daysOfWeek: [],
              exceptions: [
                new exception_1.default({
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
  ])("Renders the table correctly", function (disruptions, expected) {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, rows
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve(disruptions)
            })
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_dom_1.default.render(
                      React.createElement(DisruptionIndexWithRouter, {
                        connected: true,
                      }),
                      container
                    )
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 1:
            // eslint-disable-next-line @typescript-eslint/require-await
            _a.sent()
            rows = container.querySelectorAll("tbody tr")
            expect(rows.length).toEqual(
              disruptions.reduce(function (acc, curr) {
                return acc + curr.revisions.length
              }, 0)
            )
            rows.forEach(function (row, index) {
              var dataColumns = row.querySelectorAll("td")
              expect(dataColumns[0].textContent).toEqual(expected[index][0])
              expect(dataColumns[1].textContent).toEqual(expected[index][1])
            })
            return [2 /*return*/]
        }
      })
    })
  })
  test("can mark multiple revisions as ready", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var disruptions,
        getSpy,
        sendSpy,
        _a,
        container,
        findByText,
        actionsButton,
        checkboxes,
        confirmButton,
        sendSpyFail
      return __generator(this, function (_b) {
        switch (_b.label) {
          case 0:
            disruptions = [
              new disruption_1.default({
                id: "1",
                publishedRevision: new disruptionRevision_1.default({
                  id: "1",
                  disruptionId: "1",
                  startDate: new Date("2020-01-15"),
                  endDate: new Date("2020-01-30"),
                  isActive: false,
                  adjustments: [
                    new adjustment_1.default({
                      id: "1",
                      routeId: "Green-D",
                      source: "gtfs_creator",
                      sourceLabel: "NewtonHighlandsKenmore",
                    }),
                  ],
                  daysOfWeek: [],
                  exceptions: [],
                  tripShortNames: [],
                  status: disruption_2.DisruptionView.Published,
                }),
                revisions: [
                  new disruptionRevision_1.default({
                    id: "1",
                    disruptionId: "1",
                    startDate: new Date("2020-01-15"),
                    endDate: new Date("2020-01-30"),
                    isActive: false,
                    adjustments: [
                      new adjustment_1.default({
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
              new disruption_1.default({
                id: "2",
                readyRevision: new disruptionRevision_1.default({
                  id: "2",
                  disruptionId: "2",
                  startDate: new Date("2020-01-20"),
                  endDate: new Date("2020-01-25"),
                  isActive: false,
                  adjustments: [
                    new adjustment_1.default({
                      id: "1",
                      routeId: "Red",
                      source: "gtfs_creator",
                      sourceLabel: "AlewifeHarvard",
                    }),
                  ],
                  daysOfWeek: [],
                  exceptions: [],
                  tripShortNames: [],
                  status: disruption_2.DisruptionView.Published,
                }),
                draftRevision: new disruptionRevision_1.default({
                  id: "3",
                  disruptionId: "2",
                  startDate: new Date("2020-01-20"),
                  endDate: new Date("2020-01-28"),
                  isActive: true,
                  adjustments: [
                    new adjustment_1.default({
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
              new disruption_1.default({
                id: "3",
                readyRevision: new disruptionRevision_1.default({
                  id: "4",
                  disruptionId: "3",
                  startDate: new Date("2020-02-20"),
                  endDate: new Date("2020-02-25"),
                  isActive: false,
                  adjustments: [
                    new adjustment_1.default({
                      id: "1",
                      routeId: "Orange",
                      source: "gtfs_creator",
                      sourceLabel: "Wellington",
                    }),
                  ],
                  daysOfWeek: [],
                  exceptions: [],
                  tripShortNames: [],
                  status: disruption_2.DisruptionView.Ready,
                }),
                draftRevision: new disruptionRevision_1.default({
                  id: "5",
                  disruptionId: "3",
                  startDate: new Date("2020-02-21"),
                  endDate: new Date("2020-02-25"),
                  isActive: true,
                  adjustments: [
                    new adjustment_1.default({
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
            getSpy = jest.fn()
            sendSpy = jest
              .spyOn(api, "apiSend")
              .mockImplementation(function () {
                return Promise.resolve({
                  ok: {},
                })
              })
            ;(_a = react_1.render(
              React.createElement(DisruptionIndexWithRouter, {
                disruptions: disruptions,
                fetchDisruption: getSpy,
              })
            )),
              (container = _a.container),
              (findByText = _a.findByText)
            actionsButton = container.querySelector("#actions")
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            react_1.fireEvent.click(actionsButton)
            checkboxes = container.querySelectorAll("tr input[type=checkbox]")
            expect(checkboxes.length).toEqual(2)
            checkboxes.forEach(function (x) {
              expect(x.checked).toEqual(false)
            })
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            react_1.fireEvent.click(
              container.querySelector('tr[data-revision-id="5"] input')
            )
            expect(
              container.querySelector(
                'tr[data-revision-id="5"] input[type=checkbox]'
              ).checked
            ).toEqual(true)
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            react_1.fireEvent.click(container.querySelector("#toggle-all"))
            checkboxes.forEach(function (x) {
              expect(x.checked).toEqual(false)
            })
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            react_1.fireEvent.click(container.querySelector("#toggle-all"))
            expect(
              container.querySelectorAll("tr input:checked").length
            ).toEqual(2)
            checkboxes.forEach(function (x) {
              expect(x.checked).toEqual(true)
            })
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            react_1.fireEvent.click(container.querySelector("#actions"))
            expect(container.querySelectorAll("tr input").length).toEqual(0)
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            react_1.fireEvent.click(container.querySelector("#actions"))
            checkboxes = container.querySelectorAll("tr input")
            expect(checkboxes.length).toEqual(2)
            checkboxes.forEach(function (x) {
              expect(x.checked).toEqual(false)
            })
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            react_1.fireEvent.click(container.querySelector("#toggle-all"))
            expect(
              container.querySelectorAll("tr input:checked").length
            ).toEqual(2)
            checkboxes.forEach(function (x) {
              expect(x.checked).toEqual(true)
            })
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            react_1.fireEvent.click(
              container.querySelector("#route-filter-toggle-Orange")
            )
            expect(
              container.querySelectorAll("tr input:checked").length
            ).toEqual(1)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                    react_1.fireEvent.click(
                      container.querySelector("#mark-ready")
                    )
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 1:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [4 /*yield*/, findByText("yes, mark as ready")]
          case 2:
            confirmButton = _b.sent()
            if (!confirmButton) return [3 /*break*/, 4]
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_1.fireEvent.click(confirmButton)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 3:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [3 /*break*/, 5]
          case 4:
            throw new Error("confirm button not found")
          case 5:
            expect(sendSpy).toHaveBeenCalledWith(
              expect.objectContaining({
                url: "/api/ready_notice/",
                json: JSON.stringify({ revision_ids: "5" }),
                method: "POST",
              })
            )
            expect(getSpy).toHaveBeenCalledTimes(1)
            sendSpy.mockClear()
            sendSpyFail = jest
              .spyOn(api, "apiSend")
              .mockImplementation(function () {
                return Promise.reject()
              })
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                    react_1.fireEvent.click(
                      container.querySelector("#mark-ready")
                    )
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 6:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [4 /*yield*/, findByText("yes, mark as ready")]
          case 7:
            confirmButton = _b.sent()
            if (!confirmButton) return [3 /*break*/, 9]
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_1.fireEvent.click(confirmButton)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 8:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [3 /*break*/, 10]
          case 9:
            throw new Error("confirm button not found")
          case 10:
            expect(sendSpyFail).toBeCalledTimes(1)
            expect(getSpy).toHaveBeenCalledTimes(1)
            return [2 /*return*/]
        }
      })
    })
  })
  test("doesn't render deleted published disruption", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, rows
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve([
                new disruption_1.default({
                  id: "1",
                  publishedRevision: new disruptionRevision_1.default({
                    id: "2",
                    disruptionId: "1",
                    startDate: new Date("2020-01-15"),
                    endDate: new Date("2020-01-30"),
                    isActive: false,
                    adjustments: [
                      new adjustment_1.default({
                        id: "1",
                        routeId: "Green-D",
                        source: "gtfs_creator",
                        sourceLabel: "NewtonHighlandsKenmore",
                      }),
                    ],
                    daysOfWeek: [],
                    exceptions: [],
                    tripShortNames: [],
                    status: disruption_2.DisruptionView.Published,
                  }),
                  revisions: [
                    new disruptionRevision_1.default({
                      id: "2",
                      disruptionId: "1",
                      startDate: new Date("2020-01-15"),
                      endDate: new Date("2020-01-30"),
                      isActive: false,
                      adjustments: [
                        new adjustment_1.default({
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
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_dom_1.default.render(
                      React.createElement(DisruptionIndexWithRouter, {
                        connected: true,
                      }),
                      container
                    )
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 1:
            // eslint-disable-next-line @typescript-eslint/require-await
            _a.sent()
            rows = container.querySelectorAll("tbody tr")
            expect(rows.length).toEqual(0)
            return [2 /*return*/]
        }
      })
    })
  })
  test("displays only published revisions on the calendar view", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var today, nextWeek, published, ready, draft, container
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            today = new Date()
            today.setUTCHours(0, 0, 0, 0)
            nextWeek = new Date(
              Date.UTC(
                today.getUTCFullYear(),
                today.getUTCMonth(),
                today.getUTCDate() + 7
              )
            )
            published = new disruptionRevision_1.default({
              id: "1",
              disruptionId: "1",
              startDate: today,
              endDate: nextWeek,
              isActive: true,
              adjustments: [
                new adjustment_1.default({
                  id: "1",
                  routeId: "Red",
                  sourceLabel: "AlewifeHarvard",
                }),
              ],
              daysOfWeek: [new dayOfWeek_1.default({ dayName: "monday" })],
              exceptions: [],
              tripShortNames: [],
              status: disruption_2.DisruptionView.Published,
            })
            ready = new disruptionRevision_1.default(
              __assign(__assign({}, published), {
                id: "2",
                status: disruption_2.DisruptionView.Ready,
                daysOfWeek: [new dayOfWeek_1.default({ dayName: "tuesday" })],
              })
            )
            draft = new disruptionRevision_1.default(
              __assign(__assign({}, ready), {
                id: "3",
                status: disruption_2.DisruptionView.Draft,
                isActive: false,
              })
            )
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve([
                new disruption_1.default({
                  id: "1",
                  publishedRevision: published,
                  readyRevision: ready,
                  draftRevision: draft,
                  revisions: [published, ready, draft],
                }),
              ])
            })
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_dom_1.default.render(
                      React.createElement(DisruptionIndexWithRouter, {
                        connected: true,
                      }),
                      container
                    )
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 1:
            // eslint-disable-next-line @typescript-eslint/require-await
            _a.sent()
            react_1.fireEvent.click(
              react_1.getByText(container, /calendar view/i)
            )
            expect(
              react_1.getAllByText(container, /AlewifeHarvard/).length
            ).toBe(1)
            return [2 /*return*/]
        }
      })
    })
  })
  test("renders error", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve("error")
            })
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_dom_1.default.render(
                      React.createElement(DisruptionIndexWithRouter, {
                        connected: true,
                      }),
                      container
                    )
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 1:
            // eslint-disable-next-line @typescript-eslint/require-await
            _a.sent()
            expect(container.textContent).toMatch("Something went wrong")
            return [2 /*return*/]
        }
      })
    })
  })
})
describe("getRouteColor", function () {
  test("returns the correct color", function () {
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
    ].forEach(function (_a) {
      var route = _a[0],
        color = _a[1]
      expect(disruptionIndex_1.getRouteColor(route)).toEqual(color)
    })
  })
})
describe("revisionMatchesFilters", function () {
  var today = new Date(2020, 6, 15)
  var oneWeekAgo = new Date(2020, 6, 8)
  var twoWeeksAgo = new Date(2020, 6, 1)
  var oneWeekHence = new Date(2020, 6, 22)
  var published = new disruptionRevision_1.default({
    id: "1",
    isActive: true,
    adjustments: [
      new adjustment_1.default({
        id: "1",
        routeId: "Red",
        sourceLabel: "Adj 1",
      }),
    ],
    startDate: today,
    endDate: oneWeekHence,
    daysOfWeek: [],
    exceptions: [],
    tripShortNames: [],
    status: disruption_2.DisruptionView.Published,
  })
  var ready = new disruptionRevision_1.default({
    id: "2",
    isActive: true,
    adjustments: [
      new adjustment_1.default({
        id: "2",
        routeId: "Blue",
        sourceLabel: "Adj 2",
      }),
    ],
    startDate: today,
    endDate: oneWeekHence,
    daysOfWeek: [],
    exceptions: [],
    tripShortNames: [],
    status: disruption_2.DisruptionView.Ready,
  })
  var draft = new disruptionRevision_1.default({
    id: "3",
    isActive: true,
    adjustments: [
      new adjustment_1.default({
        id: "3",
        routeId: "Orange",
        sourceLabel: "Adj 3",
      }),
    ],
    startDate: today,
    endDate: oneWeekHence,
    daysOfWeek: [],
    exceptions: [],
    tripShortNames: [],
    status: disruption_2.DisruptionView.Draft,
  })
  var past = new disruptionRevision_1.default({
    id: "4",
    isActive: true,
    adjustments: [
      new adjustment_1.default({
        id: "1",
        routeId: "Red",
        sourceLabel: "Adj 1",
      }),
    ],
    startDate: twoWeeksAgo,
    endDate: oneWeekAgo,
    daysOfWeek: [],
    exceptions: [],
    tripShortNames: [],
    status: disruption_2.DisruptionView.Published,
  })
  var publishedDeleted = new disruptionRevision_1.default(
    __assign(__assign({}, published), { isActive: false })
  )
  var readyDeleted = new disruptionRevision_1.default(
    __assign(__assign({}, ready), { isActive: false })
  )
  var draftDeleted = new disruptionRevision_1.default(
    __assign(__assign({}, draft), { isActive: false })
  )
  var noRouteFilters = { state: {}, anyActive: false }
  var noStatusFilters = { state: {}, anyActive: false }
  var noDateFilters = { state: {}, anyActive: false }
  var onlyPublished = { state: { published: true }, anyActive: true }
  var onlyReady = { state: { ready: true }, anyActive: true }
  var onlyDraft = { state: { needs_review: true }, anyActive: true }
  var onlyRed = { state: { Red: true }, anyActive: true }
  var includePast = { state: { include_past: true }, anyActive: true }
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
    function (
      revision,
      query,
      routeFiltersArg,
      statusFiltersArg,
      dateFiltersArg,
      pastThreshold,
      expected
    ) {
      expect(
        disruptionIndex_1.revisionMatchesFilters(
          revision,
          query,
          routeFiltersArg,
          statusFiltersArg,
          dateFiltersArg,
          pastThreshold
        )
      ).toBe(expected)
    }
  )
})
