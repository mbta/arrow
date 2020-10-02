import * as React from "react"
import Col from "react-bootstrap/Col"
import Form from "react-bootstrap/Form"
import Row from "react-bootstrap/Row"

import DatePicker from "../datePicker"

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
      <Row>
        <Col lg={4}>
          <div>
            <strong>start</strong>
          </div>
          <DatePicker
            id="disruption-date-range-start"
            selected={fromDate}
            onChange={(date) => {
              if (!Array.isArray(date)) {
                setFromDate(date)
              }
            }}
          />
        </Col>
        <Col>
          <div>
            <strong>end</strong>
          </div>
          <DatePicker
            id="disruption-date-range-end"
            selected={toDate}
            onChange={(date) => {
              if (!Array.isArray(date)) {
                setToDate(date)
              }
            }}
          />
        </Col>
      </Row>
    </Form.Group>
  )
}

export { DisruptionDateRange }
