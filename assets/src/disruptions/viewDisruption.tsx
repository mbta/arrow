import * as React from "react"
import {
  RouteComponentProps,
  Link,
  Redirect,
  NavLink,
  useHistory,
} from "react-router-dom"
import Alert from "react-bootstrap/Alert"
import { LinkButton, PrimaryButton, SecondaryButton } from "../button"
import { apiGet, apiSend } from "../api"
import Loading from "../loading"
import { fromDaysOfWeek, timePeriodDescription } from "./time"
import { JsonApiResponse, toModelObject, parseErrors } from "../jsonApi"
import { Page } from "../page"
import Disruption, { DisruptionView } from "../models/disruption"
import { useDisruptionViewParam } from "./viewToggle"
import Row from "react-bootstrap/Row"
import Col from "react-bootstrap/Col"
import Icon from "../icons"
import { getRouteIcon } from "./disruptionIndex"
import { formatDisruptionDate } from "./disruptions"

interface TParams {
  id: string
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
    <LinkButton
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
      delete
    </LinkButton>
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
  const history = useHistory()

  if (doRedirect) {
    return <Redirect to={`/`} />
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

    if (disruptionDaysOfWeek !== "error") {
      return (
        <Page>
          <Row>
            <Col>
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
                {disruptionRevision?.disruptionId &&
                  disruptionRevision.startDate &&
                  disruptionRevision.startDate >=
                    new Date(new Date().toDateString()) &&
                  (view === DisruptionView.Draft ||
                    (view === DisruptionView.Ready && !draft) ||
                    (view === DisruptionView.Published && !draft && !ready)) &&
                  (disruptionRevision.isActive ? (
                    <DeleteDisruptionButton
                      disruptionId={disruption.id}
                      setDeletionErrors={setDeletionErrors}
                      setDoRedirect={setDoRedirect}
                    />
                  ) : (
                    <div>Marked for deletion</div>
                  ))}
              </div>
              {disruptionRevision && (
                <div className="m-disruption-details__adjustments">
                  <ul className="m-disruption-details__adjustment-list">
                    {disruptionRevision.adjustments.map((adj) => (
                      <li
                        key={adj.id}
                        className="m-disruption-details__adjustment-item"
                      >
                        <Icon
                          className="mr-3"
                          type={getRouteIcon(adj.routeId)}
                          size="sm"
                        />
                        {adj.sourceLabel}
                      </li>
                    ))}
                  </ul>
                </div>
              )}
              <div>
                <div className="mb-2">
                  <strong>select view</strong>
                </div>
                <div className="m-disruption-details__view-toggle-group d-flex flex-column">
                  {published && (
                    <NavLink
                      id="published"
                      to="?"
                      className="m-disruption-details__view-toggle"
                      activeClassName="active"
                      isActive={() => view === DisruptionView.Published}
                    >
                      <strong className="mr-3">published</strong>
                      <span className="text-muted">
                        In GTFS{" "}
                        {formatDisruptionDate(
                          disruption.lastPublishedAt || null
                        )}
                      </span>
                    </NavLink>
                  )}
                  {ready && (
                    <NavLink
                      id="ready"
                      className="m-disruption-details__view-toggle"
                      to="?v=ready"
                      activeClassName="active"
                      isActive={() => view === DisruptionView.Ready}
                      replace
                    >
                      <strong className="mr-3">ready</strong>
                      <span className="text-muted">
                        Created {formatDisruptionDate(ready.insertedAt || null)}
                      </span>
                    </NavLink>
                  )}
                  {draft ? (
                    <NavLink
                      id="draft"
                      className="m-disruption-details__view-toggle text-primary"
                      to="?v=draft"
                      activeClassName="active"
                      isActive={() => view === DisruptionView.Draft}
                      replace
                    >
                      <strong className="mr-3">needs review</strong>
                      <span className="text-muted">
                        Created {formatDisruptionDate(draft.insertedAt || null)}
                      </span>
                    </NavLink>
                  ) : (
                    <Link
                      className="m-disruption-details__view-toggle text-primary"
                      to={`/disruptions/${disruption.id}/edit`}
                    >
                      <strong>create new draft</strong>
                    </Link>
                  )}
                </div>
              </div>
              <hr className="my-3" />
              {disruptionRevision ? (
                <div>
                  <Row>
                    {!disruptionRevision.isActive && (
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
                      <div
                        className={
                          disruptionRevision.isActive ? "" : "text-muted"
                        }
                      >
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
                          <Link to={`/disruptions/${disruption.id}/edit`}>
                            <PrimaryButton
                              id="edit-disruption-link"
                              className="w-100"
                              filled
                            >
                              edit
                            </PrimaryButton>
                          </Link>
                        )}
                    </Col>
                  </Row>
                  <Row>
                    <Col>
                      {view === DisruptionView.Draft && (
                        <div>
                          <hr className="my-3" />
                          <div className="d-flex justify-content-center">
                            <SecondaryButton
                              id="mark-ready"
                              onClick={() => {
                                if (
                                  window.confirm(
                                    "Are you sure you want to mark these revisions as ready?"
                                  )
                                ) {
                                  apiSend({
                                    method: "POST",
                                    json: JSON.stringify({
                                      revision_ids: disruptionRevision.id,
                                    }),
                                    url: "/api/ready_notice/",
                                  })
                                    .then(async () => {
                                      await fetchDisruption()
                                      history.replace(
                                        "/disruptions/" +
                                          encodeURIComponent(disruptionId) +
                                          "?v=ready"
                                      )
                                    })
                                    .catch(() => {
                                      // eslint-disable-next-line no-console
                                      console.log(
                                        `failed to mark revision as ready: ${disruptionRevision.id}`
                                      )
                                    })
                                }
                              }}
                            >
                              {"mark as ready" +
                                (disruptionRevision.isActive
                                  ? ""
                                  : " for deletion")}
                            </SecondaryButton>
                          </div>
                        </div>
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
        </Page>
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
