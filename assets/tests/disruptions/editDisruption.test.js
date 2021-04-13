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
var test_utils_1 = require("react-dom/test-utils")
var react_router_dom_1 = require("react-router-dom")
var react_1 = require("@testing-library/react")
var dom_1 = require("@testing-library/dom")
var api = __importStar(require("../../src/api"))
var editDisruption_1 = __importDefault(
  require("../../src/disruptions/editDisruption")
)
var adjustment_1 = __importDefault(require("../../src/models/adjustment"))
var dayOfWeek_1 = __importDefault(require("../../src/models/dayOfWeek"))
var disruption_1 = __importDefault(require("../../src/models/disruption"))
var disruptionRevision_1 = __importDefault(
  require("../../src/models/disruptionRevision")
)
var exception_1 = __importDefault(require("../../src/models/exception"))
describe("EditDisruption", function () {
  var apiCallSpy
  var apiSendSpy
  var windowConfirmSpy
  beforeEach(function () {
    windowConfirmSpy = jest
      .spyOn(window, "confirm")
      .mockImplementation(function () {
        return true
      })
    apiCallSpy = jest.spyOn(api, "apiGet").mockImplementation(function () {
      return Promise.resolve(
        new disruption_1.default({
          readyRevision: new disruptionRevision_1.default({
            id: "1",
            startDate: new Date("2020-01-15T00:00:00"),
            endDate: new Date("2020-01-30T00:00:00"),
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
                excludedDate: new Date("2020-01-20T00:00:00"),
              }),
            ],
            tripShortNames: [],
          }),
          revisions: [
            new disruptionRevision_1.default({
              id: "1",
              startDate: new Date("2020-01-15T00:00:00"),
              endDate: new Date("2020-01-30T00:00:00"),
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
                  excludedDate: new Date("2020-01-20T00:00:00"),
                }),
              ],
              tripShortNames: [],
            }),
          ],
        })
      )
    })
  })
  afterAll(function () {
    apiCallSpy.mockRestore()
    apiSendSpy.mockRestore()
    windowConfirmSpy.mockRestore()
  })
  test("header include link to homepage", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            expect(container.querySelector("#header-home-link")).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("cancel link redirects back to view page", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                {
                  initialEntries: ["/previouspage", "/disruptions/foo/edit"],
                  initialIndex: 1,
                },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/previouspage",
                    render: function () {
                      return React.createElement("div", null, "You went back")
                    },
                  }),
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            )
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            react_1.fireEvent.click(react_1.screen.getByText("cancel"))
            react_1.fireEvent.click(react_1.screen.getByText("discard changes"))
            expect(react_1.screen.queryByText("You went back")).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("handles error fetching disruption", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            apiCallSpy = jest
              .spyOn(api, "apiGet")
              .mockImplementationOnce(function () {
                return Promise.resolve("error")
              })
            react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            )
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            expect(
              react_1.screen.getByText("Error loading disruption.")
            ).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("handles error with day of week information", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            apiCallSpy = jest
              .spyOn(api, "apiGet")
              .mockImplementationOnce(function () {
                return Promise.resolve(
                  new disruption_1.default({
                    readyRevision: new disruptionRevision_1.default({
                      isActive: true,
                      adjustments: [],
                      daysOfWeek: [
                        new dayOfWeek_1.default({
                          startTime: "20:37:00",
                          dayName: "friday",
                        }),
                      ],
                      exceptions: [],
                      tripShortNames: [],
                    }),
                    revisions: [
                      new disruptionRevision_1.default({
                        isActive: true,
                        adjustments: [],
                        daysOfWeek: [
                          new dayOfWeek_1.default({
                            startTime: "20:37:00",
                            dayName: "friday",
                          }),
                        ],
                        exceptions: [],
                        tripShortNames: [],
                      }),
                    ],
                  })
                )
              })
            react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            )
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            expect(
              react_1.screen.queryByText(
                "Error parsing day of week information."
              )
            ).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("update start date", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, startDateInput
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            startDateInput = container.querySelector(
              "#disruption-date-range-start"
            )
            if (startDateInput) {
              react_1.fireEvent.change(startDateInput, {
                target: { value: "01/14/2020" },
              })
            } else {
              throw new Error("disruption date range start input not found")
            }
            expect(
              react_1.screen.queryByDisplayValue("01/14/2020")
            ).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("clear start date", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, startDateInput
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            startDateInput = container.querySelector(
              "#disruption-date-range-start"
            )
            if (startDateInput) {
              react_1.fireEvent.change(startDateInput, {
                target: { value: "" },
              })
            } else {
              throw new Error("disruption date range start input not found")
            }
            expect(startDateInput.value).toEqual("")
            return [2 /*return*/]
        }
      })
    })
  })
  test("update end date", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, startDateInput
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            startDateInput = container.querySelector(
              "#disruption-date-range-end"
            )
            if (startDateInput) {
              react_1.fireEvent.change(startDateInput, {
                target: { value: "01/19/2020" },
              })
            } else {
              throw new Error("disruption date range end input not found")
            }
            expect(
              react_1.screen.queryByDisplayValue("01/19/2020")
            ).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("clear end date", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, endDateInput
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            endDateInput = container.querySelector("#disruption-date-range-end")
            if (endDateInput) {
              react_1.fireEvent.change(endDateInput, { target: { value: "" } })
            } else {
              throw new Error("disruption date range start input not found")
            }
            expect(endDateInput.value).toEqual("")
            return [2 /*return*/]
        }
      })
    })
  })
  test("adding exception date", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, addExceptionLink, exceptionDateInput
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            addExceptionLink = container.querySelector(
              "#date-exception-add-link"
            )
            if (addExceptionLink) {
              react_1.fireEvent.click(addExceptionLink)
            } else {
              throw new Error("add exception link not found")
            }
            exceptionDateInput = container.querySelector(
              "[data-date-exception-new=true] input"
            )
            if (exceptionDateInput) {
              react_1.fireEvent.change(exceptionDateInput, {
                target: { value: "01/21/2020" },
              })
            } else {
              throw new Error("new exception input not found")
            }
            expect(
              react_1.screen.queryByDisplayValue("01/21/2020")
            ).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("removing exception date", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            )
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            react_1.fireEvent.click(
              react_1.screen.getByTestId("remove-exception-date")
            )
            expect(react_1.screen.queryByDisplayValue("01/20/2020")).toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("adding and updating day of week", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container,
        dayOfWeekMCheck,
        startOfServiceCheck,
        endOfServiceCheck,
        startHour,
        startMinute,
        startPeriod,
        endHour,
        endMinute,
        endPeriod
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            dayOfWeekMCheck = container.querySelector("#day-of-week-Mon")
            if (dayOfWeekMCheck) {
              react_1.fireEvent.click(dayOfWeekMCheck)
            } else {
              throw new Error("Monday checkbox not found")
            }
            startOfServiceCheck = container.querySelector(
              "#time-of-day-start-type-0"
            )
            endOfServiceCheck = container.querySelector(
              "#time-of-day-end-type-0"
            )
            startHour = container.querySelector("#time-of-day-start-hour-0")
            startMinute = container.querySelector("#time-of-day-start-minute-0")
            startPeriod = container.querySelector("#time-of-day-start-period-0")
            endHour = container.querySelector("#time-of-day-end-hour-0")
            endMinute = container.querySelector("#time-of-day-end-minute-0")
            endPeriod = container.querySelector("#time-of-day-end-period-0")
            if (
              startOfServiceCheck &&
              endOfServiceCheck &&
              startHour &&
              startMinute &&
              startPeriod &&
              endHour &&
              endMinute &&
              endPeriod
            ) {
              react_1.fireEvent.click(startOfServiceCheck)
              react_1.fireEvent.click(endOfServiceCheck)
              react_1.fireEvent.change(startHour, { target: { value: "8" } })
              react_1.fireEvent.change(startMinute, { target: { value: "30" } })
              react_1.fireEvent.change(startPeriod, { target: { value: "AM" } })
              react_1.fireEvent.change(endHour, { target: { value: "8" } })
              react_1.fireEvent.change(endMinute, { target: { value: "30" } })
              react_1.fireEvent.change(endPeriod, { target: { value: "PM" } })
            } else {
              throw new Error("day of week time range inputs not found")
            }
            expect(startHour.value).toBe("8")
            expect(startMinute.value).toBe("30")
            expect(startPeriod.value).toBe("AM")
            expect(endHour.value).toBe("8")
            expect(endMinute.value).toBe("30")
            expect(endPeriod.value).toBe("PM")
            return [2 /*return*/]
        }
      })
    })
  })
  test("successfully creating disruption", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, saveButton
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            apiSendSpy = jest
              .spyOn(api, "apiSend")
              .mockImplementation(function () {
                return Promise.resolve({
                  ok: {},
                })
              })
            container = react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id",
                    render: function () {
                      return React.createElement("div", null, "Success!!!")
                    },
                  }),
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            saveButton = container.querySelector("#save-disruption-button")
            if (!saveButton) return [3 /*break*/, 3]
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_1.fireEvent.click(saveButton)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 2:
            // eslint-disable-next-line @typescript-eslint/require-await
            _a.sent()
            return [3 /*break*/, 4]
          case 3:
            throw new Error("save button not found")
          case 4:
            expect(react_1.screen.queryByText("Success!!!")).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("handles error with saving disruption", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, saveButton
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            apiSendSpy = jest
              .spyOn(api, "apiSend")
              .mockImplementation(function () {
                return Promise.resolve({
                  error: ["Data is all wrong"],
                })
              })
            container = react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/foo/edit"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id",
                    render: function () {
                      return React.createElement("div", null, "Success!!!")
                    },
                  }),
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/:id/edit",
                    component: editDisruption_1.default,
                  })
                )
              )
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            saveButton = container.querySelector("#save-disruption-button")
            if (!saveButton) return [3 /*break*/, 3]
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_1.fireEvent.click(saveButton)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 2:
            // eslint-disable-next-line @typescript-eslint/require-await
            _a.sent()
            return [3 /*break*/, 4]
          case 3:
            throw new Error("save button not found")
          case 4:
            expect(react_1.screen.getByText("Data is all wrong")).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
})
