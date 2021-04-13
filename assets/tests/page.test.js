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
Object.defineProperty(exports, "__esModule", { value: true })
var React = __importStar(require("react"))
var react_1 = require("@testing-library/react")
var page_1 = require("../src/page")
describe("Page", function () {
  test("conditionally renders home link", function () {
    var container = react_1.render(
      React.createElement(
        page_1.Page,
        { includeHomeLink: true },
        React.createElement("div", { id: "content" }, "Your content here!!!")
      )
    ).container
    var link = container.getElementsByTagName("a")[0]
    expect(link.textContent).toContain("back to home")
    var containerWithoutLink = react_1.render(
      React.createElement(
        page_1.Page,
        { includeHomeLink: true },
        React.createElement("div", { id: "content" }, "Your content here!!!")
      )
    ).container
    link = containerWithoutLink.getElementsByTagName("a")[0]
    expect(link).not.toBeUndefined()
  })
  test("renders children", function () {
    react_1.render(
      React.createElement(
        page_1.Page,
        null,
        React.createElement("div", { id: "content" }, "Your content here!!!")
      )
    )
    expect(react_1.screen.getByText("Your content here!!!")).toBeDefined()
  })
})
