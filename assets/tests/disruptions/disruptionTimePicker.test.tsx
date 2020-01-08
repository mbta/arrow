import { mount } from "enzyme"
import * as React from "react"

import {
  DayOfWeekTimeRanges,
  DisruptionTimePicker,
} from "../../src/disruptions/disruptionTimePicker"

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
  test("selecting a day of the week updates props", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper
      .find("#day-of-week-M")
      .find("input")
      .simulate("change")

    expect(
      wrapper.find(DisruptionTimePicker).props().disruptionDaysOfWeek
    ).toStrictEqual([["TBD", "TBD"], null, null, null, null, null, null])
  })

  test("enabling date exceptions shows a field for entering a date", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper
      .find("#date-exceptions-yes")
      .find("input")
      .simulate("change")

    expect(wrapper.exists("#date-exception-new")).toBe(true)
    expect(wrapper.exists("#date-exception-add-link")).toBe(false)
  })

  test("entering one date exception allows adding another", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper
      .find("#date-exceptions-yes")
      .find("input")
      .simulate("change")

    wrapper
      .find("#date-exception-new")
      .find("input")
      .simulate("change", { target: { value: "01/01/2020" } })

    expect(wrapper.exists("#date-exception-add-link")).toBe(true)

    wrapper.find("#date-exception-add-link").simulate("click")

    expect(wrapper.exists("#date-exception-new")).toBe(true)
  })

  test("can delete a not-yet-added exception date field", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper
      .find("#date-exceptions-yes")
      .find("input")
      .simulate("change")

    wrapper
      .find("#date-exception-new")
      .find("a")
      .simulate("click")

    expect(wrapper.exists("#date-exception-new")).toBe(false)
    expect(
      wrapper
        .find("#date-exceptions-yes")
        .find("input")
        .props().checked
    ).toBe(false)
    expect(
      wrapper
        .find("#date-exceptions-no")
        .find("input")
        .props().checked
    ).toBe(true)
  })

  test("can delete the only exception date", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper
      .find("#date-exceptions-yes")
      .find("input")
      .simulate("change")

    wrapper
      .find("#date-exception-new")
      .find("input")
      .simulate("change", { target: { value: "01/01/2020" } })

    wrapper
      .find("#date-exception-row-0")
      .find("a")
      .simulate("click")

    expect(wrapper.exists("#date-exception-row-0")).toBe(false)
    expect(
      wrapper
        .find("#date-exceptions-yes")
        .find("input")
        .props().checked
    ).toBe(false)
    expect(
      wrapper
        .find("#date-exceptions-no")
        .find("input")
        .props().checked
    ).toBe(true)
  })

  test("can delete one of several exception dates", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper
      .find("#date-exceptions-yes")
      .find("input")
      .simulate("change")

    wrapper
      .find("#date-exception-new")
      .find("input")
      .simulate("change", { target: { value: "01/01/2020" } })

    wrapper.find("#date-exception-add-link").simulate("click")

    wrapper
      .find("#date-exception-new")
      .find("input")
      .simulate("change", { target: { value: "01/02/2020" } })

    wrapper
      .find("#date-exception-row-0")
      .find("a")
      .simulate("click")

    expect(wrapper.exists("#date-exception-row-0")).toBe(true)
    expect(wrapper.exists("#date-exception-row-1")).toBe(false)
    expect(
      wrapper
        .find("#date-exceptions-yes")
        .find("input")
        .props().checked
    ).toBe(true)
    expect(
      wrapper
        .find("#date-exceptions-no")
        .find("input")
        .props().checked
    ).toBe(false)
  })
})
