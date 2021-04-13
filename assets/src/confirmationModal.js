"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
exports.ConfirmationModal = void 0
var react_1 = __importDefault(require("react"))
var Modal_1 = __importDefault(require("react-bootstrap/Modal"))
var button_1 = require("./button")
var ConfirmationModal = function (_a) {
  var confirmationText = _a.confirmationText,
    confirmationButtonText = _a.confirmationButtonText,
    cancelButtonText = _a.cancelButtonText,
    buttonIdentifier = _a.buttonIdentifier,
    onClickConfirm = _a.onClickConfirm,
    Component = _a.Component
  var _b = react_1.default.useState(false),
    modalOpen = _b[0],
    setModalOpen = _b[1]
  return react_1.default.createElement(
    react_1.default.Fragment,
    null,
    react_1.default.createElement(
      Modal_1.default,
      { show: modalOpen, className: "m-confirmation-modal" },
      react_1.default.createElement(
        Modal_1.default.Body,
        null,
        react_1.default.createElement(
          "div",
          { className: "my-3" },
          react_1.default.createElement("strong", null, "Are you sure?")
        ),
        react_1.default.createElement("div", null, confirmationText),
        react_1.default.createElement(
          "div",
          { className: "d-flex my-3 w-100" },
          react_1.default.createElement(
            "div",
            { className: "w-50 mr-3" },
            react_1.default.createElement(
              button_1.SecondaryButton,
              {
                id: buttonIdentifier ? buttonIdentifier + "-cancel" : "cancel",
                className: "w-100",
                onClick: function () {
                  return setModalOpen(false)
                },
              },
              cancelButtonText || "cancel"
            )
          ),
          react_1.default.createElement(
            "div",
            { className: "w-50 ml-3" },
            react_1.default.createElement(
              button_1.PrimaryButton,
              {
                id: buttonIdentifier
                  ? buttonIdentifier + "-confirm"
                  : "confirm",
                className: "w-100",
                onClick: function () {
                  onClickConfirm()
                  setModalOpen(false)
                },
              },
              confirmationButtonText
            )
          )
        )
      )
    ),
    react_1.default.cloneElement(Component, {
      onClick: function () {
        return setModalOpen(true)
      },
    })
  )
}
exports.ConfirmationModal = ConfirmationModal
