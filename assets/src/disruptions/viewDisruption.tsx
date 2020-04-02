import * as React from "react"
import { RouteComponentProps, Link } from "react-router-dom"

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
  disruptionId: string
}

const EditDisruptionButton = ({
  disruptionId,
}: EditDisruptionButtonProps): JSX.Element => {
  return (
    <Link
      to={"/disruptions/" + encodeURIComponent(disruptionId) + "/edit"}
      id="edit-disruption-link"
      className="btn btn-primary"
    >
      edit disruption times
    </Link>
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

  if (disruption && disruption !== "error" && disruption.id) {
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
          <EditDisruptionButton disruptionId={disruption.id} />
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

export default ViewDisruption
