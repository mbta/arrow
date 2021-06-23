import { render, fireEvent } from "@testing-library/react"
import * as React from "react"

import { DisruptionExceptionDates } from "../../src/disruptions/disruptionExceptionDates"

const DisruptionExceptionDatesWithProps = ({}): JSX.Element => {
  const [exceptionDates, setExceptionDates] = React.useState<Date[]>([])

  return (
    <DisruptionExceptionDates
      exceptionDates={exceptionDates}
      setExceptionDates={setExceptionDates}
    />
  )
}

describe("DisruptionExceptionDates", () => {
  test("enabling date exceptions shows a field for entering a date", () => {
    const { container } = render(<DisruptionExceptionDatesWithProps />)

    const dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    expect(
      container.querySelector("[data-date-exception-new=true]")
    ).not.toBeNull()
    expect(container.querySelector("#date-exception-add-link")).toBeNull()
  })

  test("entering one date exception allows adding another", () => {
    const { container } = render(<DisruptionExceptionDatesWithProps />)

    const dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    const newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    fireEvent.change(newDateExceptionInput, { target: { value: "01/01/2020" } })

    expect(container.querySelector("#date-exception-add-link")).not.toBeNull()

    const addExceptionLink = container.querySelector("#date-exception-add-link")
    if (!addExceptionLink) {
      throw new Error("add exception link not found")
    }
    fireEvent.click(addExceptionLink)

    expect(
      container.querySelector("[data-date-exception-new=true]")
    ).not.toBeNull()
  })

  test("can delete a not-yet-added exception date field", () => {
    const { container } = render(<DisruptionExceptionDatesWithProps />)

    const dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    const deleteExceptionButton = container.querySelector(
      "[data-date-exception-new=true] button"
    )
    if (!deleteExceptionButton) {
      throw new Error("delete exception button not found")
    }
    fireEvent.click(deleteExceptionButton)

    expect(container.querySelector("[data-date-exception-new=true]")).toBeNull()
    expect(
      (container.querySelector("#exception-add") as HTMLInputElement).checked
    ).toBe(false)
  })

  test("safely ignores leaving the new exception date input empty", () => {
    const { container } = render(<DisruptionExceptionDatesWithProps />)

    const dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    const newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    fireEvent.change(newDateExceptionInput, { target: { value: "invalid" } })
  })

  test("can delete the only exception date", () => {
    const { container } = render(<DisruptionExceptionDatesWithProps />)

    const dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    const newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    fireEvent.change(newDateExceptionInput, { target: { value: "01/01/2020" } })

    const deleteExceptionButton = container.querySelector(
      "#date-exception-row-0 button"
    )
    if (!deleteExceptionButton) {
      throw new Error("delete exception button not found")
    }
    fireEvent.click(deleteExceptionButton)

    expect(container.querySelector("#date-exception-row-0")).toBeNull()
    expect(
      (container.querySelector("#exception-add") as HTMLInputElement).checked
    ).toBe(false)
  })

  test("can edit and then delete one of several exception dates", () => {
    const { container } = render(<DisruptionExceptionDatesWithProps />)

    const dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    let newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    fireEvent.change(newDateExceptionInput, { target: { value: "01/01/2020" } })

    expect(
      (
        container.querySelector(
          "#date-exception-row-0 input"
        ) as HTMLInputElement
      ).value
    ).toEqual("01/01/2020")

    const dateException0Input = container.querySelector(
      "#date-exception-row-0 input"
    )
    if (!dateException0Input) {
      throw new Error("date exception row 0 input not found")
    }
    fireEvent.change(dateException0Input, { target: { value: "01/05/2020" } })

    expect(
      (
        container.querySelector(
          "#date-exception-row-0 input"
        ) as HTMLInputElement
      ).value
    ).toEqual("01/05/2020")

    const addDateExceptionLink = container.querySelector(
      "#date-exception-add-link"
    )
    if (!addDateExceptionLink) {
      throw new Error("add date exception link not found")
    }
    fireEvent.click(addDateExceptionLink)

    newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    fireEvent.change(newDateExceptionInput, { target: { value: "01/02/2020" } })

    const deleteExceptionButton = container.querySelector(
      "#date-exception-row-0 button"
    )
    if (!deleteExceptionButton) {
      throw new Error("delete exception button not found")
    }
    fireEvent.click(deleteExceptionButton)

    expect(container.querySelector("#date-exception-row-0")).not.toBeNull()
    expect(container.querySelector("#date-exception-row-1")).toBeNull()
    expect(
      (container.querySelector("#exception-add") as HTMLInputElement).checked
    ).toBe(true)
  })

  test("can delete an exception date by deleting the text in the input", () => {
    const { container } = render(<DisruptionExceptionDatesWithProps />)

    const dateExceptionsCheck = container.querySelector("#exception-add")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    const newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    fireEvent.change(newDateExceptionInput, { target: { value: "01/01/2020" } })

    expect(
      (
        container.querySelector(
          "#date-exception-row-0 input"
        ) as HTMLInputElement
      ).value
    ).toEqual("01/01/2020")

    const dateException0Input = container.querySelector(
      "#date-exception-row-0 input"
    )
    if (!dateException0Input) {
      throw new Error("date exception row 0 input not found")
    }
    fireEvent.change(dateException0Input, { target: { value: "" } })

    expect(container.querySelector("#date-exception-row-0")).toBeNull()
  })

  test("changing date exceptions back to 'no' clears selections", () => {
    const { container } = render(<DisruptionExceptionDatesWithProps />)

    const dateExceptionsYesCheck = container.querySelector("#exception-add")
    if (!dateExceptionsYesCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsYesCheck)

    const newDateExceptionInput = container.querySelector(
      "[data-date-exception-new=true] input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    fireEvent.change(newDateExceptionInput, { target: { value: "01/01/2020" } })

    expect(
      (
        container.querySelector(
          "#date-exception-row-0 input"
        ) as HTMLInputElement
      ).value
    ).toEqual("01/01/2020")

    const dateExceptionsNoCheck = container.querySelector("#exception-add")
    if (!dateExceptionsNoCheck) {
      throw new Error('date exception "no" checkbox not found')
    }
    fireEvent.click(dateExceptionsNoCheck)

    expect(container.querySelector("#date-exception-row-0")).toBeNull()
  })
})
