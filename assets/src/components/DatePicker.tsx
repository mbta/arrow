import React, { useState } from "react"
import ReactDatePicker, { ReactDatePickerProps } from "react-datepicker"

/* Convert a local `Date` to an ISO date string */
const encodeDate = (date: Date | null): string | null => {
  if (!date) return null

  const month = `0${date.getMonth() + 1}`.slice(-2)
  const day = `0${date.getDate()}`.slice(-2)
  return `${date.getFullYear()}-${month}-${day}`
}

/* Convert an ISO date string to a local `Date` */
const parseDate = (date: string | null): Date | null => {
  if (!date) return null
  return new Date(`${date}T00:00:00`)
}

type Omitted = "excludeDates" | "onChange" | "selected"
interface DatePickerProps extends Omit<ReactDatePickerProps, Omitted> {
  excludeDates?: string[]
  onChange?: (value: string | null) => void
  selected?: string | null
}

/**
 * Wrapper for `ReactDatePicker`, with some changes:
 *
 * - Accepts and exposes the selected value as an ISO date string.
 *
 * - The `name` prop, instead of being the name of the date input, is the name
 *   of a hidden input whose value is the selected date as an ISO string.
 *
 * - The `onChange` prop is optional: if omitted, the `selected` prop is taken
 *   as an initial value only, and the input is "uncontrolled".
 */

const DatePicker = ({
  excludeDates,
  name,
  onChange,
  selected,
  ...props
}: DatePickerProps): JSX.Element => {
  const externalSelected = selected ? parseDate(selected) : null
  const [internalSelected, setInternalSelected] = useState(externalSelected)
  const inputValue = encodeDate(onChange ? externalSelected : internalSelected)

  return (
    <div className="m-datepicker__container">
      <ReactDatePicker
        autoComplete="off"
        className="m-datepicker__react"
        excludeDates={
          excludeDates ? (excludeDates.map(parseDate) as Date[]) : []
        }
        onChange={(date) => {
          if (onChange) {
            onChange(encodeDate(date as Date | null))
          } else {
            setInternalSelected(date as Date | null)
          }
        }}
        placeholderText="__ / __ / ____"
        selected={onChange ? externalSelected : internalSelected}
        {...props}
      />
      <div className="m-datepicker__icon">&#x2b12;</div>
      <input type="hidden" name={name} value={inputValue || ""} />
    </div>
  )
}

export default DatePicker
export { encodeDate, parseDate }
