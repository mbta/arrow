import { render, fireEvent } from "@testing-library/react"
import * as React from "react"

import { DayOfWeekTimeRanges } from "../../src/disruptions/time"
import { DisruptionTimePicker } from "../../src/disruptions/disruptionTimePicker"

const DisruptionTimePickerWithProps = ({}): JSX.Element => {
  const [disruptionDaysOfWeek, setDisruptionDaysOfWeek] =
    React.useState<DayOfWeekTimeRanges>([
      null,
      null,
      null,
      null,
      null,
      null,
      null,
    ])

  return (
    <DisruptionTimePicker
      disruptionDaysOfWeek={disruptionDaysOfWeek}
      setDisruptionDaysOfWeek={setDisruptionDaysOfWeek}
    />
  )
}

describe("DisruptionTimePicker", () => {
  test("selecting a day of the week enables updating time range", () => {
    const { container } = render(<DisruptionTimePickerWithProps />)

    const mondayCheck = container.querySelector("input#day-of-week-Mon")
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
})
