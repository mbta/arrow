import * as React from "react"
import Button from "react-bootstrap/Button"
import { RouteComponentProps } from "react-router-dom"
import { Redirect } from "react-router"

import Header from "../header"
import { DisruptionPreview } from "./disruptionPreview"
import { fromDaysOfWeek } from "./time"

import Adjustment from "../models/adjustment"

interface TParams {
  id: string
}

interface EditDisruptionButtonProps {
  setRedirect: React.Dispatch<boolean>
}

const EditDisruptionButton = ({
  setRedirect,
}: EditDisruptionButtonProps): JSX.Element => {
  return (
    <Button
      variant="primary"
      onClick={() => setRedirect(true)}
      id="edit-disruption-button"
    >
      edit disruption times
    </Button>
  )
}

const ViewDisruption = ({
  match,
}: RouteComponentProps<TParams>): JSX.Element => {
  return <ViewDisruptionForm disruptionId={match.params.id} />
}

interface ViewDisruptionFormProps {
  disruptionId: string
}

const ViewDisruptionForm = ({
  disruptionId,
}: ViewDisruptionFormProps): JSX.Element => {
  const [redirect, setRedirect] = React.useState<boolean>(false)

  if (redirect) {
    return (
      <Redirect
        to={"/disruptions/" + encodeURIComponent(disruptionId) + "/edit"}
      />
    )
  } else {
    // TODO: Dummy data, to be filled in with the results from an API call once that's ready
    const adjustment = new Adjustment({
      routeId: "Green-D",
      sourceLabel: "Kenmore - Newton Highlands",
    })
    const fromDate = new Date("2020-03-06")
    const toDate = new Date("2020-03-22")
    const exceptionDates = [new Date("2020-03-13")]
    const disruptionDaysOfWeek: DayOfWeekTimeRanges = [
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
    ]

    return (
      <div>
        <Header />
        <DisruptionPreview
          disruptionId={disruptionId}
          adjustments={[adjustment]}
          fromDate={fromDate}
          toDate={toDate}
          exceptionDates={exceptionDates}
          disruptionDaysOfWeek={disruptionDaysOfWeek}
        />
        <EditDisruptionButton setRedirect={setRedirect} />
      </div>
    )
  }
}

export default ViewDisruption
