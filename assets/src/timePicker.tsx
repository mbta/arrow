import React, { useState } from "react"
import Checkbox from "./checkbox"

const hours = ["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]
const minutes = ["00", "15", "30", "45"]
const meridiems = ["AM", "PM"]

type Time = { hour: string; minute: string; meridiem: string }

/* Convert a `Time` object to an ISO time string */
const encodeTime = (time: Time | null): string | null => {
  if (!time) return null

  let { hour } = time
  const { minute, meridiem } = time

  if (hour === "12" && meridiem === "AM") {
    hour = "00"
  } else if (hour !== "12" && meridiem === "PM") {
    hour = (parseInt(hour, 10) + 12).toString()
  } else if (parseInt(hour, 10) < 10) {
    hour = `0${hour}`
  }

  return `${hour}:${minute}:00`
}

/* Convert an ISO time string to a `Time` object */
const parseTime = (time: string | null): Time | null => {
  if (!time) return null

  const [hourPart, minutePart] = time.split(":")
  let hour = parseInt(hourPart, 10)
  let meridiem = "AM"

  if (hour === 0) {
    hour = 12
  } else if (hour === 12) {
    meridiem = "PM"
  } else if (hour > 12) {
    hour -= 12
    meridiem = "PM"
  }

  return { hour: hour.toString(), minute: minutePart, meridiem }
}

interface TimePickerProps {
  id: string
  name: string
  initialValue: string | null
  ariaLabel: string
  nullLabel: string
}

/**
 * Uncontrolled 12-hour time picker with selects for hours, minutes, and AM/PM,
 * plus a checkbox that blanks and disables the selects.
 *
 * Accepts an `initialValue` in ISO time format, and renders a hidden input with
 * the given `name` whose value is the selected time in ISO format.
 */

const TimePicker = ({
  id,
  name,
  initialValue,
  ariaLabel,
  nullLabel,
}: TimePickerProps) => {
  const [time, setTime] = useState<Time | null>(parseTime(initialValue))

  return (
    <div>
      <input type="hidden" name={name} value={encodeTime(time) || ""} />

      <div className="form-inline align-items-start">
        <select
          aria-label={`${ariaLabel} hour`}
          className="form-control"
          value={time?.hour || ""}
          disabled={!time}
          onChange={(event) => {
            if (time) setTime({ ...time, hour: event.target.value })
          }}
        >
          <option value="" disabled>
            &mdash;
          </option>
          {hours.map((hour) => (
            <option key={hour} value={hour}>
              {hour}
            </option>
          ))}
        </select>

        <select
          aria-label={`${ariaLabel} minute`}
          className="form-control ml-2"
          value={time?.minute || ""}
          disabled={!time}
          onChange={(event) => {
            if (time) setTime({ ...time, minute: event.target.value })
          }}
        >
          <option value="" disabled>
            &mdash;
          </option>
          {minutes.map((minute) => (
            <option key={minute} value={minute}>
              {minute}
            </option>
          ))}
        </select>

        <select
          aria-label={`${ariaLabel} meridiem`}
          className="form-control ml-2"
          value={time?.meridiem || ""}
          disabled={!time}
          onChange={(event) => {
            if (time) setTime({ ...time, meridiem: event.target.value })
          }}
        >
          <option value="" disabled>
            &mdash;
          </option>
          {meridiems.map((meridiem) => (
            <option key={meridiem} value={meridiem}>
              {meridiem}
            </option>
          ))}
        </select>
      </div>

      <Checkbox
        id={id}
        checked={!time}
        labelClassName="form-check-label"
        labelText={nullLabel}
        onChange={(event) => {
          if (event.target.checked) {
            setTime(null)
          } else {
            setTime({ hour: "12", minute: "00", meridiem: "AM" })
          }
        }}
      />
    </div>
  )
}

export default TimePicker
export { encodeTime, parseTime }
