import { render, fireEvent } from "@testing-library/react"
import * as React from "react"

import { DisruptionDateRange } from "../../src/disruptions/disruptionDateRange"

const DisruptionDateRangeWithProps = ({}): JSX.Element => {
  const [fromDate, setFromDate] = React.useState<Date | null>(null)
  const [toDate, setToDate] = React.useState<Date | null>(null)

  return (
    <DisruptionDateRange
      fromDate={fromDate}
      setFromDate={setFromDate}
      toDate={toDate}
      setToDate={setToDate}
    />
  )
}

describe("DisruptionDateRange", () => {
  test("can set the date range", () => {
    const { container } = render(<DisruptionDateRangeWithProps />)

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
      (
        container.querySelector(
          "#disruption-date-range-start"
        ) as HTMLInputElement
      ).value
    ).toEqual("01/01/2020")

    expect(
      (
        container.querySelector(
          "#disruption-date-range-end"
        ) as HTMLInputElement
      ).value
    ).toEqual("01/02/2020")
  })
})
