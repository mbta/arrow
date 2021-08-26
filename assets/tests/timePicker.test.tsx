import React from "react"
import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import TimePicker, { encodeTime, parseTime } from "../src/timePicker"
import { hiddenInputValue } from "./testHelpers"

describe("TimePicker", () => {
  test("allows selecting a time", () => {
    render(
      <TimePicker
        id="test"
        name="test_name"
        initialValue={null}
        ariaLabel="time"
        nullLabel="No time"
      />
    )

    userEvent.click(screen.getByLabelText("No time"))
    userEvent.selectOptions(screen.getByLabelText("time hour"), "3")
    userEvent.selectOptions(screen.getByLabelText("time minute"), "45")
    userEvent.selectOptions(screen.getByLabelText("time meridiem"), "PM")

    expect(hiddenInputValue("test_name")).toEqual("15:45:00")
  })

  test("allows selecting no time", () => {
    render(
      <TimePicker
        id="test"
        name="test_name"
        initialValue="12:00:00"
        ariaLabel="time"
        nullLabel="No time"
      />
    )

    userEvent.click(screen.getByLabelText("No time"))

    expect(hiddenInputValue("test_name")).toEqual("")
  })

  test("presets the inputs for an initial value", () => {
    render(
      <TimePicker
        id="test"
        name="test_name"
        initialValue="04:30:00"
        ariaLabel="time"
        nullLabel="No time"
      />
    )

    expect(screen.getByLabelText("No time")).not.toBeChecked()
    expect(screen.getByLabelText("time hour")).toHaveValue("4")
    expect(screen.getByLabelText("time minute")).toHaveValue("30")
    expect(screen.getByLabelText("time meridiem")).toHaveValue("AM")
    expect(hiddenInputValue("test_name")).toEqual("04:30:00")
  })

  test("presets the inputs for a null initial value", () => {
    render(
      <TimePicker
        id="test"
        name="test_name"
        initialValue={null}
        ariaLabel="time"
        nullLabel="No time"
      />
    )

    expect(screen.getByLabelText("No time")).toBeChecked()
    expect(screen.getByLabelText("time hour")).toBeDisabled()
    expect(screen.getByLabelText("time minute")).toBeDisabled()
    expect(screen.getByLabelText("time meridiem")).toBeDisabled()
    expect(hiddenInputValue("test_name")).toEqual("")
  })
})

const timeTestCases = [
  { iso: "00:00:00", parts: ["12", "00", "AM"] },
  { iso: "04:30:00", parts: ["4", "30", "AM"] },
  { iso: "10:15:00", parts: ["10", "15", "AM"] },
  { iso: "12:00:00", parts: ["12", "00", "PM"] },
  { iso: "14:45:00", parts: ["2", "45", "PM"] },
  { iso: "23:30:00", parts: ["11", "30", "PM"] },
]

describe("encodeTime", () => {
  test("encodes null to null", () => {
    expect(encodeTime(null)).toBe(null)
  })

  test.each(timeTestCases)(
    "encodes $parts to $iso",
    ({ iso, parts: [hour, minute, meridiem] }) => {
      expect(encodeTime({ hour, minute, meridiem })).toEqual(iso)
    }
  )
})

describe("parseTime", () => {
  test("parses null to null", () => {
    expect(parseTime(null)).toBe(null)
  })

  test.each(timeTestCases)(
    "parses $iso to $parts",
    ({ iso, parts: [hour, minute, meridiem] }) => {
      expect(parseTime(iso)).toEqual({ hour, minute, meridiem })
    }
  )
})
