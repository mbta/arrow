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
var react_router_dom_1 = require("react-router-dom")
var test_utils_1 = require("react-dom/test-utils")
var react_1 = require("@testing-library/react")
var dom_1 = require("@testing-library/dom")
var react_select_event_1 = __importDefault(require("react-select-event"))
var api = __importStar(require("../../src/api"))
var newDisruption_1 = require("../../src/disruptions/newDisruption")
var adjustment_1 = __importDefault(require("../../src/models/adjustment"))
var withElement = function (container, selector, fn) {
  var element = container.querySelector(selector)
  if (element) {
    fn(element)
  } else {
    throw new Error("No element found for " + selector)
  }
}
describe("NewDisruption", function () {
  var apiCallSpy
  var apiSendSpy
  beforeEach(function () {
    apiCallSpy = jest.spyOn(api, "apiGet").mockImplementation(function () {
      return Promise.resolve([
        new adjustment_1.default({
          id: "1",
          routeId: "Red",
          sourceLabel: "Broadway--Kendall/MIT",
        }),
        new adjustment_1.default({
          id: "2",
          routeId: "Green-D",
          sourceLabel: "Kenmore--Newton Highlands",
        }),
        new adjustment_1.default({
          id: "3",
          routeId: "CR-Fairmount",
          sourceLabel: "Fairmount--Newmarket",
        }),
      ])
    })
  })
  afterAll(function () {
    apiCallSpy.mockRestore()
    apiSendSpy.mockRestore()
  })
  test("header include link to homepage", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(newDisruption_1.NewDisruption, null)
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
  test("selecting a mode filters the available adjustments", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container,
        commuterRailCheck,
        adjustmentSelect,
        adjustmentOptions,
        subwayCheck
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(newDisruption_1.NewDisruption, null)
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            commuterRailCheck = container.querySelector("#mode-commuter-rail")
            if (commuterRailCheck) {
              react_1.fireEvent.click(commuterRailCheck)
            } else {
              throw new Error("commuter rail check not found")
            }
            adjustmentSelect = container.querySelector("#adjustment-select")
            if (adjustmentSelect) {
              react_select_event_1.default.openMenu(adjustmentSelect)
            } else {
              throw new Error("subway check not found")
            }
            adjustmentOptions = container.querySelectorAll(
              ".adjustment-select__option"
            )
            expect(adjustmentOptions.length).toEqual(1)
            expect(adjustmentOptions.length).toBe(1)
            expect(adjustmentOptions[0].textContent).toEqual(
              "Fairmount--Newmarket"
            )
            subwayCheck = container.querySelector("#mode-subway")
            if (subwayCheck) {
              react_1.fireEvent.click(subwayCheck)
            } else {
              throw new Error("subway check not found")
            }
            react_select_event_1.default.openMenu(adjustmentSelect)
            adjustmentOptions = container.querySelectorAll(
              ".adjustment-select__option"
            )
            expect(adjustmentOptions.length).toBe(2)
            expect(adjustmentOptions[0].textContent).toEqual(
              "Broadway--Kendall/MIT"
            )
            expect(adjustmentOptions[1].textContent).toEqual(
              "Kenmore--Newton Highlands"
            )
            return [2 /*return*/]
        }
      })
    })
  })
  test("add another adjustment link not enabled by default", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, addAnotherLink
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(newDisruption_1.NewDisruption, null)
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            addAnotherLink = container.querySelector(
              "#add-another-adjustment-link"
            )
            expect(addAnotherLink).toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("ability to delete the only adjustment", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, adjustmentSelect, adjustmentDelete
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(newDisruption_1.NewDisruption, null)
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            adjustmentSelect = container.querySelector("#adjustment-select")
            if (!adjustmentSelect) return [3 /*break*/, 3]
            return [
              4 /*yield*/,
              react_select_event_1.default.select(
                adjustmentSelect,
                "Kenmore--Newton Highlands"
              ),
            ]
          case 2:
            _a.sent()
            return [3 /*break*/, 4]
          case 3:
            throw new Error("adjustment selector not found")
          case 4:
            expect(
              container.querySelectorAll(".adjustment-select__multi-value")
                .length
            ).toEqual(1)
            adjustmentDelete = container.querySelector(
              ".adjustment-select__multi-value__remove"
            )
            if (adjustmentDelete) {
              react_1.fireEvent.click(adjustmentDelete)
            } else {
              throw new Error("adjustment delete button not found")
            }
            expect(
              container.querySelectorAll(".adjustment-select__multi-value")
                .length
            ).toEqual(0)
            return [2 /*return*/]
        }
      })
    })
  })
  test("ability to delete an adjustment that isn't the only one", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, adjustmentSelect, valueElements, adjustmentDelete
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            container = react_1.render(
              React.createElement(newDisruption_1.NewDisruption, null)
            ).container
            return [
              4 /*yield*/,
              dom_1.waitForElementToBeRemoved(
                document.querySelector("#loading-indicator")
              ),
            ]
          case 1:
            _a.sent()
            adjustmentSelect = container.querySelector("#adjustment-select")
            if (!adjustmentSelect) return [3 /*break*/, 4]
            return [
              4 /*yield*/,
              react_select_event_1.default.select(
                adjustmentSelect,
                "Kenmore--Newton Highlands"
              ),
            ]
          case 2:
            _a.sent()
            return [
              4 /*yield*/,
              react_select_event_1.default.select(
                adjustmentSelect,
                "Broadway--Kendall/MIT"
              ),
            ]
          case 3:
            _a.sent()
            return [3 /*break*/, 5]
          case 4:
            throw new Error("adjustment selector not found")
          case 5:
            valueElements = container.querySelectorAll(
              ".adjustment-select__multi-value"
            )
            expect(valueElements.length).toEqual(2)
            expect(valueElements[0].textContent).toEqual(
              "Kenmore--Newton Highlands"
            )
            expect(valueElements[1].textContent).toEqual(
              "Broadway--Kendall/MIT"
            )
            adjustmentDelete = container.querySelector(
              ".adjustment-select__multi-value__remove"
            )
            if (adjustmentDelete) {
              react_1.fireEvent.click(adjustmentDelete)
            } else {
              throw new Error("adjustment delete link not found")
            }
            valueElements = container.querySelectorAll(
              ".adjustment-select__multi-value"
            )
            expect(valueElements.length).toEqual(1)
            expect(valueElements[0].textContent).toEqual(
              "Broadway--Kendall/MIT"
            )
            return [2 /*return*/]
        }
      })
    })
  })
  test("handles error fetching / parsing adjustments", function () {
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
              React.createElement(newDisruption_1.NewDisruption, null)
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
                "Error loading or parsing adjustments."
              )
            ).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
  test("can create a disruption", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      var container, apiSendCall, apiSendData
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
                { initialEntries: ["/disruptions/new"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    path: "/disruptions/new",
                    component: newDisruption_1.NewDisruption,
                  }),
                  React.createElement(react_router_dom_1.Route, {
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
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    switch (_a.label) {
                      case 0:
                        return [
                          4 /*yield*/,
                          dom_1.waitForElementToBeRemoved(
                            document.querySelector("#loading-indicator")
                          ),
                        ]
                      case 1:
                        _a.sent()
                        withElement(
                          container,
                          "#mode-commuter-rail",
                          function (el) {
                            react_1.fireEvent.click(el)
                          }
                        )
                        withElement(
                          container,
                          "#disruption-date-range-start",
                          function (el) {
                            react_1.fireEvent.change(el, {
                              target: { value: "2020-03-31" },
                            })
                          }
                        )
                        withElement(
                          container,
                          "#disruption-date-range-end",
                          function (el) {
                            react_1.fireEvent.change(el, {
                              target: { value: "2020-04-30" },
                            })
                          }
                        )
                        withElement(container, "#trips-some", function (el) {
                          react_1.fireEvent.click(el)
                        })
                        withElement(
                          container,
                          "#trip-short-names",
                          function (el) {
                            react_1.fireEvent.change(el, {
                              target: { value: "999,888" },
                            })
                          }
                        )
                        withElement(container, "#trips-all", function (el) {
                          react_1.fireEvent.click(el)
                        })
                        withElement(container, "#trips-some", function (el) {
                          react_1.fireEvent.click(el)
                        })
                        withElement(
                          container,
                          "#trip-short-names",
                          function (el) {
                            react_1.fireEvent.change(el, {
                              target: { value: "123,456" },
                            })
                          }
                        )
                        return [2 /*return*/]
                    }
                  })
                })
              }),
            ]
          case 1:
            _a.sent()
            return [
              4 /*yield*/,
              react_select_event_1.default.select(
                container.querySelector("#adjustment-select"),
                ["Fairmount--Newmarket"]
              ),
              // eslint-disable-next-line @typescript-eslint/require-await
            ]
          case 2:
            _a.sent()
            // eslint-disable-next-line @typescript-eslint/require-await
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  return __generator(this, function (_a) {
                    withElement(
                      container,
                      "#save-disruption-button",
                      function (el) {
                        react_1.fireEvent.click(el)
                      }
                    )
                    return [2 /*return*/]
                  })
                })
              }),
            ]
          case 3:
            // eslint-disable-next-line @typescript-eslint/require-await
            _a.sent()
            return [4 /*yield*/, react_1.screen.findByText("Success!!!")]
          case 4:
            _a.sent()
            apiSendCall = apiSendSpy.mock.calls[0][0]
            apiSendData = JSON.parse(apiSendCall.json)
            expect(apiSendCall.url).toEqual("/api/disruptions")
            expect(apiSendData.data.attributes.start_date).toEqual("2020-03-31")
            expect(apiSendData.data.attributes.end_date).toEqual("2020-04-30")
            expect(
              apiSendData.data.relationships.trip_short_names.data
            ).toEqual([
              {
                attributes: { trip_short_name: "123" },
                type: "trip_short_name",
              },
              {
                attributes: { trip_short_name: "456" },
                type: "trip_short_name",
              },
            ])
            expect(
              apiSendData.data.relationships.adjustments.data[0].attributes
                .source_label
            ).toEqual("Fairmount--Newmarket")
            return [2 /*return*/]
        }
      })
    })
  })
  test("handles errors with disruptions", function () {
    return __awaiter(void 0, void 0, void 0, function () {
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
            return [
              4 /*yield*/,
              test_utils_1.act(function () {
                return __awaiter(void 0, void 0, void 0, function () {
                  var container
                  return __generator(this, function (_a) {
                    switch (_a.label) {
                      case 0:
                        container = react_1.render(
                          React.createElement(
                            react_router_dom_1.MemoryRouter,
                            { initialEntries: ["/disruptions/new"] },
                            React.createElement(
                              react_router_dom_1.Switch,
                              null,
                              React.createElement(react_router_dom_1.Route, {
                                path: "/disruptions/new",
                                component: newDisruption_1.NewDisruption,
                              }),
                              React.createElement(react_router_dom_1.Route, {
                                path: "/",
                                render: function () {
                                  return React.createElement(
                                    "div",
                                    null,
                                    "Success!!!"
                                  )
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
                        withElement(
                          container,
                          "#save-disruption-button",
                          function (el) {
                            react_1.fireEvent.click(el)
                          }
                        )
                        return [2 /*return*/]
                    }
                  })
                })
              }),
            ]
          case 1:
            _a.sent()
            return [4 /*yield*/, react_1.screen.findByText("Data is all wrong")]
          case 2:
            _a.sent()
            return [2 /*return*/]
        }
      })
    })
  })
  test("canceling sends back to the home page", function () {
    return __awaiter(void 0, void 0, void 0, function () {
      return __generator(this, function (_a) {
        switch (_a.label) {
          case 0:
            react_1.render(
              React.createElement(
                react_router_dom_1.MemoryRouter,
                { initialEntries: ["/disruptions/new", "/previouspage"] },
                React.createElement(
                  react_router_dom_1.Switch,
                  null,
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/",
                    render: function () {
                      return React.createElement(
                        "div",
                        null,
                        "This is the homepage"
                      )
                    },
                  }),
                  React.createElement(react_router_dom_1.Route, {
                    exact: true,
                    path: "/disruptions/new",
                    component: newDisruption_1.NewDisruption,
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
            expect(
              react_1.screen.queryByText("This is the homepage")
            ).not.toBeNull()
            return [2 /*return*/]
        }
      })
    })
  })
})
