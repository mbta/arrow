import * as React from "react"
import { RouteComponentProps, Link, Redirect } from "react-router-dom"
import Alert from "react-bootstrap/Alert"
import Button from "react-bootstrap/Button"

import { apiGet, apiSend } from "../api"

import Header from "../header"
import Loading from "../loading"
import { DisruptionPreview } from "./disruptionPreview"
import { fromDaysOfWeek } from "./time"

import Disruption from "../models/disruption"
import { JsonApiResponse, toModelObject, parseErrors } from "../jsonApi"

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

interface DeleteDisruptionButtonProps {
  disruptionId: string
  setDoRedirect: React.Dispatch<React.SetStateAction<boolean>>
  setDeletionErrors: React.Dispatch<React.SetStateAction<string[]>>
}

const DeleteDisruptionButton = ({
  disruptionId,
  setDoRedirect,
  setDeletionErrors,
}: DeleteDisruptionButtonProps): JSX.Element => {
  return (
    <Button
      variant="light"
      onClick={async () => {
        if (window.confirm("Really delete this disruption?")) {
          const result = await apiSend({
            url: "/api/disruptions/" + encodeURIComponent(disruptionId),
            method: "DELETE",
            json: "",
            successParser: () => {
              return true
            },
            errorParser: parseErrors,
          })

          if (result.ok) {
            setDoRedirect(true)
          } else if (result.error) {
            setDeletionErrors(result.error)
          }
        }
      }}
      id="delete-disruption-button"
    >
      delete disruption
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
  const [disruption, setDisruption] = React.useState<
    Disruption | "error" | null
  >(null)
  const [doRedirect, setDoRedirect] = React.useState<boolean>(false)
  const [deletionErrors, setDeletionErrors] = React.useState<string[]>([])

  React.useEffect(() => {
    apiGet<JsonApiResponse>({
      url: "/api/disruptions/" + encodeURIComponent(disruptionId),
      parser: toModelObject,
      defaultResult: "error",
    }).then((result: JsonApiResponse) => {
      if (result instanceof Disruption) {
        setDisruption(result)
      } else {
        setDisruption("error")
      }
    })
  }, [disruptionId])

  if (doRedirect) {
    return <Redirect to={`/`} />
  }

  if (disruption && disruption !== "error" && disruption.id) {
    const exceptionDates = disruption.exceptions
      .map((exception) => exception.excludedDate)
      .filter(
        (maybeDate: Date | undefined): maybeDate is Date =>
          typeof maybeDate !== "undefined"
      )

    const disruptionDaysOfWeek = fromDaysOfWeek(disruption.daysOfWeek)

    if (disruptionDaysOfWeek !== "error") {
      return (
        <div>
          <Header />
          {deletionErrors.length > 0 && (
            <Alert variant="danger">
              <ul>
                {deletionErrors.map((err) => (
                  <li key={err}>{err} </li>
                ))}
              </ul>
            </Alert>
          )}
          <DisruptionPreview
            disruptionId={disruption.id}
            adjustments={disruption.adjustments}
            fromDate={disruption.startDate || null}
            toDate={disruption.endDate || null}
            exceptionDates={exceptionDates}
            disruptionDaysOfWeek={disruptionDaysOfWeek}
            tripShortNames={disruption.tripShortNames
              .map((tsn) => tsn.tripShortName)
              .join(", ")}
          />
          <div>
            <EditDisruptionButton disruptionId={disruption.id} />
          </div>
          {disruption.startDate &&
            disruption.startDate >= new Date(new Date().toDateString()) && (
              <div>
                <DeleteDisruptionButton
                  disruptionId={disruption.id}
                  setDoRedirect={setDoRedirect}
                  setDeletionErrors={setDeletionErrors}
                />
              </div>
            )}
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
