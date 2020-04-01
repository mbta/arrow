import * as React from "react"
import Button from "react-bootstrap/Button"
import { RouteComponentProps } from "react-router-dom"
import { Redirect } from "react-router"

import { apiCall } from "../api"

import Header from "../header"
import Loading from "../loading"
import { DisruptionPreview } from "./disruptionPreview"
import { fromDaysOfWeek } from "./time"

import Disruption from "../models/disruption"
import { ModelObject, toModelObject } from "../jsonApi"

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
  const [disruption, setDisruption] = React.useState<
    Disruption | "error" | null
  >(null)

  React.useEffect(() => {
    apiCall<ModelObject | "error">({
      url: "/api/disruptions/" + encodeURIComponent(disruptionId),
      parser: toModelObject,
      defaultResult: "error",
    }).then((result: ModelObject | "error") => {
      if (result instanceof Disruption) {
        setDisruption(result)
      } else {
        setDisruption("error")
      }
    })
  }, [disruptionId])

  if (redirect) {
    return (
      <Redirect
        to={"/disruptions/" + encodeURIComponent(disruptionId) + "/edit"}
      />
    )
  } else {
    if (disruption && disruption !== "error") {
      const exceptionDates = disruption.exceptions
        .map(exception => exception.excludedDate)
        .filter(
          (maybeDate: Date | undefined): maybeDate is Date =>
            typeof maybeDate !== "undefined"
        )

      const disruptionDaysOfWeek = fromDaysOfWeek(disruption.daysOfWeek)

      if (disruptionDaysOfWeek !== "error") {
        return (
          <div>
            <Header />
            <DisruptionPreview
              disruptionId={disruption.id}
              adjustments={disruption.adjustments}
              fromDate={disruption.startDate || null}
              toDate={disruption.endDate || null}
              exceptionDates={exceptionDates}
              disruptionDaysOfWeek={disruptionDaysOfWeek}
            />
            <EditDisruptionButton setRedirect={setRedirect} />
          </div>
        )
      } else {
        return <div>Error parsing day of week information.</div>
      }
    } else if (disruption === "error") {
      return <div>Error fetching or parsing disruption.</div>
    } else {
      return <Loading />
    }
  }
}

export default ViewDisruption
