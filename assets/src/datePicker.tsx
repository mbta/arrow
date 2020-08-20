import * as React from "react"
import ReactDatePicker, { ReactDatePickerProps } from "react-datepicker"

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome"
import { faCalendar } from "@fortawesome/free-solid-svg-icons"

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
      <div className="m-datepicker__icon">
        <FontAwesomeIcon icon={faCalendar} />
      </div>
    </div>
  )
}

export default DatePicker
