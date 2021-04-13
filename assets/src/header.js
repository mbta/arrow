"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var react_1 = __importDefault(require("react"))
var Navbar_1 = __importDefault(require("react-bootstrap/Navbar"))
var defaultProps = {
  includeHomeLink: true,
}
var Header = function (_a) {
  var includeHomeLink = _a.includeHomeLink
  return react_1.default.createElement(
    "div",
    null,
    react_1.default.createElement(
      Navbar_1.default,
      { bg: "light" },
      react_1.default.createElement(
        Navbar_1.default.Brand,
        null,
        react_1.default.createElement(
          "span",
          { className: "m-header__arrow" },
          react_1.default.createElement("img", {
            src: "/images/logo.svg",
            width: "34",
            height: "34",
          }),
          react_1.default.createElement(
            "span",
            { className: "m-header__arrow-text" },
            "ARROW"
          )
        )
      ),
      react_1.default.createElement(
        Navbar_1.default.Collapse,
        { className: "justify-content-end" },
        react_1.default.createElement(
          Navbar_1.default.Text,
          null,
          react_1.default.createElement(
            "span",
            { className: "m-header__long-name" },
            "Adjustments to the Regular Right of Way"
          )
        )
      )
    ),
    includeHomeLink &&
      react_1.default.createElement(
        "div",
        { className: "my-3" },
        react_1.default.createElement(
          "a",
          { id: "header-home-link", href: "/" },
          "< back to home"
        )
      )
  )
}
Header.defaultProps = defaultProps
exports.default = Header
