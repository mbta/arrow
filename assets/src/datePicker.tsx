import * as React from "react"
import ReactDatePicker, { ReactDatePickerProps } from "react-datepicker"

import { FontAwesomeIcon } from "@fortawesome/react-fontawesome"
import { faCalendar } from "@fortawesome/free-solid-svg-icons"

const DatePicker = (props: ReactDatePickerProps): JSX.Element => {
  return (
    <div className="m-datepicker__container">
      <ReactDatePicker
        className="m-datepicker__react"
        placeholderText="__ / __ / ____"
        {...props}
      />
      <div className="m-datepicker__icon">
        <FontAwesomeIcon icon={faCalendar} />
      </div>
    </div>
  )
}

export default DatePicker
