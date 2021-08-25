import * as React from "react"
import Alert from "react-bootstrap/Alert"
import { LinkButton, PrimaryButton } from "../button"
import { apiGet, apiSend } from "../api"
import Loading from "../loading"
import { redirectTo } from "../navigation"
import { fromDaysOfWeek, timePeriodDescription } from "./time"
import { JsonApiResponse, toModelObject, parseErrors } from "../jsonApi"
import Disruption, { DisruptionView } from "../models/disruption"
import { useDisruptionViewParam } from "./viewToggle"
import Row from "react-bootstrap/Row"
import Col from "react-bootstrap/Col"
import { formatDisruptionDate } from "./disruptions"
import { ConfirmationModal } from "../confirmationModal"
import { AdjustmentSummary } from "./adjustmentSummary"

interface ViewDisruptionProps {
  id: string
}

const ViewDisruption = ({ id }: ViewDisruptionProps): JSX.Element => {
  return <ViewDisruptionForm disruptionId={id} />
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
  const fetchDisruption = React.useCallback(() => {
    return apiGet<JsonApiResponse>({
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
  }, [disruptionId, setDisruption])
  React.useEffect(() => {
    fetchDisruption()
  }, [disruptionId, fetchDisruption])

  const view = useDisruptionViewParam()

  if (doRedirect) {
    redirectTo("/")
  }

  if (disruption && disruption !== "error" && disruption.id) {
    const { published, ready, draft } = disruption.getUniqueRevisions()
    const disruptionRevision = Disruption.uniqueRevisionFromDisruptionForView(
      disruption,
      view
    )

    const exceptionDates = (disruptionRevision?.exceptions || [])
      .map((exception) => exception.excludedDate)
      .filter(
        (maybeDate: Date | undefined): maybeDate is Date =>
          typeof maybeDate !== "undefined"
      )

    const disruptionDaysOfWeek = fromDaysOfWeek(
      disruptionRevision?.daysOfWeek || []
    )

    const anyDeleted = [published, ready, draft].some((x) => !!x && !x.isActive)

    if (disruptionDaysOfWeek !== "error") {
      return (
        <>
          <Row>
            <Col lg={7}>
              {deletionErrors.length > 0 && (
                <Alert variant="danger">
                  <ul>
                    {deletionErrors.map((err) => (
                      <li key={err}>{err} </li>
                    ))}
                  </ul>
                </Alert>
              )}
              <div className="m-disruption-details__header">
                <div className="d-flex align-items-end">
                  <h2 className="mb-0">adjustment</h2>
                  <h5>
                    ID
                    <span className="ml-2 font-weight-normal">
                      {disruptionId}
                    </span>
                  </h5>
                </div>
                {disruptionRevision &&
                  (anyDeleted ? (
                    <div>Marked for deletion</div>
                  ) : disruptionRevision &&
                    disruptionRevision.startDate &&
                    disruptionRevision.startDate >=
                      new Date(new Date().toDateString()) ? (
                    <ConfirmationModal
                      confirmationText={
                        !published && !ready
                          ? "Since this draft is not published or ready, this will delete this disruption from Arrow permanently."
                          : "Since this draft is published or ready, this change must be approved first before it is added to GTFS."
                      }
                      confirmationButtonText={
                        !published && !ready
                          ? "yes, delete"
                          : "mark for deletion"
                      }
                      onClickConfirm={async () => {
                        const result = await apiSend({
                          url:
                            "/api/disruptions/" +
                            encodeURIComponent(disruptionId),
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
                      }}
                      Component={
                        <LinkButton id="delete-disruption-button">
                          delete
                        </LinkButton>
                      }
                    />
                  ) : null)}
              </div>
              {disruptionRevision && (
                <AdjustmentSummary
                  adjustments={disruptionRevision.adjustments}
                />
              )}
              <div>
                <div className="mb-2">
                  <strong>select view</strong>
                </div>
                <div className="m-disruption-details__view-toggle-group d-flex flex-column">
                  {published && (
                    <a
                      id="published"
                      href="?"
                      className={
                        "m-disruption-details__view-toggle " +
                        (view === DisruptionView.Published ? "active" : "")
                      }
                    >
                      <strong className="mr-3">published</strong>
                      <span className="text-muted">
                        In GTFS{" "}
                        {formatDisruptionDate(
                          disruption.lastPublishedAt || null
                        )}
                      </span>
                    </a>
                  )}
                  {ready && (
                    <a
                      id="ready"
                      className={
                        "m-disruption-details__view-toggle " +
                        (view === DisruptionView.Ready ? "active" : "")
                      }
                      href="?v=ready"
                    >
                      <strong className="mr-3">ready</strong>
                      <span className="text-muted">
                        Created {formatDisruptionDate(ready.insertedAt || null)}
                      </span>
                    </a>
                  )}
                  {draft ? (
                    <a
                      id="draft"
                      className={
                        "m-disruption-details__view-toggle text-primary " +
                        (view === DisruptionView.Draft ? "active" : "")
                      }
                      href="?v=draft"
                    >
                      <strong className="mr-3">needs review</strong>
                      <span className="text-muted">
                        Created {formatDisruptionDate(draft.insertedAt || null)}
                      </span>
                    </a>
                  ) : !anyDeleted ? (
                    <a
                      className="m-disruption-details__view-toggle text-primary"
                      href={`/disruptions/${disruption.id}/edit`}
                    >
                      <strong>create new draft</strong>
                    </a>
                  ) : null}
                </div>
              </div>
              <hr className="my-3" />
              {disruptionRevision ? (
                <div>
                  <Row>
                    {anyDeleted && (
                      <Col xs={12}>
                        <div className="m-disruption-details__deletion-indicator">
                          <span className="text-blue-grey mr-3">
                            {"\uE14E"}
                          </span>
                          <strong>Note</strong> This disruption is marked for
                          deletion
                        </div>
                      </Col>
                    )}
                    <Col md={10}>
                      <div className={anyDeleted ? "text-muted" : ""}>
                        <div className="mb-3">
                          <h4>date range</h4>
                          <div className="pl-3">
                            {formatDisruptionDate(
                              disruptionRevision.startDate || null
                            )}{" "}
                            &ndash;{" "}
                            {formatDisruptionDate(
                              disruptionRevision.endDate || null
                            )}
                          </div>
                        </div>
                        <div className="mb-3">
                          <h4>time period</h4>
                          <div className="pl-3">
                            {disruptionRevision.daysOfWeek.map((d) => {
                              return (
                                <div key={d.id}>
                                  <div>
                                    <strong>
                                      {d.dayName.charAt(0).toUpperCase() +
                                        d.dayName.slice(1)}
                                    </strong>
                                  </div>
                                  <div>
                                    {timePeriodDescription(
                                      d.startTime,
                                      d.endTime
                                    )}
                                  </div>
                                </div>
                              )
                            })}
                          </div>
                        </div>
                        {disruptionRevision.tripShortNames.length > 0 && (
                          <div className="mb-3">
                            <h4>trips</h4>
                            <div className="pl-3">
                              {disruptionRevision.tripShortNames
                                .map((x) => x.tripShortName)
                                .join(", ")}
                            </div>
                          </div>
                        )}
                        {exceptionDates.length > 0 && (
                          <div className="mb-3">
                            <h4>exceptions</h4>
                            <div className="pl-3">
                              {exceptionDates.map((exc) => {
                                return (
                                  <div key={exc.toISOString()}>
                                    {formatDisruptionDate(exc)}
                                  </div>
                                )
                              })}
                            </div>
                          </div>
                        )}
                      </div>
                    </Col>
                    <Col md={2}>
                      {view === DisruptionView.Draft &&
                        disruptionRevision.isActive && (
                          <a href={`/disruptions/${disruption.id}/edit`}>
                            <PrimaryButton
                              id="edit-disruption-link"
                              className="w-100"
                              filled
                            >
                              edit
                            </PrimaryButton>
                          </a>
                        )}
                    </Col>
                  </Row>
                </div>
              ) : (
                <div>
                  Disruption {disruption.id} has no{" "}
                  {view === DisruptionView.Draft
                    ? "draft"
                    : view === DisruptionView.Ready
                    ? "ready"
                    : "published"}{" "}
                  revision
                </div>
              )}
            </Col>
          </Row>
        </>
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
