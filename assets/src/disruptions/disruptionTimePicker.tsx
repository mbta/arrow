import * as React from "react"
import Col from "react-bootstrap/Col"
import Form from "react-bootstrap/Form"
import Row from "react-bootstrap/Row"

import DatePicker from "react-datepicker"

import { indexToDayOfWeekString } from "./disruptions"

type TimeRange = [string, string]

type DayOfWeekTimeRanges = [
  TimeRange | null,
  TimeRange | null,
  TimeRange | null,
  TimeRange | null,
  TimeRange | null,
  TimeRange | null,
  TimeRange | null
]

const isEmpty = (days: DayOfWeekTimeRanges): boolean => {
  return days.filter(d => d !== null).length === 0
}

const timeOptions = (): string[] => {
  return ["10:00am", "12:00pm", "1:00pm", "11:00pm"]
}

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
        selected={fromDate}
        onChange={date => setFromDate(date)}
      />{" "}
      until <DatePicker selected={toDate} onChange={date => setToDate(date)} />
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
      newDisruptionDaysOfWeek[i] = ["TBD", "TBD"]
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
          <Form.Check
            key={day}
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
        )
      })}
    </Form.Group>
  )
}

interface DisruptionTimeRangesProps {
  disruptionDaysOfWeek: DayOfWeekTimeRanges
  setDisruptionDaysOfWeek: React.Dispatch<DayOfWeekTimeRanges>
}

const DisruptionTimeRanges = ({
  disruptionDaysOfWeek,
  setDisruptionDaysOfWeek,
}: DisruptionTimeRangesProps): JSX.Element => {
  const setTimeRange = (dow: number, idx: 0 | 1, evt: React.FormEvent) => {
    const val = (evt.target as HTMLSelectElement).value
    const newDisruptionDaysOfWeek = [
      ...disruptionDaysOfWeek,
    ] as DayOfWeekTimeRanges
    const oldTimeRange = disruptionDaysOfWeek[dow] as TimeRange
    const newTimeRange =
      oldTimeRange == null
        ? (["TBD", "TBD"] as TimeRange)
        : ([...oldTimeRange] as TimeRange)
    newTimeRange[idx] = val
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
  setTimeRange(dow: number, idx: number, evt: React.FormEvent): void
}

const DisruptionTimeRange = ({
  timeRange,
  setTimeRange,
  dayOfWeekIndex,
}: DisruptionTimeRangeProps): JSX.Element => {
  if (timeRange !== null) {
    return (
      <Form.Group>
        <div className="form-inline">
          <span className="m-disruption-times__dow_label">
            {indexToDayOfWeekString(dayOfWeekIndex)}
          </span>
          <div className="m-disruption-times__time_of_day_start">
            <Form.Control
              as="select"
              value={timeRange[0]}
              onChange={evt => setTimeRange(dayOfWeekIndex, 0, evt)}
            >
              <option value="TBD">Choose Time</option>
              <option value="Beginning of Service">Beginning of Service</option>
              {timeOptions().map(opt => (
                <option key={"0" + opt}>{opt}</option>
              ))}
            </Form.Control>
          </div>
          until
          <div className="m-disruption-times__time_of_day_end">
            <Form.Control
              as="select"
              value={timeRange[1]}
              onChange={evt => setTimeRange(dayOfWeekIndex, 1, evt)}
            >
              <option value="TBD">Choose Time</option>
              {timeOptions().map(opt => (
                <option key={"1" + opt}>{opt}</option>
              ))}
              <option value="End of Service">End of Service</option>
            </Form.Control>
          </div>
        </div>
      </Form.Group>
    )
  } else {
    return <div></div>
  }
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
              <a
                href="#"
                onClick={() => {
                  const newExceptionDates = exceptionDates
                    .slice(0, index)
                    .concat(exceptionDates.slice(index + 1))

                  setExceptionDates(newExceptionDates)
                }}
              >
                delete exception
              </a>
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
              <a href="#" onClick={() => setIsAddingDate(false)}>
                delete exception
              </a>
            </Col>
          </Row>
        </div>
      ) : (
        <Row key="date-exception-add-link">
          <a
            href="#"
            id="date-exception-add-link"
            onClick={() => setIsAddingDate(true)}
          >
            + add another exception
          </a>
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

export { DisruptionTimePicker, TimeRange, DayOfWeekTimeRanges }
