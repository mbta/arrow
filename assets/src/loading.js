"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var react_1 = __importDefault(require("react"))
var Loading = function () {
  return react_1.default.createElement(
    "div",
    { id: "loading-indicator" },
    "Loading\u2026"
  )
}
exports.default = Loading
