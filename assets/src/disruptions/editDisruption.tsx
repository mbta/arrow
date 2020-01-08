import * as React from "react"
import Button from "react-bootstrap/Button"
import ButtonGroup from "react-bootstrap/ButtonGroup"
import { RouteComponentProps } from "react-router-dom"

import Header from "../header"
import {
  DayOfWeekTimeRanges,
  DisruptionTimePicker,
} from "./disruptionTimePicker"

interface TParams {
  id: string
}

const AdjustmentSummary = (): JSX.Element => {
  return (
    <div>
      <div>Adjustment name(s) go here.</div>
      <div>Disruption ID goes here.</div>
      <div>Route bullet goes here.</div>
    </div>
  )
}

const SaveCancelButton = (): JSX.Element => {
  return (
    <ButtonGroup vertical>
      <Button variant="primary">save changes</Button>
      <Button variant="light">cancel</Button>
    </ButtonGroup>
  )
}

const EditDisruption = ({
  match,
}: RouteComponentProps<TParams>): JSX.Element => {
  const [fromDate, setFromDate] = React.useState<Date | null>(null)
  const [toDate, setToDate] = React.useState<Date | null>(null)
  const [exceptionDates, setExceptionDates] = React.useState<Date[]>([])
  const [disruptionDaysOfWeek, setDisruptionDaysOfWeek] = React.useState<
    DayOfWeekTimeRanges
  >([null, null, null, null, null, null, null])

  return (
    <div>
      <Header />
      <div>id is {match.params.id}</div>
      <AdjustmentSummary />
      <DisruptionTimePicker
        fromDate={fromDate}
        setFromDate={setFromDate}
        toDate={toDate}
        setToDate={setToDate}
        disruptionDaysOfWeek={disruptionDaysOfWeek}
        setDisruptionDaysOfWeek={setDisruptionDaysOfWeek}
        exceptionDates={exceptionDates}
        setExceptionDates={setExceptionDates}
      />
      <SaveCancelButton />
    </div>
  )
}

export default EditDisruption
