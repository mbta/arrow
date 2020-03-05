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
  test("can set the date range", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper
      .find("#disruption-date-range-start")
      .find("input")
      .simulate("change", { target: { value: "01/01/2020" } })
    wrapper
      .find("#disruption-date-range-end")
      .find("input")
      .simulate("change", { target: { value: "01/02/2020" } })

    expect(
      wrapper
        .find("#disruption-date-range-start")
        .find("input")
        .props().value
    ).toEqual("01/01/2020")

    expect(
      wrapper
        .find("#disruption-date-range-end")
        .find("input")
        .props().value
    ).toEqual("01/02/2020")
  })

  test("selecting a day of the week enables updating time range", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper.find("input#day-of-week-M").simulate("change")

    expect(
      wrapper.find(DisruptionTimePicker).props().disruptionDaysOfWeek
    ).toStrictEqual([[null, null], null, null, null, null, null, null])

    wrapper
      .find("input#time-of-day-start-type-0")
      .simulate("change", { target: { checked: false } })

    wrapper
      .find("input#time-of-day-end-type-0")
      .simulate("change", { target: { checked: false } })

    expect(
      wrapper.find(DisruptionTimePicker).props().disruptionDaysOfWeek
    ).toStrictEqual([
      [
        { hour: "12", minute: "00", period: "AM" },
        { hour: "12", minute: "00", period: "AM" },
      ],
      null,
      null,
      null,
      null,
      null,
      null,
    ])

    wrapper
      .find("select#time-of-day-start-hour-0")
      .simulate("change", { target: { value: "9" } })

    wrapper
      .find("select#time-of-day-end-minute-0")
      .simulate("change", { target: { value: "30" } })

    wrapper
      .find("select#time-of-day-end-period-0")
      .simulate("change", { target: { value: "PM" } })

    expect(
      wrapper.find(DisruptionTimePicker).props().disruptionDaysOfWeek
    ).toStrictEqual([
      [
        { hour: "9", minute: "00", period: "AM" },
        { hour: "12", minute: "30", period: "PM" },
      ],
      null,
      null,
      null,
      null,
      null,
      null,
    ])

    wrapper
      .find("input#time-of-day-end-type-0")
      .simulate("change", { target: { checked: true } })

    expect(
      wrapper.find(DisruptionTimePicker).props().disruptionDaysOfWeek
    ).toStrictEqual([
      [{ hour: "9", minute: "00", period: "AM" }, null],
      null,
      null,
      null,
      null,
      null,
      null,
    ])

    wrapper.find("input#day-of-week-M").simulate("change")

    expect(
      wrapper.find(DisruptionTimePicker).props().disruptionDaysOfWeek
    ).toStrictEqual([null, null, null, null, null, null, null])
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
      .find("button")
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

  test("safely ignores leaving the new exception date input empty", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper
      .find("#date-exceptions-yes")
      .find("input")
      .simulate("change")

    wrapper
      .find("#date-exception-new")
      .find("input")
      .simulate("change", { target: { value: "invalid" } })
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
      .find("button")
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

  test("can edit and then delete one of several exception dates", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper
      .find("#date-exceptions-yes")
      .find("input")
      .simulate("change")

    wrapper
      .find("#date-exception-new")
      .find("input")
      .simulate("change", { target: { value: "01/01/2020" } })

    expect(
      wrapper
        .find("#date-exception-row-0")
        .find("input")
        .props().value
    ).toEqual("01/01/2020")

    wrapper
      .find("#date-exception-row-0")
      .find("input")
      .simulate("change", { target: { value: "01/05/2020" } })

    expect(
      wrapper
        .find("#date-exception-row-0")
        .find("input")
        .props().value
    ).toEqual("01/05/2020")

    wrapper.find("#date-exception-add-link").simulate("click")

    wrapper
      .find("#date-exception-new")
      .find("input")
      .simulate("change", { target: { value: "01/02/2020" } })

    wrapper
      .find("#date-exception-row-0")
      .find("button")
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

  test("can delete an exception date by deleting the text in the input", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper
      .find("#date-exceptions-yes")
      .find("input")
      .simulate("change")

    wrapper
      .find("#date-exception-new")
      .find("input")
      .simulate("change", { target: { value: "01/01/2020" } })

    expect(
      wrapper
        .find("#date-exception-row-0")
        .find("input")
        .props().value
    ).toEqual("01/01/2020")

    wrapper
      .find("#date-exception-row-0")
      .find("input")
      .simulate("change", { target: { value: "" } })

    expect(wrapper.exists("#date-exception-row-0")).toBe(false)
  })

  test("changing date exceptions back to 'no' clears selections", () => {
    const wrapper = mount(<DisruptionTimePickerWithProps />)

    wrapper
      .find("#date-exceptions-yes")
      .find("input")
      .simulate("change")

    wrapper
      .find("#date-exception-new")
      .find("input")
      .simulate("change", { target: { value: "01/01/2020" } })

    expect(
      wrapper
        .find("#date-exception-row-0")
        .find("input")
        .props().value
    ).toEqual("01/01/2020")

    wrapper
      .find("#date-exceptions-no")
      .find("input")
      .simulate("change")

    expect(wrapper.exists("#date-exception-row-0")).toBe(false)
  })
})
