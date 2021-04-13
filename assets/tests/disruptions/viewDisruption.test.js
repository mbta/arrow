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
var history_1 = require("history")
var React = __importStar(require("react"))
var react_router_dom_1 = require("react-router-dom")
var test_utils_1 = require("react-dom/test-utils")
var react_router_dom_2 = require("react-router-dom")
var ReactDOM = __importStar(require("react-dom"))
var api = __importStar(require("../../src/api"))
var jsonApi_1 = require("../../src/jsonApi")
var react_1 = require("@testing-library/react")
var dom_1 = require("@testing-library/dom")
var viewDisruption_1 = __importDefault(
  require("../../src/disruptions/viewDisruption")
)
var adjustment_1 = __importDefault(require("../../src/models/adjustment"))
var dayOfWeek_1 = __importDefault(require("../../src/models/dayOfWeek"))
var disruption_1 = __importDefault(require("../../src/models/disruption"))
var disruptionRevision_1 = __importDefault(
  require("../../src/models/disruptionRevision")
)
var exception_1 = __importDefault(require("../../src/models/exception"))
var tripShortName_1 = __importDefault(require("../../src/models/tripShortName"))
describe("ViewDisruption", function () {
  test("loads and displays disruption from the API", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var history, container
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve(
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
                    tripShortNames: [
                      new tripShortName_1.default({ tripShortName: "123" }),
                      new tripShortName_1.default({ tripShortName: "456" }),
                    ],
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
                      tripShortNames: [
                        new tripShortName_1.default({ tripShortName: "123" }),
                        new tripShortName_1.default({ tripShortName: "456" }),
                      ],
                    }),
                  ],
                })
              )
            })
            history = history_1.createBrowserHistory()
            history.push("/disruptions/1?v=ready")
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    ReactDOM.render(
                      React.createElement(
                        react_router_dom_1.BrowserRouter,
                        null,
                        React.createElement(viewDisruption_1.default, {
                          match: {
                            params: { id: "1" },
                            isExact: true,
                            path: "/disruptions/1?v=ready",
                            url: "https://localhost/disruptions/1?v=ready",
                          },
                          history: history,
                          location: {
                            pathname: "/disruptions/1?v=ready",
                            search: "?v=ready",
                            state: {},
                            hash: "",
                          },
                        })
                      ),
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
            expect(document.body.textContent).toMatch("NewtonHighlandsKenmore")
            expect(document.body.textContent).toMatch("1/15/2020")
            expect(document.body.textContent).toMatch("1/30/2020")
            expect(document.body.textContent).toMatch("1/20/2020")
            expect(document.body.textContent).toMatch("Friday")
            expect(document.body.textContent).toMatch("8:45PM")
            expect(document.body.textContent).toMatch("123, 456")
            expect(document.body.textContent).toMatch("End of service")
            return [2 /*return*/]
        }
      })
    })
  })
  test("indicates if revision does not exist for ready view", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var history, container
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  publishedRevision: new disruptionRevision_1.default({
                    id: "1",
                    disruptionId: "1",
                    startDate: new Date("2020-01-15"),
                    endDate: new Date("2020-01-30"),
                    isActive: true,
                    adjustments: [],
                    daysOfWeek: [],
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [
                    new disruptionRevision_1.default({
                      id: "1",
                      disruptionId: "1",
                      startDate: new Date("2020-01-15"),
                      endDate: new Date("2020-01-30"),
                      isActive: true,
                      adjustments: [],
                      daysOfWeek: [],
                      exceptions: [],
                      tripShortNames: [],
                    }),
                  ],
                })
              )
            })
            history = history_1.createBrowserHistory()
            history.push("/disruptions/1?v=draft")
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    ReactDOM.render(
                      React.createElement(
                        react_router_dom_1.BrowserRouter,
                        null,
                        React.createElement(viewDisruption_1.default, {
                          match: {
                            params: { id: "1" },
                            isExact: true,
                            path: "/disruptions/1?v=draft",
                            url: "https://localhost/disruptions/1?v=draft",
                          },
                          history: history,
                          location: {
                            pathname: "/disruptions/1?v=draft",
                            search: "?v=draft",
                            state: {},
                            hash: "",
                          },
                        })
                      ),
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
            expect(container.textContent).toMatch(
              "Disruption 1 has no draft revision"
            )
            return [2 /*return*/]
        }
      })
    })
  })
  test("indicates if revision does not exist for draft view", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var history, container
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  draftRevision: new disruptionRevision_1.default({
                    id: "1",
                    disruptionId: "1",
                    startDate: new Date("2020-01-15"),
                    endDate: new Date("2020-01-30"),
                    isActive: true,
                    adjustments: [],
                    daysOfWeek: [],
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [
                    new disruptionRevision_1.default({
                      id: "1",
                      disruptionId: "1",
                      startDate: new Date("2020-01-15"),
                      endDate: new Date("2020-01-30"),
                      isActive: true,
                      adjustments: [],
                      daysOfWeek: [],
                      exceptions: [],
                      tripShortNames: [],
                    }),
                  ],
                })
              )
            })
            history = history_1.createBrowserHistory()
            history.push("/disruptions/1?v=ready")
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    ReactDOM.render(
                      React.createElement(
                        react_router_dom_1.BrowserRouter,
                        null,
                        React.createElement(viewDisruption_1.default, {
                          match: {
                            params: { id: "1" },
                            isExact: true,
                            path: "/disruptions/1?v=ready",
                            url: "https://localhost/disruptions/1?v=ready",
                          },
                          history: history,
                          location: {
                            pathname: "/disruptions/1?v=ready",
                            search: "?v=ready",
                            state: {},
                            hash: "",
                          },
                        })
                      ),
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
            expect(container.textContent).toMatch(
              "Disruption 1 has no ready revision"
            )
            return [2 /*return*/]
        }
      })
    })
  })
  test("indicates if revision does not exist for published view", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var history, container
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  draftRevision: new disruptionRevision_1.default({
                    id: "1",
                    disruptionId: "1",
                    startDate: new Date("2020-01-15"),
                    endDate: new Date("2020-01-30"),
                    isActive: true,
                    adjustments: [],
                    daysOfWeek: [],
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [
                    new disruptionRevision_1.default({
                      id: "1",
                      disruptionId: "1",
                      startDate: new Date("2020-01-15"),
                      endDate: new Date("2020-01-30"),
                      isActive: true,
                      adjustments: [],
                      daysOfWeek: [],
                      exceptions: [],
                      tripShortNames: [],
                    }),
                  ],
                })
              )
            })
            history = history_1.createBrowserHistory()
            history.push("/disruptions/1?v=published")
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    ReactDOM.render(
                      React.createElement(
                        react_router_dom_1.BrowserRouter,
                        null,
                        React.createElement(viewDisruption_1.default, {
                          match: {
                            params: { id: "1" },
                            isExact: true,
                            path: "/disruptions/1?v=published",
                            url: "https://localhost/disruptions/1?v=published",
                          },
                          history: history,
                          location: {
                            pathname: "/disruptions/1?v=published",
                            search: "?v=published",
                            state: {},
                            hash: "",
                          },
                        })
                      ),
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
            expect(container.textContent).toMatch(
              "Disruption 1 has no published revision"
            )
            return [2 /*return*/]
        }
      })
    })
  })
  test("edit link redirects to edit page", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var history, container, editButton
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  draftRevision: new disruptionRevision_1.default({
                    id: "1",
                    disruptionId: "1",
                    startDate: new Date("2020-01-15"),
                    endDate: new Date("2020-01-30"),
                    isActive: true,
                    adjustments: [],
                    daysOfWeek: [],
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [
                    new disruptionRevision_1.default({
                      id: "1",
                      disruptionId: "1",
                      startDate: new Date("2020-01-15"),
                      endDate: new Date("2020-01-30"),
                      isActive: true,
                      adjustments: [],
                      daysOfWeek: [],
                      exceptions: [],
                      tripShortNames: [],
                    }),
                  ],
                })
              )
            })
            history = history_1.createBrowserHistory()
            history.push("/disruptions/1?v=draft")
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    ReactDOM.render(
                      React.createElement(
                        react_router_dom_1.BrowserRouter,
                        null,
                        React.createElement(viewDisruption_1.default, {
                          match: {
                            params: { id: "1" },
                            isExact: true,
                            path: "/disruptions/1?v=draft",
                            url: "https://localhost/disruptions/1?v=draft",
                          },
                          history: history,
                          location: {
                            pathname: "/disruptions/1?v=draft",
                            search: "?v=draft",
                            state: {},
                            hash: "",
                          },
                        })
                      ),
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
            editButton = container.querySelector("#edit-disruption-link")
            expect(editButton).toBeDefined()
            // expect(editButton.textContent).toEqual("edit")
            test_utils_1.act(function () {
              editButton.dispatchEvent(
                new MouseEvent("click", { bubbles: true })
              )
            })
            expect(location.pathname).toBe("/disruptions/1/edit")
            return [2 /*return*/]
        }
      })
    })
  })
  test("handles error on fetching / parsing", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var history, container
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve("error")
            })
            history = history_1.createBrowserHistory()
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    ReactDOM.render(
                      React.createElement(
                        react_router_dom_1.BrowserRouter,
                        null,
                        React.createElement(viewDisruption_1.default, {
                          match: {
                            params: { id: "1" },
                            isExact: true,
                            path: "/disruptions/1",
                            url: "https://localhost/disruptions/1",
                          },
                          history: history,
                          location: {
                            pathname: "/disruptions/1",
                            search: "",
                            state: {},
                            hash: "",
                          },
                        })
                      ),
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
            expect(document.body.textContent).toMatch(
              "Error fetching or parsing disruption."
            )
            return [2 /*return*/]
        }
      })
    })
  })
  test("handles error with day of week values", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var history, container
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  publishedRevision: new disruptionRevision_1.default({
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
                        startTime: "20:37:00",
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
                          startTime: "20:37:00",
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
                })
              )
            })
            history = history_1.createBrowserHistory()
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    ReactDOM.render(
                      React.createElement(
                        react_router_dom_1.BrowserRouter,
                        null,
                        React.createElement(viewDisruption_1.default, {
                          match: {
                            params: { id: "1" },
                            isExact: true,
                            path: "/disruptions/1",
                            url: "https://localhost/disruptions/1",
                          },
                          history: history,
                          location: {
                            pathname: "/disruptions/1",
                            search: "",
                            state: {},
                            hash: "",
                          },
                        })
                      ),
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
            expect(document.body.textContent).toMatch(
              "Error parsing day of week information."
            )
            return [2 /*return*/]
        }
      })
    })
  })
  test("doesn't display delete button for disruption that started in the past", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var startDate, endDate, container, deleteButton
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            startDate = new Date()
            startDate.setTime(startDate.getTime() - 24 * 60 * 60 * 1000)
            startDate = new Date(startDate.toDateString())
            endDate = new Date(new Date().toDateString())
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  readyRevision: new disruptionRevision_1.default({
                    id: "1",
                    disruptionId: "1",
                    startDate: startDate,
                    endDate: endDate,
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
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [
                    new disruptionRevision_1.default({
                      id: "1",
                      disruptionId: "1",
                      startDate: startDate,
                      endDate: endDate,
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
                      exceptions: [],
                      tripShortNames: [],
                    }),
                  ],
                })
              )
            })
            container = react_1.render(
              React.createElement(
                react_router_dom_2.MemoryRouter,
                { initialEntries: ["/disruptions/1"] },
                React.createElement(
                  react_router_dom_2.Switch,
                  null,
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/disruptions/:id/",
                    component: viewDisruption_1.default,
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
            deleteButton = container.querySelector("#delete-disruption-button")
            expect(deleteButton).toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("can delete a disruption", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var startDate,
        endDate,
        _a,
        container,
        findByText,
        deleteButton,
        apiSendSpy,
        confirmButton
      return __generator(this, function (_b) {
        switch (_b.label) {
          case 0:
            startDate = new Date()
            startDate.setTime(startDate.getTime() + 24 * 60 * 60 * 1000)
            startDate = new Date(startDate.toDateString())
            endDate = new Date()
            startDate.setTime(startDate.getTime() + 2 * 24 * 60 * 60 * 1000)
            endDate = new Date(endDate.toDateString())
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  readyRevision: new disruptionRevision_1.default({
                    id: "1",
                    disruptionId: "1",
                    startDate: startDate,
                    endDate: endDate,
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
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [
                    new disruptionRevision_1.default({
                      id: "1",
                      disruptionId: "1",
                      startDate: startDate,
                      endDate: endDate,
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
                      exceptions: [],
                      tripShortNames: [],
                    }),
                  ],
                })
              )
            })
            ;(_a = react_1.render(
              React.createElement(
                react_router_dom_2.MemoryRouter,
                { initialEntries: ["/disruptions/1?v=ready"] },
                React.createElement(
                  react_router_dom_2.Switch,
                  null,
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/disruptions/:id/",
                    component: viewDisruption_1.default,
                  }),
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/",
                    render: function () {
                      return React.createElement("div", null, "Success!!!")
                    },
                  })
                )
              )
            )),
              (container = _a.container),
              (findByText = _a.findByText)
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _b.sent()
            deleteButton = container.querySelector("#delete-disruption-button")
            apiSendSpy = jest
              .spyOn(api, "apiSend")
              .mockImplementationOnce(function (_a) {
                var successParser = _a.successParser
                return Promise.resolve({
                  // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                  ok: successParser(null),
                })
              })
            if (!deleteButton) return [3 /*break*/, 3]
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_1.fireEvent.click(deleteButton)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 2:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [3 /*break*/, 4]
          case 3:
            throw new Error("delete button not found")
          case 4:
            return [4 /*yield*/, findByText("mark for deletion")]
          case 5:
            confirmButton = _b.sent()
            if (!confirmButton) return [3 /*break*/, 7]
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
          case 6:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [3 /*break*/, 8]
          case 7:
            throw new Error("confirm button not found")
          case 8:
            expect(apiSendSpy).toBeCalled()
            expect(react_1.screen.queryByText("Success!!!")).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("handles errors from deleting a disruption", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var startDate,
        endDate,
        _a,
        container,
        findByText,
        deleteButton,
        apiSendSpy,
        confirmButton
      return __generator(this, function (_b) {
        switch (_b.label) {
          case 0:
            startDate = new Date()
            startDate.setTime(startDate.getTime() + 24 * 60 * 60 * 1000)
            startDate = new Date(startDate.toDateString())
            endDate = new Date()
            startDate.setTime(startDate.getTime() + 2 * 24 * 60 * 60 * 1000)
            endDate = new Date(endDate.toDateString())
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  readyRevision: new disruptionRevision_1.default({
                    id: "1",
                    disruptionId: "1",
                    startDate: startDate,
                    endDate: endDate,
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
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [
                    new disruptionRevision_1.default({
                      id: "1",
                      disruptionId: "1",
                      startDate: startDate,
                      endDate: endDate,
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
                      exceptions: [],
                      tripShortNames: [],
                    }),
                  ],
                })
              )
            })
            ;(_a = react_1.render(
              React.createElement(
                react_router_dom_2.MemoryRouter,
                { initialEntries: ["/disruptions/1?v=ready"] },
                React.createElement(
                  react_router_dom_2.Switch,
                  null,
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/disruptions/:id/",
                    component: viewDisruption_1.default,
                  })
                )
              )
            )),
              (container = _a.container),
              (findByText = _a.findByText)
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _b.sent()
            deleteButton = container.querySelector("#delete-disruption-button")
            apiSendSpy = jest
              .spyOn(api, "apiSend")
              .mockImplementationOnce(function () {
                return Promise.resolve({
                  error: ["Test error"],
                })
              })
            if (!deleteButton) return [3 /*break*/, 3]
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_1.fireEvent.click(deleteButton)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 2:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [3 /*break*/, 4]
          case 3:
            throw new Error("delete button not found")
          case 4:
            return [4 /*yield*/, findByText("mark for deletion")]
          case 5:
            confirmButton = _b.sent()
            if (!confirmButton) return [3 /*break*/, 7]
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
          case 6:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [3 /*break*/, 8]
          case 7:
            throw new Error("confirm button not found")
          case 8:
            expect(apiSendSpy).toBeCalled()
            expect(react_1.screen.getByText("Test error")).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("can toggle between views", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var startDate,
        endDate,
        spy,
        container,
        publishedButton,
        readyButton,
        draftButton
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            startDate = new Date()
            startDate.setTime(startDate.getTime() + 24 * 60 * 60 * 1000)
            startDate = new Date(startDate.toDateString())
            endDate = new Date()
            startDate.setTime(startDate.getTime() + 2 * 24 * 60 * 60 * 1000)
            endDate = new Date(endDate.toDateString())
            spy = jest.spyOn(api, "apiGet").mockImplementation(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  publishedRevision: new disruptionRevision_1.default({
                    id: "1",
                    disruptionId: "1",
                    startDate: startDate,
                    endDate: endDate,
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
                        startTime: "21:45:00",
                        dayName: "friday",
                      }),
                    ],
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  readyRevision: new disruptionRevision_1.default({
                    id: "2",
                    disruptionId: "1",
                    startDate: startDate,
                    endDate: endDate,
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
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  draftRevision: new disruptionRevision_1.default({
                    id: "3",
                    disruptionId: "1",
                    startDate: startDate,
                    endDate: endDate,
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
                        startTime: "19:45:00",
                        dayName: "friday",
                      }),
                    ],
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [
                    new disruptionRevision_1.default({
                      id: "1",
                      disruptionId: "1",
                      startDate: startDate,
                      endDate: endDate,
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
                      exceptions: [],
                      tripShortNames: [],
                    }),
                    new disruptionRevision_1.default({
                      id: "2",
                      disruptionId: "1",
                      startDate: startDate,
                      endDate: endDate,
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
                          startTime: "21:00:00",
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
            container = react_1.render(
              React.createElement(
                react_router_dom_2.MemoryRouter,
                { initialEntries: ["/disruptions/1?v=ready"] },
                React.createElement(
                  react_router_dom_2.Switch,
                  null,
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/disruptions/:id/",
                    component: viewDisruption_1.default,
                  }),
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/",
                    render: function () {
                      return React.createElement("div", null, "Success!!!")
                    },
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
            expect(spy).toHaveBeenCalledWith({
              url: "/api/disruptions/1",
              parser: jsonApi_1.toModelObject,
              defaultResult: "error",
            })
            publishedButton = container.querySelector("#published")
            expect(
              publishedButton === null || publishedButton === void 0
                ? void 0
                : publishedButton.classList
            ).not.toContain("active")
            readyButton = container.querySelector("#ready")
            expect(
              readyButton === null || readyButton === void 0
                ? void 0
                : readyButton.classList
            ).toContain("active")
            draftButton = container.querySelector("#draft")
            expect(
              draftButton === null || draftButton === void 0
                ? void 0
                : draftButton.classList
            ).not.toContain("active")
            expect(container.querySelector("#edit-disruption-link")).toBeNull()
            expect(
              container.querySelector("#delete-disruption-button")
            ).not.toBeNull()
            expect(container.textContent).toContain("8:45PM")
            if (!draftButton) return [3 /*break*/, 3]
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_1.fireEvent.click(draftButton)
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
            throw new Error("draft button not found")
          case 4:
            expect(
              publishedButton === null || publishedButton === void 0
                ? void 0
                : publishedButton.classList
            ).not.toContain("active")
            expect(
              readyButton === null || readyButton === void 0
                ? void 0
                : readyButton.classList
            ).not.toContain("active")
            expect(
              draftButton === null || draftButton === void 0
                ? void 0
                : draftButton.classList
            ).toContain("active")
            expect(
              container.querySelector("#edit-disruption-link")
            ).not.toBeNull()
            expect(
              container.querySelector("#delete-disruption-button")
            ).not.toBeNull()
            expect(container.textContent).toContain("7:45PM")
            if (!publishedButton) return [3 /*break*/, 6]
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_1.fireEvent.click(publishedButton)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 5:
            // eslint-disable-next-line @typescript-eslint/require-await
            _a.sent()
            return [3 /*break*/, 7]
          case 6:
            throw new Error("published button not found")
          case 7:
            expect(
              publishedButton === null || publishedButton === void 0
                ? void 0
                : publishedButton.classList
            ).toContain("active")
            expect(
              readyButton === null || readyButton === void 0
                ? void 0
                : readyButton.classList
            ).not.toContain("active")
            expect(
              draftButton === null || draftButton === void 0
                ? void 0
                : draftButton.classList
            ).not.toContain("active")
            expect(container.querySelector("#edit-disruption-link")).toBeNull()
            expect(
              container.querySelector("#delete-disruption-button")
            ).not.toBeNull()
            expect(container.textContent).toContain("9:45PM")
            return [2 /*return*/]
        }
      })
    })
  })
  test("can mark active draft revision as ready", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var mockHistoryReplace,
        startDate,
        endDate,
        spy,
        _a,
        container,
        findByText,
        apiSendSpy,
        readyButton,
        confirmButton
      return __generator(this, function (_b) {
        switch (_b.label) {
          case 0:
            mockHistoryReplace = jest.fn()
            jest.mock("react-router-dom", function () {
              return {
                useHistory: function () {
                  return {
                    replace: mockHistoryReplace,
                  }
                },
              }
            })
            startDate = new Date()
            startDate.setTime(startDate.getTime() + 24 * 60 * 60 * 1000)
            startDate = new Date(startDate.toDateString())
            endDate = new Date()
            startDate.setTime(startDate.getTime() + 2 * 24 * 60 * 60 * 1000)
            endDate = new Date(endDate.toDateString())
            spy = jest.spyOn(api, "apiGet").mockImplementation(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  draftRevision: new disruptionRevision_1.default({
                    id: "3",
                    disruptionId: "1",
                    startDate: startDate,
                    endDate: endDate,
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
                        startTime: "19:45:00",
                        dayName: "friday",
                      }),
                    ],
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [],
                })
              )
            })
            ;(_a = react_1.render(
              React.createElement(
                react_router_dom_2.MemoryRouter,
                { initialEntries: ["/disruptions/1?v=draft"] },
                React.createElement(
                  react_router_dom_2.Switch,
                  null,
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/disruptions/:id/",
                    component: viewDisruption_1.default,
                  }),
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/",
                    render: function () {
                      return React.createElement("div", null, "Success!!!")
                    },
                  })
                )
              )
            )),
              (container = _a.container),
              (findByText = _a.findByText)
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _b.sent()
            expect(spy).toHaveBeenCalledWith({
              url: "/api/disruptions/1",
              parser: jsonApi_1.toModelObject,
              defaultResult: "error",
            })
            apiSendSpy = jest
              .spyOn(api, "apiSend")
              .mockImplementationOnce(function () {
                return Promise.resolve({
                  ok: null,
                })
              })
            readyButton = container.querySelector("#mark-ready")
            if (!readyButton) {
              throw new Error("mark as ready button not found")
            }
            expect(readyButton.textContent).toEqual("mark as ready")
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                    react_1.fireEvent.click(readyButton)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 2:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [4 /*yield*/, findByText("yes, mark as ready")]
          case 3:
            confirmButton = _b.sent()
            if (!confirmButton) return [3 /*break*/, 5]
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
          case 4:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [3 /*break*/, 6]
          case 5:
            throw new Error("confirm button not found")
          case 6:
            expect(apiSendSpy).toBeCalledWith({
              url: "/api/ready_notice/",
              method: "POST",
              json: JSON.stringify({ revision_ids: "3" }),
            })
            expect(spy).toBeCalledTimes(2)
            return [2 /*return*/]
        }
      })
    })
  })
  test("can mark deleted draft revision as ready", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var startDate,
        endDate,
        spy,
        _a,
        container,
        findByText,
        apiSendSpy,
        readyButton,
        confirmButton
      return __generator(this, function (_b) {
        switch (_b.label) {
          case 0:
            startDate = new Date()
            startDate.setTime(startDate.getTime() + 24 * 60 * 60 * 1000)
            startDate = new Date(startDate.toDateString())
            endDate = new Date()
            startDate.setTime(startDate.getTime() + 2 * 24 * 60 * 60 * 1000)
            endDate = new Date(endDate.toDateString())
            spy = jest.spyOn(api, "apiGet").mockImplementation(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  draftRevision: new disruptionRevision_1.default({
                    id: "3",
                    disruptionId: "1",
                    startDate: startDate,
                    endDate: endDate,
                    isActive: false,
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
                        startTime: "19:45:00",
                        dayName: "friday",
                      }),
                    ],
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [],
                })
              )
            })
            ;(_a = react_1.render(
              React.createElement(
                react_router_dom_2.MemoryRouter,
                { initialEntries: ["/disruptions/1?v=draft"] },
                React.createElement(
                  react_router_dom_2.Switch,
                  null,
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/disruptions/:id/",
                    component: viewDisruption_1.default,
                  }),
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/",
                    render: function () {
                      return React.createElement("div", null, "Success!!!")
                    },
                  })
                )
              )
            )),
              (container = _a.container),
              (findByText = _a.findByText)
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _b.sent()
            expect(spy).toHaveBeenCalledWith({
              url: "/api/disruptions/1",
              parser: jsonApi_1.toModelObject,
              defaultResult: "error",
            })
            apiSendSpy = jest
              .spyOn(api, "apiSend")
              .mockImplementationOnce(function () {
                return Promise.resolve({
                  ok: null,
                })
              })
            readyButton = container.querySelector("#mark-ready")
            if (!readyButton) {
              throw new Error("mark as ready button not found")
            }
            expect(readyButton.textContent).toEqual(
              "mark as ready for deletion"
            )
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                    react_1.fireEvent.click(readyButton)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 2:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [4 /*yield*/, findByText("yes, mark as ready")]
          case 3:
            confirmButton = _b.sent()
            if (!confirmButton) return [3 /*break*/, 5]
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
          case 4:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [3 /*break*/, 6]
          case 5:
            throw new Error("confirm button not found")
          case 6:
            expect(apiSendSpy).toBeCalledWith({
              url: "/api/ready_notice/",
              method: "POST",
              json: JSON.stringify({ revision_ids: "3" }),
            })
            expect(spy).toBeCalledTimes(2)
            return [2 /*return*/]
        }
      })
    })
  })
  test("can cancel marking ready", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var startDate,
        endDate,
        spy,
        _a,
        container,
        findByText,
        apiSendSpy,
        readyButton,
        cancel
      return __generator(this, function (_b) {
        switch (_b.label) {
          case 0:
            startDate = new Date()
            startDate.setTime(startDate.getTime() + 24 * 60 * 60 * 1000)
            startDate = new Date(startDate.toDateString())
            endDate = new Date()
            startDate.setTime(startDate.getTime() + 2 * 24 * 60 * 60 * 1000)
            endDate = new Date(endDate.toDateString())
            spy = jest.spyOn(api, "apiGet").mockImplementation(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  draftRevision: new disruptionRevision_1.default({
                    id: "3",
                    disruptionId: "1",
                    startDate: startDate,
                    endDate: endDate,
                    isActive: false,
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
                        startTime: "19:45:00",
                        dayName: "friday",
                      }),
                    ],
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [],
                })
              )
            })
            ;(_a = react_1.render(
              React.createElement(
                react_router_dom_2.MemoryRouter,
                { initialEntries: ["/disruptions/1?v=draft"] },
                React.createElement(
                  react_router_dom_2.Switch,
                  null,
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/disruptions/:id/",
                    component: viewDisruption_1.default,
                  }),
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/",
                    render: function () {
                      return React.createElement("div", null, "Success!!!")
                    },
                  })
                )
              )
            )),
              (container = _a.container),
              (findByText = _a.findByText)
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _b.sent()
            expect(spy).toHaveBeenCalledWith({
              url: "/api/disruptions/1",
              parser: jsonApi_1.toModelObject,
              defaultResult: "error",
            })
            apiSendSpy = jest.spyOn(api, "apiSend")
            readyButton = container.querySelector("#mark-ready")
            if (!readyButton) {
              throw new Error("mark as ready button not found")
            }
            expect(readyButton.textContent).toEqual(
              "mark as ready for deletion"
            )
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                    react_1.fireEvent.click(readyButton)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 2:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [4 /*yield*/, findByText("cancel")]
          case 3:
            cancel = _b.sent()
            if (!cancel) return [3 /*break*/, 5]
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    react_1.fireEvent.click(cancel)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 4:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [3 /*break*/, 6]
          case 5:
            throw new Error("cancel button not found")
          case 6:
            expect(apiSendSpy).not.toHaveBeenCalled()
            expect(spy).toBeCalledTimes(1)
            apiSendSpy.mockClear()
            return [2 /*return*/]
        }
      })
    })
  })
  test("handles error marking draft revision as ready", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var startDate,
        endDate,
        spy,
        _a,
        container,
        findByText,
        apiSendSpy,
        readyButton,
        confirmButton
      return __generator(this, function (_b) {
        switch (_b.label) {
          case 0:
            startDate = new Date()
            startDate.setTime(startDate.getTime() + 24 * 60 * 60 * 1000)
            startDate = new Date(startDate.toDateString())
            endDate = new Date()
            startDate.setTime(startDate.getTime() + 2 * 24 * 60 * 60 * 1000)
            endDate = new Date(endDate.toDateString())
            spy = jest.spyOn(api, "apiGet").mockImplementation(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  draftRevision: new disruptionRevision_1.default({
                    id: "3",
                    disruptionId: "1",
                    startDate: startDate,
                    endDate: endDate,
                    isActive: false,
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
                        startTime: "19:45:00",
                        dayName: "friday",
                      }),
                    ],
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [],
                })
              )
            })
            ;(_a = react_1.render(
              React.createElement(
                react_router_dom_2.MemoryRouter,
                { initialEntries: ["/disruptions/1?v=draft"] },
                React.createElement(
                  react_router_dom_2.Switch,
                  null,
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/disruptions/:id/",
                    component: viewDisruption_1.default,
                  }),
                  React.createElement(react_router_dom_2.Route, {
                    exact: true,
                    path: "/",
                    render: function () {
                      return React.createElement("div", null, "Success!!!")
                    },
                  })
                )
              )
            )),
              (container = _a.container),
              (findByText = _a.findByText)
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _b.sent()
            expect(spy).toHaveBeenCalledWith({
              url: "/api/disruptions/1",
              parser: jsonApi_1.toModelObject,
              defaultResult: "error",
            })
            apiSendSpy = jest
              .spyOn(api, "apiSend")
              .mockImplementationOnce(function () {
                return Promise.reject()
              })
            readyButton = container.querySelector("#mark-ready")
            if (!readyButton) {
              throw new Error("mark as ready button not found")
            }
            expect(readyButton.textContent).toEqual(
              "mark as ready for deletion"
            )
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
                    react_1.fireEvent.click(readyButton)
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 2:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [4 /*yield*/, findByText("yes, mark as ready")]
          case 3:
            confirmButton = _b.sent()
            if (!confirmButton) return [3 /*break*/, 5]
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
          case 4:
            // eslint-disable-next-line @typescript-eslint/require-await
            _b.sent()
            return [3 /*break*/, 6]
          case 5:
            throw new Error("confirm button not found")
          case 6:
            expect(apiSendSpy).toBeCalledWith({
              url: "/api/ready_notice/",
              method: "POST",
              json: JSON.stringify({ revision_ids: "3" }),
            })
            expect(spy).toBeCalledTimes(1)
            return [2 /*return*/]
        }
      })
    })
  })
  test("does not display 'create new disruption' button if any revision is deleted", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var history, container, editButton
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            jest.spyOn(api, "apiGet").mockImplementationOnce(function () {
              return Promise.resolve(
                new disruption_1.default({
                  id: "1",
                  readyRevision: new disruptionRevision_1.default({
                    id: "1",
                    disruptionId: "1",
                    startDate: new Date("2020-01-15"),
                    endDate: new Date("2020-01-30"),
                    isActive: false,
                    adjustments: [],
                    daysOfWeek: [],
                    exceptions: [],
                    tripShortNames: [],
                  }),
                  revisions: [
                    new disruptionRevision_1.default({
                      id: "1",
                      disruptionId: "1",
                      startDate: new Date("2020-01-15"),
                      endDate: new Date("2020-01-30"),
                      isActive: true,
                      adjustments: [],
                      daysOfWeek: [],
                      exceptions: [],
                      tripShortNames: [],
                    }),
                  ],
                })
              )
            })
            history = history_1.createBrowserHistory()
            history.push("/disruptions/1?v=ready")
            container = document.createElement("div")
            document.body.appendChild(container)
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    ReactDOM.render(
                      React.createElement(
                        react_router_dom_1.BrowserRouter,
                        null,
                        React.createElement(viewDisruption_1.default, {
                          match: {
                            params: { id: "1" },
                            isExact: true,
                            path: "/disruptions/1?v=ready",
                            url: "https://localhost/disruptions/1?v=ready",
                          },
                          history: history,
                          location: {
                            pathname: "/disruptions/1?v=ready",
                            search: "?v=ready",
                            state: {},
                            hash: "",
                          },
                        })
                      ),
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
            editButton = container.querySelector(
              "a[href='/disruptions/1/edit']"
            )
            expect(editButton).toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
})
