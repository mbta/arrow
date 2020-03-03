import * as React from "react"
import Button from "react-bootstrap/Button"
import ButtonGroup from "react-bootstrap/ButtonGroup"
import { RouteComponentProps } from "react-router-dom"
import { Redirect } from "react-router"

import Header from "../header"
import { DisruptionPreview } from "./disruptionPreview"
import { DisruptionSummary } from "./disruptionSummary"
import {
  DayOfWeekTimeRanges,
  DisruptionTimePicker,
} from "./disruptionTimePicker"

interface TParams {
  id: string
}

interface SaveCancelButtonProps {
  setRedirect: React.Dispatch<boolean>
  setIsPreview: React.Dispatch<boolean>
}

const SaveCancelButton = ({
  setRedirect,
  setIsPreview,
}: SaveCancelButtonProps): JSX.Element => {
  return (
    <ButtonGroup vertical>
      <Button
        variant="primary"
        onClick={() => setIsPreview(true)}
        id="save-changes-button"
      >
        save changes
      </Button>
      <Button
        variant="light"
        onClick={() => setRedirect(true)}
        id="cancel-button"
      >
        cancel
      </Button>
    </ButtonGroup>
  )
}

const EditDisruption = ({
  match,
}: RouteComponentProps<TParams>): JSX.Element => {
  // TODO: Dummy data, to be filled in with the results from an API call once that's ready
  const [fromDate, setFromDate] = React.useState<Date | null>(
    new Date("2020-03-06")
  )
  const [toDate, setToDate] = React.useState<Date | null>(
    new Date("2020-03-22")
  )
  const [exceptionDates, setExceptionDates] = React.useState<Date[]>([
    new Date("2020-03-13"),
  ])
  const [disruptionDaysOfWeek, setDisruptionDaysOfWeek] = React.useState<
    DayOfWeekTimeRanges
  >([
    null,
    null,
    null,
    null,
    [
      { hour: "1", minute: "00", period: "PM" },
      { hour: "11", minute: "00", period: "PM" },
    ],
    [
      { hour: "1", minute: "00", period: "PM" },
      { hour: "11", minute: "00", period: "PM" },
    ],
    [
      { hour: "1", minute: "00", period: "PM" },
      { hour: "11", minute: "00", period: "PM" },
    ],
  ])

  return (
    <EditDisruptionForm
      disruptionId={match.params.id}
      fromDate={fromDate}
      setFromDate={setFromDate}
      toDate={toDate}
      setToDate={setToDate}
      exceptionDates={exceptionDates}
      setExceptionDates={setExceptionDates}
      disruptionDaysOfWeek={disruptionDaysOfWeek}
      setDisruptionDaysOfWeek={setDisruptionDaysOfWeek}
    />
  )
}

interface EditDisruptionFormProps {
  disruptionId?: string
  fromDate: Date | null
  setFromDate: React.Dispatch<Date | null>
  toDate: Date | null
  setToDate: React.Dispatch<Date | null>
  exceptionDates: Date[]
  setExceptionDates: React.Dispatch<Date[]>
  disruptionDaysOfWeek: DayOfWeekTimeRanges
  setDisruptionDaysOfWeek: React.Dispatch<DayOfWeekTimeRanges>
}

const EditDisruptionForm = ({
  disruptionId,
  fromDate,
  setFromDate,
  toDate,
  setToDate,
  exceptionDates,
  setExceptionDates,
  disruptionDaysOfWeek,
  setDisruptionDaysOfWeek,
}: EditDisruptionFormProps): JSX.Element => {
  const [redirect, setRedirect] = React.useState(false)
  const [isPreview, setIsPreview] = React.useState<boolean>(false)

  // TODO: Dummy data, to be filled in with the results from an API call once that's ready
  const adjustment = {
    label: "Kenmore - Newton Highlands",
    route: "Green-D",
  }

  if (redirect && disruptionId) {
    return <Redirect to={"/disruptions/" + encodeURIComponent(disruptionId)} />
  } else if (isPreview) {
    return (
      <div>
        <Header />
        <DisruptionPreview
          disruptionId={disruptionId}
          adjustments={[adjustment]}
          setIsPreview={setIsPreview}
          fromDate={fromDate}
          toDate={toDate}
          disruptionDaysOfWeek={disruptionDaysOfWeek}
          exceptionDates={exceptionDates}
        />
      </div>
    )
  } else {
    return (
      <div>
        <Header />
        <DisruptionSummary
          disruptionId={disruptionId}
          adjustments={[adjustment]}
        />
        <fieldset>
          <legend>Edit disruption times</legend>
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
        </fieldset>
        <SaveCancelButton
          setRedirect={setRedirect}
          setIsPreview={setIsPreview}
        />
      </div>
    )
  }
}

export default EditDisruption
