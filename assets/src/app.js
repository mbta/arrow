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
// tslint:disable-next-line
require("../css/app.scss")
require("phoenix_html")
var React = __importStar(require("react"))
var react_dom_1 = __importDefault(require("react-dom"))
var react_router_dom_1 = require("react-router-dom")
var editDisruption_1 = __importDefault(require("./disruptions/editDisruption"))
var newDisruption_1 = require("./disruptions/newDisruption")
var viewDisruption_1 = __importDefault(require("./disruptions/viewDisruption"))
var disruptionIndex_1 = require("./disruptions/disruptionIndex")
var App = function () {
  return React.createElement(
    react_router_dom_1.BrowserRouter,
    null,
    React.createElement(
      react_router_dom_1.Switch,
      null,
      React.createElement(react_router_dom_1.Route, {
        exact: true,
        path: "/",
        component: disruptionIndex_1.DisruptionIndex,
      }),
      React.createElement(react_router_dom_1.Route, {
        exact: true,
        path: "/disruptions/new",
        component: newDisruption_1.NewDisruption,
      }),
      React.createElement(react_router_dom_1.Route, {
        exact: true,
        path: "/disruptions/:id",
        component: viewDisruption_1.default,
      }),
      React.createElement(react_router_dom_1.Route, {
        exact: true,
        path: "/disruptions/:id/edit",
        component: editDisruption_1.default,
      })
    )
  )
}
react_dom_1.default.render(
  React.createElement(App, null),
  document.getElementById("app")
)
