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
exports.AdjustmentSummary = void 0
var React = __importStar(require("react"))
var icons_1 = __importDefault(require("../icons"))
var disruptionIndex_1 = require("./disruptionIndex")
var AdjustmentSummary = function (_a) {
  var adjustments = _a.adjustments
  return React.createElement(
    "div",
    { className: "m-disruption-details__adjustments" },
    React.createElement(
      "ul",
      { className: "m-disruption-details__adjustment-list" },
      adjustments.map(function (adj) {
        return React.createElement(
          "li",
          { key: adj.id, className: "m-disruption-details__adjustment-item" },
          React.createElement(icons_1.default, {
            className: "mr-3",
            type: disruptionIndex_1.getRouteIcon(adj.routeId),
            size: "sm",
          }),
          adj.sourceLabel
        )
      })
    )
  )
}
exports.AdjustmentSummary = AdjustmentSummary
