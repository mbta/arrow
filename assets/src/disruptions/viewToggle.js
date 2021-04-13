"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
exports.useDisruptionViewParam = void 0
var react_router_dom_1 = require("react-router-dom")
var query_string_1 = __importDefault(require("query-string"))
var disruption_1 = require("../models/disruption")
var useDisruptionViewParam = function () {
  var v = query_string_1.default.parse(
    react_router_dom_1.useHistory().location.search
  ).v
  switch (v) {
    case "draft": {
      return disruption_1.DisruptionView.Draft
    }
    case "ready": {
      return disruption_1.DisruptionView.Ready
    }
    default: {
      return disruption_1.DisruptionView.Published
    }
  }
}
exports.useDisruptionViewParam = useDisruptionViewParam
