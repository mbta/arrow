import * as React from "react"
import { RouteComponentProps, Link, Redirect } from "react-router-dom"
import Alert from "react-bootstrap/Alert"
import { Button } from "../button"

import { apiGet, apiSend } from "../api"

import Loading from "../loading"
import { DisruptionPreview } from "./disruptionPreview"
import { fromDaysOfWeek } from "./time"

import Disruption from "../models/disruption"
import { JsonApiResponse, toModelObject, parseErrors } from "../jsonApi"
import { Page } from "../page"
import {
  DisruptionViewToggle,
  useDisruptionViewParam,
  DisruptionView,
  revisionFromDisruptionForView,
} from "./viewToggle"
import Row from "react-bootstrap/Row"
import Col from "react-bootstrap/Col"
import DisruptionRevision from "../models/disruptionRevision"

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
  const [disruptionRevision, setDisruptionRevision] = React.useState<
    DisruptionRevision | "error" | null
  >(null)
  const [doRedirect, setDoRedirect] = React.useState<boolean>(false)
  const [deletionErrors, setDeletionErrors] = React.useState<string[]>([])
  const view = useDisruptionViewParam()
  React.useEffect(() => {
    apiGet<JsonApiResponse>({
      url: "/api/disruptions/" + encodeURIComponent(disruptionId),
      parser: toModelObject,
      defaultResult: "error",
    }).then((result: JsonApiResponse) => {
      if (result instanceof Disruption) {
        setDisruptionRevision(
          revisionFromDisruptionForView(result, view) || null
        )
      } else {
        setDisruptionRevision("error")
      }
    })
  }, [disruptionId, view])

  if (doRedirect) {
    return <Redirect to={`/`} />
  }

  if (
    disruptionRevision &&
    disruptionRevision !== "error" &&
    disruptionRevision.id
  ) {
    const exceptionDates = disruptionRevision.exceptions
      .map((exception) => exception.excludedDate)
      .filter(
        (maybeDate: Date | undefined): maybeDate is Date =>
          typeof maybeDate !== "undefined"
      )

    const disruptionDaysOfWeek = fromDaysOfWeek(disruptionRevision.daysOfWeek)

    if (disruptionDaysOfWeek !== "error") {
      return (
        <Page>
          <Row>
            <Col xs={9}>
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
                disruptionId={disruptionRevision.disruptionId}
                adjustments={disruptionRevision.adjustments}
                fromDate={disruptionRevision.startDate || null}
                toDate={disruptionRevision.endDate || null}
                exceptionDates={exceptionDates}
                disruptionDaysOfWeek={disruptionDaysOfWeek}
                tripShortNames={disruptionRevision.tripShortNames
                  .map((tsn) => tsn.tripShortName)
                  .join(", ")}
              />
              {view === DisruptionView.Draft && (
                <>
                  <div>
                    {disruptionRevision.disruptionId && (
                      <EditDisruptionButton
                        disruptionId={disruptionRevision.disruptionId}
                      />
                    )}
                  </div>
                  {disruptionRevision.disruptionId &&
                    disruptionRevision.startDate &&
                    disruptionRevision.startDate >=
                      new Date(new Date().toDateString()) && (
                      <div>
                        <DeleteDisruptionButton
                          disruptionId={disruptionRevision.disruptionId}
                          setDoRedirect={setDoRedirect}
                          setDeletionErrors={setDeletionErrors}
                        />
                      </div>
                    )}
                </>
              )}
            </Col>
            <Col>
              <DisruptionViewToggle />
            </Col>
          </Row>
        </Page>
      )
    } else {
      return <div>Error parsing day of week information.</div>
    }
  } else if (disruptionRevision === "error") {
    return <div>Error fetching or parsing disruption.</div>
  } else {
    return <Loading />
  }
}

export default ViewDisruption
