import * as React from "react"
import Form from "react-bootstrap/Form"
import Row from "react-bootstrap/Row"

import Checkbox from "../checkbox"
import DatePicker from "../datePicker"

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
  const dates = isAddingDate ? [...exceptionDates, null] : exceptionDates
  return (
    <Form.Group>
      {dates.map((date, index) => (
        <div
          id={"date-exception-row-" + index}
          key={"date-exception-row-" + index}
          data-date-exception-new={!date}
        >
          <Row className="mb-2 ml-0">
            <DatePicker
              autoComplete="off"
              selected={date}
              onChange={(newDate) => {
                if (newDate !== null && !Array.isArray(newDate)) {
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
                setIsAddingDate(false)
              }}
            />
            <button
              className="btn btn-link"
              data-testid="remove-exception-date"
              onClick={() => {
                if (date) {
                  const newExceptionDates = exceptionDates
                    .slice(0, index)
                    .concat(exceptionDates.slice(index + 1))

                  setExceptionDates(newExceptionDates)
                } else {
                  setIsAddingDate(false)
                }
              }}
            >
              &#xe161;
            </button>
          </Row>
        </div>
      ))}

      {!isAddingDate && (
        <Row key="date-exception-add-link">
          <button
            className="btn btn-link"
            id="date-exception-add-link"
            onClick={() => setIsAddingDate(true)}
          >
            &#xe15f; add an exception
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

  const checkboxIsChecked = exceptionDates.length !== 0 || isAddingDate

  return (
    <div>
      <Form.Group>
        <Checkbox
          id="exception-add"
          labelText="Include exceptions"
          checked={checkboxIsChecked}
          onChange={() => {
            setExceptionDates([])
            setIsAddingDate(!checkboxIsChecked)
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

export { DisruptionExceptionDates }
