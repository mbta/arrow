import * as React from "react"
import Col from "react-bootstrap/Col"
import Form from "react-bootstrap/Form"
import Row from "react-bootstrap/Row"
import Checkbox from "../checkbox"

import {
  Time,
  HourOptions,
  MinuteOptions,
  PeriodOptions,
  TimeRange,
  DayOfWeekTimeRanges,
} from "./time"
import { indexToDayOfWeekString } from "./disruptions"

interface DisruptionDaysOfWeekProps {
  disruptionDaysOfWeek: DayOfWeekTimeRanges
  setDisruptionDaysOfWeek: React.Dispatch<DayOfWeekTimeRanges>
}

const DisruptionDaysOfWeek = ({
  disruptionDaysOfWeek,
  setDisruptionDaysOfWeek,
}: DisruptionDaysOfWeekProps): JSX.Element => {
  const handleClick = (i: number) => {
    const newDisruptionDaysOfWeek = [
      ...disruptionDaysOfWeek,
    ] as DayOfWeekTimeRanges
    if (disruptionDaysOfWeek[i] === null) {
      newDisruptionDaysOfWeek[i] = [null, null]
    } else {
      newDisruptionDaysOfWeek[i] = null
    }
    setDisruptionDaysOfWeek(newDisruptionDaysOfWeek)
  }

  return (
    <Form.Group>
      <div className="m-forms__sublegend">Choose day(s) of week</div>
      {["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((day, i) => {
        return (
          <span key={day} className="m-forms__day-of-week-bubble">
            <Form.Check
              inline
              type="checkbox"
              id={`day-of-week-${day}`}
              label={day}
              name="day-of-week"
              checked={disruptionDaysOfWeek[i] !== null}
              onChange={() => {
                handleClick(i)
              }}
            />
          </span>
        )
      })}
    </Form.Group>
  )
}

const DEFAULT_TIME: Time = {
  hour: "12",
  minute: "00",
  period: "AM",
}

interface DisruptionTimeRangesProps {
  disruptionDaysOfWeek: DayOfWeekTimeRanges
  setDisruptionDaysOfWeek: React.Dispatch<DayOfWeekTimeRanges>
}

const DisruptionTimeRanges = ({
  disruptionDaysOfWeek,
  setDisruptionDaysOfWeek,
}: DisruptionTimeRangesProps): JSX.Element => {
  const setTimeRange = (dow: number, idx: 0 | 1, val: Partial<Time> | null) => {
    const newDisruptionDaysOfWeek = [
      ...disruptionDaysOfWeek,
    ] as DayOfWeekTimeRanges
    const oldTimeRange = disruptionDaysOfWeek[dow] as TimeRange
    const newTimeRange = [...oldTimeRange] as TimeRange
    const oldTime = oldTimeRange[idx] || DEFAULT_TIME
    const newTime = val && { ...oldTime, ...val }
    newTimeRange[idx] = newTime
    newDisruptionDaysOfWeek[dow] = newTimeRange
    setDisruptionDaysOfWeek(newDisruptionDaysOfWeek)
  }

  return (
    <div>
      {disruptionDaysOfWeek.map((timeRange, index) => {
        return (
          <DisruptionTimeRange
            key={index}
            timeRange={timeRange}
            setTimeRange={setTimeRange}
            dayOfWeekIndex={index}
          />
        )
      })}
    </div>
  )
}

interface DisruptionTimeRangeProps {
  dayOfWeekIndex: number
  timeRange: TimeRange | null
  setTimeRange(dow: number, idx: number, val: Partial<Time> | null): void
}

const DisruptionTimeRange = ({
  timeRange,
  setTimeRange,
  dayOfWeekIndex,
}: DisruptionTimeRangeProps): JSX.Element => {
  if (timeRange !== null) {
    return (
      <Form.Group>
        <strong>{indexToDayOfWeekString(dayOfWeekIndex)}</strong>
        <Row>
          <Col xs={5}>
            <div className="m-disruption-times__time_of_day_start">
              <TimeOfDaySelector
                dayOfWeekIndex={dayOfWeekIndex}
                timeIndex={0}
                setTimeRange={setTimeRange}
                time={timeRange[0]}
              />
            </div>
          </Col>
          until
          <Col xs={5}>
            <div className="m-disruption-times__time_of_day_end">
              <TimeOfDaySelector
                dayOfWeekIndex={dayOfWeekIndex}
                timeIndex={1}
                setTimeRange={setTimeRange}
                time={timeRange[1]}
              />
            </div>
          </Col>
        </Row>
      </Form.Group>
    )
  } else {
    return <div></div>
  }
}

interface TimeOfDaySelectorProps {
  dayOfWeekIndex: number
  timeIndex: 0 | 1
  time: Time | null
  setTimeRange: (dow: number, idx: number, val: Partial<Time> | null) => void
}

const TimeOfDaySelector = ({
  dayOfWeekIndex,
  timeIndex,
  time,
  setTimeRange,
}: TimeOfDaySelectorProps) => {
  const handleChangeTime = (val: Partial<Time> | null) => {
    setTimeRange(dayOfWeekIndex, timeIndex, val)
  }

  const startOrEnd = timeIndex === 0 ? "start" : "end"

  return (
    <div>
      <div className="form-inline align-items-start">
        <Form.Control
          as="select"
          id={`time-of-day-${startOrEnd}-hour-${dayOfWeekIndex}`}
          value={time?.hour || ""}
          disabled={!time}
          onChange={(e: React.ChangeEvent<HTMLSelectElement>) => {
            handleChangeTime({
              hour: e.target.value as HourOptions,
            })
          }}
        >
          <option value="" disabled>
            &mdash;
          </option>
          {["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"].map(
            (hour) => {
              return (
                <option
                  key={`${hour}-${dayOfWeekIndex}-${timeIndex}`}
                  value={hour}
                >
                  {hour}
                </option>
              )
            }
          )}
        </Form.Control>
        <Form.Control
          className="ml-2"
          as="select"
          id={`time-of-day-${startOrEnd}-minute-${dayOfWeekIndex}`}
          value={time?.minute || ""}
          disabled={!time}
          onChange={(e: React.ChangeEvent<HTMLSelectElement>) =>
            handleChangeTime({
              minute: e.target.value as MinuteOptions,
            })
          }
        >
          <option value="" disabled>
            &mdash;
          </option>
          {["00", "15", "30", "45"].map((minute) => {
            return (
              <option
                key={`${minute}-${dayOfWeekIndex}-${timeIndex}`}
                value={minute}
              >
                {minute}
              </option>
            )
          })}
        </Form.Control>
        <Form.Control
          className="ml-2"
          as="select"
          id={`time-of-day-${startOrEnd}-period-${dayOfWeekIndex}`}
          key={`period-${dayOfWeekIndex}-${timeIndex}`}
          value={time?.period || ""}
          disabled={!time}
          onChange={(e: React.ChangeEvent<HTMLSelectElement>) =>
            handleChangeTime({
              period: e.target.value as PeriodOptions,
            })
          }
        >
          <option value="" disabled>
            &mdash;
          </option>
          {["AM", "PM"].map((period) => {
            return (
              <option
                key={`${period}-${dayOfWeekIndex}-${timeIndex}`}
                value={period}
              >
                {period}
              </option>
            )
          })}
        </Form.Control>
      </div>
      <Checkbox
        id={`time-of-day-${startOrEnd}-type-${dayOfWeekIndex}`}
        labelText={timeIndex === 0 ? "Start of service" : "End of service"}
        checked={!time}
        onChange={(e: React.ChangeEvent<HTMLInputElement>) => {
          if (e.target.checked) {
            handleChangeTime(null)
          } else {
            handleChangeTime({})
          }
        }}
      />
    </div>
  )
}

interface DisruptionTimePickerProps {
  disruptionDaysOfWeek: DayOfWeekTimeRanges
  setDisruptionDaysOfWeek: React.Dispatch<DayOfWeekTimeRanges>
}

const DisruptionTimePicker = ({
  disruptionDaysOfWeek,
  setDisruptionDaysOfWeek,
}: DisruptionTimePickerProps): JSX.Element => {
  return (
    <div>
      <DisruptionDaysOfWeek
        disruptionDaysOfWeek={disruptionDaysOfWeek}
        setDisruptionDaysOfWeek={setDisruptionDaysOfWeek}
      />
      <DisruptionTimeRanges
        disruptionDaysOfWeek={disruptionDaysOfWeek}
        setDisruptionDaysOfWeek={setDisruptionDaysOfWeek}
      />
    </div>
  )
}

export { DisruptionTimePicker, DisruptionTimeRange }
