import { render, fireEvent } from "@testing-library/react"
import * as React from "react"

import { DayOfWeekTimeRanges } from "../../src/disruptions/time"
import { DisruptionTimePicker } from "../../src/disruptions/disruptionTimePicker"

const DisruptionTimePickerWithProps = ({}): JSX.Element => {
  const [fromDate, setFromDate] = React.useState<Date | null>(null)
  const [toDate, setToDate] = React.useState<Date | null>(null)
  const [disruptionDaysOfWeek, setDisruptionDaysOfWeek] = React.useState<
    DayOfWeekTimeRanges
  >([null, null, null, null, null, null, null])
  const [exceptionDates, setExceptionDates] = React.useState<Date[]>([])

  return (
    <DisruptionTimePicker
      fromDate={fromDate}
      setFromDate={setFromDate}
      toDate={toDate}
      setToDate={setToDate}
      disruptionDaysOfWeek={disruptionDaysOfWeek}
      setDisruptionDaysOfWeek={setDisruptionDaysOfWeek}
      exceptionDates={exceptionDates}
      setExceptionDates={setExceptionDates}
    />
  )
}

describe("DisruptionTimePicker", () => {
  test("can set the date range", () => {
    const { container } = render(<DisruptionTimePickerWithProps />)

    const rangeStartInput = container.querySelector(
      "#disruption-date-range-start"
    )
    if (!rangeStartInput) {
      throw new Error("range start input not found")
    }
    fireEvent.change(rangeStartInput, { target: { value: "01/01/2020" } })
    const rangeEndInput = container.querySelector("#disruption-date-range-end")
    if (!rangeEndInput) {
      throw new Error("range end input not found")
    }
    fireEvent.change(rangeEndInput, { target: { value: "01/02/2020" } })

    expect(
      (container.querySelector(
        "#disruption-date-range-start"
      ) as HTMLInputElement).value
    ).toEqual("01/01/2020")

    expect(
      (container.querySelector(
        "#disruption-date-range-end"
      ) as HTMLInputElement).value
    ).toEqual("01/02/2020")
  })

  test("selecting a day of the week enables updating time range", () => {
    const { container } = render(<DisruptionTimePickerWithProps />)

    const mondayCheck = container.querySelector("input#day-of-week-M")
    if (!mondayCheck) {
      throw new Error("Monday checkbox not found")
    }
    fireEvent.click(mondayCheck)

    const mondayStartTypeCheck = container.querySelector(
      "input#time-of-day-start-type-0"
    )
    if (!mondayStartTypeCheck) {
      throw new Error("Monday start time type checkbox not found")
    }
    fireEvent.click(mondayStartTypeCheck)

    const mondayEndTypeCheck = container.querySelector(
      "input#time-of-day-end-type-0"
    )
    if (!mondayEndTypeCheck) {
      throw new Error("Monday end time type checkbox not found")
    }
    fireEvent.click(mondayEndTypeCheck)

    const mondayStartHourSelect = container.querySelector(
      "select#time-of-day-start-hour-0"
    )
    if (!mondayStartHourSelect) {
      throw new Error("Monday start hour select not found")
    }
    fireEvent.change(mondayStartHourSelect, { target: { value: "9" } })

    const mondayEndMinuteSelect = container.querySelector(
      "select#time-of-day-end-minute-0"
    )
    if (!mondayEndMinuteSelect) {
      throw new Error("Monday end minute select not found")
    }
    fireEvent.change(mondayEndMinuteSelect, { target: { value: "30" } })

    const mondayEndPeriodSelect = container.querySelector(
      "select#time-of-day-end-period-0"
    )
    if (!mondayEndPeriodSelect) {
      throw new Error("Monday end period select not found")
    }
    fireEvent.change(mondayEndPeriodSelect, { target: { value: "PM" } })

    fireEvent.click(mondayEndTypeCheck)

    fireEvent.click(mondayCheck)

    expect(
      container.querySelector("select#time-of-day-start-hour-0")
    ).toBeNull()
    expect(
      container.querySelector("select#time-of-day-start-minute-0")
    ).toBeNull()
    expect(
      container.querySelector("select#time-of-day-start-period-0")
    ).toBeNull()
    expect(container.querySelector("select#time-of-day-end-hour-0")).toBeNull()
    expect(
      container.querySelector("select#time-of-day-end-minute-0")
    ).toBeNull()
    expect(
      container.querySelector("select#time-of-day-end-period-0")
    ).toBeNull()
  })

  test("enabling date exceptions shows a field for entering a date", () => {
    const { container } = render(<DisruptionTimePickerWithProps />)

    const dateExceptionsCheck = container.querySelector("#date-exceptions-yes")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    expect(container.querySelector("#date-exception-new")).not.toBeNull()
    expect(container.querySelector("#date-exception-add-link")).toBeNull()
  })

  test("entering one date exception allows adding another", () => {
    const { container } = render(<DisruptionTimePickerWithProps />)

    const dateExceptionsCheck = container.querySelector("#date-exceptions-yes")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    const newDateExceptionInput = container.querySelector(
      "#date-exception-new input"
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

    expect(container.querySelector("#date-exception-new")).not.toBeNull()
  })

  test("can delete a not-yet-added exception date field", () => {
    const { container } = render(<DisruptionTimePickerWithProps />)

    const dateExceptionsCheck = container.querySelector("#date-exceptions-yes")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    const deleteExceptionButton = container.querySelector(
      "#date-exception-new button"
    )
    if (!deleteExceptionButton) {
      throw new Error("delete exception button not found")
    }
    fireEvent.click(deleteExceptionButton)

    expect(container.querySelector("#date-exception-new")).toBeNull()
    expect(
      (container.querySelector("#date-exceptions-yes") as HTMLInputElement)
        .checked
    ).toBe(false)
    expect(
      (container.querySelector("#date-exceptions-no") as HTMLInputElement)
        .checked
    ).toBe(true)
  })

  test("safely ignores leaving the new exception date input empty", () => {
    const { container } = render(<DisruptionTimePickerWithProps />)

    const dateExceptionsCheck = container.querySelector("#date-exceptions-yes")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    const newDateExceptionInput = container.querySelector(
      "#date-exception-new input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    fireEvent.change(newDateExceptionInput, { target: { value: "invalid" } })
  })

  test("can delete the only exception date", () => {
    const { container } = render(<DisruptionTimePickerWithProps />)

    const dateExceptionsCheck = container.querySelector("#date-exceptions-yes")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    const newDateExceptionInput = container.querySelector(
      "#date-exception-new input"
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
      (container.querySelector("#date-exceptions-yes") as HTMLInputElement)
        .checked
    ).toBe(false)
    expect(
      (container.querySelector("#date-exceptions-no") as HTMLInputElement)
        .checked
    ).toBe(true)
  })

  test("can edit and then delete one of several exception dates", () => {
    const { container } = render(<DisruptionTimePickerWithProps />)

    const dateExceptionsCheck = container.querySelector("#date-exceptions-yes")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    let newDateExceptionInput = container.querySelector(
      "#date-exception-new input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    fireEvent.change(newDateExceptionInput, { target: { value: "01/01/2020" } })

    expect(
      (container.querySelector(
        "#date-exception-row-0 input"
      ) as HTMLInputElement).value
    ).toEqual("01/01/2020")

    const dateException0Input = container.querySelector(
      "#date-exception-row-0 input"
    )
    if (!dateException0Input) {
      throw new Error("date exception row 0 input not found")
    }
    fireEvent.change(dateException0Input, { target: { value: "01/05/2020" } })

    expect(
      (container.querySelector(
        "#date-exception-row-0 input"
      ) as HTMLInputElement).value
    ).toEqual("01/05/2020")

    const addDateExceptionLink = container.querySelector(
      "#date-exception-add-link"
    )
    if (!addDateExceptionLink) {
      throw new Error("add date exception link not found")
    }
    fireEvent.click(addDateExceptionLink)

    newDateExceptionInput = container.querySelector("#date-exception-new input")
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
      (container.querySelector("#date-exceptions-yes") as HTMLInputElement)
        .checked
    ).toBe(true)
    expect(
      (container.querySelector("#date-exceptions-no") as HTMLInputElement)
        .checked
    ).toBe(false)
  })

  test("can delete an exception date by deleting the text in the input", () => {
    const { container } = render(<DisruptionTimePickerWithProps />)

    const dateExceptionsCheck = container.querySelector("#date-exceptions-yes")
    if (!dateExceptionsCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsCheck)

    const newDateExceptionInput = container.querySelector(
      "#date-exception-new input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    fireEvent.change(newDateExceptionInput, { target: { value: "01/01/2020" } })

    expect(
      (container.querySelector(
        "#date-exception-row-0 input"
      ) as HTMLInputElement).value
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
    const { container } = render(<DisruptionTimePickerWithProps />)

    const dateExceptionsYesCheck = container.querySelector(
      "#date-exceptions-yes"
    )
    if (!dateExceptionsYesCheck) {
      throw new Error('date exception "yes" checkbox not found')
    }
    fireEvent.click(dateExceptionsYesCheck)

    const newDateExceptionInput = container.querySelector(
      "#date-exception-new input"
    )
    if (!newDateExceptionInput) {
      throw new Error("new date exception input not found")
    }
    fireEvent.change(newDateExceptionInput, { target: { value: "01/01/2020" } })

    expect(
      (container.querySelector(
        "#date-exception-row-0 input"
      ) as HTMLInputElement).value
    ).toEqual("01/01/2020")

    const dateExceptionsNoCheck = container.querySelector("#date-exceptions-no")
    if (!dateExceptionsNoCheck) {
      throw new Error('date exception "no" checkbox not found')
    }
    fireEvent.click(dateExceptionsNoCheck)

    expect(container.querySelector("#date-exception-row-0")).toBeNull()
  })
})
