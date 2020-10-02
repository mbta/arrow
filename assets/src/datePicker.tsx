import * as React from "react"
import ReactDatePicker, { ReactDatePickerProps } from "react-datepicker"

const DatePicker = ({
  selected,
  ...rest
}: ReactDatePickerProps): JSX.Element => {
  return (
    <div className="m-datepicker__container">
      <ReactDatePicker
        className="m-datepicker__react"
        placeholderText="__ / __ / ____"
        selected={
          selected &&
          new Date(
            selected.getUTCFullYear(),
            selected.getUTCMonth(),
            selected.getUTCDate()
          )
        }
        {...rest}
      />
      <div className="m-datepicker__icon">&#x2b12;</div>
    </div>
  )
}

export default DatePicker
