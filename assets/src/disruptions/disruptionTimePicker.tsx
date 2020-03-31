import * as React from "react"
import Col from "react-bootstrap/Col"
import Form from "react-bootstrap/Form"
import Row from "react-bootstrap/Row"

import DatePicker from "react-datepicker"

import {
  Time,
  HourOptions,
  MinuteOptions,
  PeriodOptions,
  TimeRange,
  DayOfWeekTimeRanges,
  isEmpty,
} from "./time"
import { indexToDayOfWeekString } from "./disruptions"

interface DisruptionDateRangeProps {
  fromDate: Date | null
  setFromDate: React.Dispatch<Date | null>
  toDate: Date | null
  setToDate: React.Dispatch<Date | null>
}

const DisruptionDateRange = ({
  fromDate,
  setFromDate,
  toDate,
  setToDate,
}: DisruptionDateRangeProps): JSX.Element => {
  return (
    <Form.Group>
      <div className="m-forms__sublegend">Select date range</div>
      <DatePicker
        id="disruption-date-range-start"
        selected={fromDate}
        onChange={date => setFromDate(date)}
      />
      until{" "}
      <DatePicker
        id="disruption-date-range-end"
        selected={toDate}
        onChange={date => setToDate(date)}
      />
    </Form.Group>
  )
}

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
      <div className="m-forms__sublegend">Select days of the week</div>
      {["M", "T", "W", "Th", "F", "Sa", "Su"].map((day, i) => {
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
      {isEmpty(disruptionDaysOfWeek) ? null : (
        <div className="m-forms__sublegend">Choose time of day</div>
      )}
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
        <div className="form-inline align-items-start">
          <span className="m-disruption-times__dow_label pt-2">
            {indexToDayOfWeekString(dayOfWeekIndex)}
          </span>
          <div className="m-disruption-times__time_of_day_start">
            <TimeOfDaySelector
              dayOfWeekIndex={dayOfWeekIndex}
              timeIndex={0}
              setTimeRange={setTimeRange}
              time={timeRange[0]}
            />
          </div>
          <span className="pt-2">until</span>
          <div className="m-disruption-times__time_of_day_end">
            <TimeOfDaySelector
              dayOfWeekIndex={dayOfWeekIndex}
              timeIndex={1}
              setTimeRange={setTimeRange}
              time={timeRange[1]}
            />
          </div>
        </div>
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
  setTimeRange(dow: number, idx: number, val: Partial<Time> | null): void
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
      <div>
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
            --
          </option>
          {["12", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"].map(
            hour => {
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
            --
          </option>
          {["00", "15", "30", "45"].map(minute => {
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
            --
          </option>
          {["AM", "PM"].map(period => {
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
      <Form.Check
        id={`time-of-day-${startOrEnd}-type-${dayOfWeekIndex}`}
        className="justify-content-start"
        label={timeIndex === 0 ? "start of service" : "end of service"}
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

interface DisruptionExceptionDateListProps {
  exceptionDates: Date[]
  setExceptionDates: React.Dispatch<Date[]>
  isAddingDate: boolean
  setIsAddingDate: React.Dispatch<boolean>
}

const DisruptionExceptionDateList = ({
  exceptionDates,
  setExceptionDates,
  isAddingDate,
  setIsAddingDate,
}: DisruptionExceptionDateListProps): JSX.Element => {
  return (
    <Form.Group>
      {exceptionDates.map((date, index) => (
        <div
          id={"date-exception-row-" + index}
          key={"date-exception-row-" + index}
        >
          <Row>
            <Col md="auto">
              <DatePicker
                selected={date}
                onChange={newDate => {
                  if (newDate !== null) {
                    setExceptionDates(
                      exceptionDates
                        .slice(0, index)
                        .concat([newDate])
                        .concat(exceptionDates.slice(index + 1))
                    )
                  } else {
                    setExceptionDates(
                      exceptionDates
                        .slice(0, index)
                        .concat(exceptionDates.slice(index + 1))
                    )
                  }
                }}
              />
            </Col>
            <Col md="auto">
              <button
                className="btn btn-link"
                onClick={() => {
                  const newExceptionDates = exceptionDates
                    .slice(0, index)
                    .concat(exceptionDates.slice(index + 1))

                  setExceptionDates(newExceptionDates)
                }}
              >
                delete exception
              </button>
            </Col>
          </Row>
        </div>
      ))}

      {isAddingDate ? (
        <div id="date-exception-new" key="date-exception-new">
          <Row>
            <Col md="auto">
              <DatePicker
                selected={null}
                onChange={newDate => {
                  if (newDate !== null) {
                    setExceptionDates(exceptionDates.concat([newDate]))
                    setIsAddingDate(false)
                  }
                }}
              />
            </Col>
            <Col md="auto">
              <button
                className="btn btn-link"
                onClick={() => setIsAddingDate(false)}
              >
                delete exception
              </button>
            </Col>
          </Row>
        </div>
      ) : (
        <Row key="date-exception-add-link">
          <button
            className="btn btn-link"
            id="date-exception-add-link"
            onClick={() => setIsAddingDate(true)}
          >
            + add another exception
          </button>
        </Row>
      )}
    </Form.Group>
  )
}

interface DisruptionExceptionDatesProps {
  exceptionDates: Date[]
  setExceptionDates: React.Dispatch<Date[]>
}

const DisruptionExceptionDates = ({
  exceptionDates,
  setExceptionDates,
}: DisruptionExceptionDatesProps): JSX.Element => {
  const [isAddingDate, setIsAddingDate] = React.useState<boolean>(false)

  return (
    <div>
      <Form.Group>
        <div className="m-forms__sublegend">Any date exceptions?</div>
        <Form.Check
          type="radio"
          id="date-exceptions-yes"
          label="Yes"
          name="date-exceptions-radio"
          checked={exceptionDates.length !== 0 || isAddingDate}
          onChange={() => {
            setExceptionDates([])
            setIsAddingDate(true)
          }}
        />
        <Form.Check
          type="radio"
          id="date-exceptions-no"
          label="No"
          name="date-exceptions-radio"
          checked={exceptionDates.length === 0 && !isAddingDate}
          onChange={() => {
            setExceptionDates([])
            setIsAddingDate(false)
          }}
        />
      </Form.Group>
      {exceptionDates.length !== 0 || isAddingDate ? (
        <DisruptionExceptionDateList
          exceptionDates={exceptionDates}
          setExceptionDates={setExceptionDates}
          isAddingDate={isAddingDate}
          setIsAddingDate={setIsAddingDate}
        />
      ) : null}
    </div>
  )
}

interface DisruptionTimePickerProps {
  fromDate: Date | null
  setFromDate: React.Dispatch<Date | null>
  toDate: Date | null
  setToDate: React.Dispatch<Date | null>
  disruptionDaysOfWeek: DayOfWeekTimeRanges
  setDisruptionDaysOfWeek: React.Dispatch<DayOfWeekTimeRanges>
  exceptionDates: Date[]
  setExceptionDates: React.Dispatch<Date[]>
}

const DisruptionTimePicker = ({
  fromDate,
  setFromDate,
  toDate,
  setToDate,
  disruptionDaysOfWeek,
  setDisruptionDaysOfWeek,
  exceptionDates,
  setExceptionDates,
}: DisruptionTimePickerProps): JSX.Element => {
  return (
    <div>
      <DisruptionDateRange
        fromDate={fromDate}
        setFromDate={setFromDate}
        toDate={toDate}
        setToDate={setToDate}
      />
      <DisruptionDaysOfWeek
        disruptionDaysOfWeek={disruptionDaysOfWeek}
        setDisruptionDaysOfWeek={setDisruptionDaysOfWeek}
      />
      <DisruptionTimeRanges
        disruptionDaysOfWeek={disruptionDaysOfWeek}
        setDisruptionDaysOfWeek={setDisruptionDaysOfWeek}
      />
      <DisruptionExceptionDates
        exceptionDates={exceptionDates}
        setExceptionDates={setExceptionDates}
      />
    </div>
  )
}

export { DisruptionTimePicker, DisruptionTimeRange }
