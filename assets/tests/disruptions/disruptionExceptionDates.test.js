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
var react_1 = require("@testing-library/react")
var React = __importStar(require("react"))
var disruptionExceptionDates_1 = require("../../src/disruptions/disruptionExceptionDates")
var DisruptionExceptionDatesWithProps = function (_a) {
  var _b = React.useState([]),
    exceptionDates = _b[0],
    setExceptionDates = _b[1]
  return React.createElement(
    disruptionExceptionDates_1.DisruptionExceptionDates,
    { exceptionDates: exceptionDates, setExceptionDates: setExceptionDates }
  )
}
describe("DisruptionExceptionDates", function () {
  test("enabling date exceptions shows a field for entering a date", function () {
    var container = react_1.render(
      React.createElement(DisruptionExceptionDatesWithProps, null)
    ).container
    var dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    react_1.fireEvent.click(dateExceptionsCheck)
    expect(
      container.querySelector("[data-date-exception-new=true]")
    ).not.toBeNull()
    expect(container.querySelector("#date-exception-add-link")).toBeNull()
  })
  test("entering one date exception allows adding another", function () {
    var container = react_1.render(
      React.createElement(DisruptionExceptionDatesWithProps, null)
    ).container
    var dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    react_1.fireEvent.click(dateExceptionsCheck)
    var newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    react_1.fireEvent.change(newDateExceptionInput, {
      target: { value: "01/01/2020" },
    })
    expect(container.querySelector("#date-exception-add-link")).not.toBeNull()
    var addExceptionLink = container.querySelector("#date-exception-add-link")
    if (!addExceptionLink) {
      throw new Error("add exception link not found")
    }
    react_1.fireEvent.click(addExceptionLink)
    expect(
      container.querySelector("[data-date-exception-new=true]")
    ).not.toBeNull()
  })
  test("can delete a not-yet-added exception date field", function () {
    var container = react_1.render(
      React.createElement(DisruptionExceptionDatesWithProps, null)
    ).container
    var dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    react_1.fireEvent.click(dateExceptionsCheck)
    var deleteExceptionButton = container.querySelector(
      "[data-date-exception-new=true] button"
    )
    if (!deleteExceptionButton) {
      throw new Error("delete exception button not found")
    }
    react_1.fireEvent.click(deleteExceptionButton)
    expect(container.querySelector("[data-date-exception-new=true]")).toBeNull()
    expect(container.querySelector("#exception-add").checked).toBe(false)
  })
  test("safely ignores leaving the new exception date input empty", function () {
    var container = react_1.render(
      React.createElement(DisruptionExceptionDatesWithProps, null)
    ).container
    var dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    react_1.fireEvent.click(dateExceptionsCheck)
    var newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    react_1.fireEvent.change(newDateExceptionInput, {
      target: { value: "invalid" },
    })
  })
  test("can delete the only exception date", function () {
    var container = react_1.render(
      React.createElement(DisruptionExceptionDatesWithProps, null)
    ).container
    var dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    react_1.fireEvent.click(dateExceptionsCheck)
    var newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    react_1.fireEvent.change(newDateExceptionInput, {
      target: { value: "01/01/2020" },
    })
    var deleteExceptionButton = container.querySelector(
      "#date-exception-row-0 button"
    )
    if (!deleteExceptionButton) {
      throw new Error("delete exception button not found")
    }
    react_1.fireEvent.click(deleteExceptionButton)
    expect(container.querySelector("#date-exception-row-0")).toBeNull()
    expect(container.querySelector("#exception-add").checked).toBe(false)
  })
  test("can edit and then delete one of several exception dates", function () {
    var container = react_1.render(
      React.createElement(DisruptionExceptionDatesWithProps, null)
    ).container
    var dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    react_1.fireEvent.click(dateExceptionsCheck)
    var newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    react_1.fireEvent.change(newDateExceptionInput, {
      target: { value: "01/01/2020" },
    })
    expect(
      container.querySelector("#date-exception-row-0 input").value
    ).toEqual("01/01/2020")
    var dateException0Input = container.querySelector(
      "#date-exception-row-0 input"
    )
    if (!dateException0Input) {
      throw new Error("date exception row 0 input not found")
    }
    react_1.fireEvent.change(dateException0Input, {
      target: { value: "01/05/2020" },
    })
    expect(
      container.querySelector("#date-exception-row-0 input").value
    ).toEqual("01/05/2020")
    var addDateExceptionLink = container.querySelector(
      "#date-exception-add-link"
    )
    if (!addDateExceptionLink) {
      throw new Error("add date exception link not found")
    }
    react_1.fireEvent.click(addDateExceptionLink)
    newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    react_1.fireEvent.change(newDateExceptionInput, {
      target: { value: "01/02/2020" },
    })
    var deleteExceptionButton = container.querySelector(
      "#date-exception-row-0 button"
    )
    if (!deleteExceptionButton) {
      throw new Error("delete exception button not found")
    }
    react_1.fireEvent.click(deleteExceptionButton)
    expect(container.querySelector("#date-exception-row-0")).not.toBeNull()
    expect(container.querySelector("#date-exception-row-1")).toBeNull()
    expect(container.querySelector("#exception-add").checked).toBe(true)
  })
  test("can delete an exception date by deleting the text in the input", function () {
    var container = react_1.render(
      React.createElement(DisruptionExceptionDatesWithProps, null)
    ).container
    var dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    react_1.fireEvent.click(dateExceptionsCheck)
    var newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    react_1.fireEvent.change(newDateExceptionInput, {
      target: { value: "01/01/2020" },
    })
    expect(
      container.querySelector("#date-exception-row-0 input").value
    ).toEqual("01/01/2020")
    var dateException0Input = container.querySelector(
      "#date-exception-row-0 input"
    )
    if (!dateException0Input) {
      throw new Error("date exception row 0 input not found")
    }
    react_1.fireEvent.change(dateException0Input, { target: { value: "" } })
    expect(container.querySelector("#date-exception-row-0")).toBeNull()
  })
  test("changing date exceptions back to 'no' clears selections", function () {
    var container = react_1.render(
      React.createElement(DisruptionExceptionDatesWithProps, null)
    ).container
    var dateExceptionsYesCheck = container.querySelector("#exception-add")
    if (!dateExceptionsYesCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    react_1.fireEvent.click(dateExceptionsYesCheck)
    var newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    react_1.fireEvent.change(newDateExceptionInput, {
      target: { value: "01/01/2020" },
    })
    expect(
      container.querySelector("#date-exception-row-0 input").value
    ).toEqual("01/01/2020")
    var dateExceptionsNoCheck = container.querySelector("#exception-add")
    if (!dateExceptionsNoCheck) {
      throw new Error('date exception "no" checkbox not found')
    }
    react_1.fireEvent.click(dateExceptionsNoCheck)
    expect(container.querySelector("#date-exception-row-0")).toBeNull()
  })
})
