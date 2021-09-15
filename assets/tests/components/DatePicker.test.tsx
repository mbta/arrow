import React from "react"
import { render, screen } from "@testing-library/react"
import DatePicker, {
  encodeDate,
  parseDate,
} from "../../src/components/DatePicker"
import { hiddenInputValue, pickDate } from "../testHelpers"

describe("DatePicker", () => {
  test("exposes the selected date as ISO using a hidden input", () => {
    render(<DatePicker name="test_name" />)

    pickDate(screen.getByRole("textbox"), "09/17/2021")

    expect(hiddenInputValue("test_name")).toEqual("2021-09-17")
  })

  test("accepts an initial selection as an ISO date", () => {
    render(<DatePicker name="test_name" selected="2021-09-19" />)

    expect(screen.getByRole("textbox")).toHaveValue("09/19/2021")
    expect(hiddenInputValue("test_name")).toEqual("2021-09-19")
  })

  test("accepts `excludeDates` as an array of ISO dates", () => {
    render(<DatePicker name="test_name" excludeDates={["2021-09-01"]} />)

    pickDate(screen.getByRole("textbox"), "09/01/2021")

    expect(hiddenInputValue("test_name")).toEqual("")
  })

  test("is a controlled input when `onChange` is set", () => {
    const onChange = jest.fn()
    render(
      <DatePicker name="test_name" selected="2021-01-01" onChange={onChange} />
    )

    pickDate(screen.getByRole("textbox"), "09/01/2021")

    expect(onChange).toHaveBeenCalledWith("2021-09-01")
    expect(hiddenInputValue("test_name")).toEqual("2021-01-01")
  })
})

const dateTestCases = [
  { iso: "2021-01-01", date: new Date(2021, 0, 1) },
  { iso: "2021-08-24", date: new Date(2021, 7, 24) },
  { iso: "2021-10-07", date: new Date(2021, 9, 7) },
  { iso: "2021-12-31", date: new Date(2021, 11, 31) },
]

describe("encodeDate", () => {
  test("encodes null to null", () => {
    expect(encodeDate(null)).toBe(null)
  })

  test.each(dateTestCases)("encodes $date to $iso", ({ iso, date }) => {
    expect(encodeDate(date)).toEqual(iso)
  })
})

describe("parseDate", () => {
  test("parses null to null", () => {
    expect(parseDate(null)).toBe(null)
  })

  test.each(dateTestCases)("parses $iso to $date", ({ iso, date }) => {
    expect(parseDate(iso)).toEqual(date)
  })
})
