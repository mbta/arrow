import * as React from "react"

import Alert from "react-bootstrap/Alert"
import { PrimaryButton } from "../button"
import Col from "react-bootstrap/Col"

import { Redirect, RouteComponentProps, useHistory } from "react-router-dom"

import { apiGet, apiSend } from "../api"

import Loading from "../loading"
import { AdjustmentSummary } from "./adjustmentSummary"
import {
  Time,
  DayOfWeekTimeRanges,
  fromDaysOfWeek,
  timeToString,
  ixToDayName,
} from "./time"
import { DisruptionTimePicker } from "./disruptionTimePicker"

import Adjustment from "../models/adjustment"
import Disruption, { DisruptionView } from "../models/disruption"
import DisruptionRevision from "../models/disruptionRevision"
import Exception from "../models/exception"
import { JsonApiResponse, toModelObject, parseErrors } from "../jsonApi"
import DayOfWeek from "../models/dayOfWeek"
import { Page } from "../page"
import { ConfirmationModal } from "../confirmationModal"
import { DisruptionExceptionDates } from "./disruptionExceptionDates"
import { DisruptionDateRange } from "./disruptionDateRange"

interface TParams {
  id: string
}

const EditDisruption = ({
  match,
}: RouteComponentProps<TParams>): JSX.Element => {
  const [disruptionRevision, setDisruptionRevision] = React.useState<
    DisruptionRevision | "error" | null
  >(null)
  const [validationErrors, setValidationErrors] = React.useState<string[]>([])
  const [doRedirect, setDoRedirect] = React.useState<boolean>(false)

  const saveDisruption = React.useCallback(async () => {
    const result = await apiSend({
      url: "/api/disruptions/" + encodeURIComponent(match.params.id),
      method: "PATCH",
      json: JSON.stringify(
        (disruptionRevision as DisruptionRevision).toJsonApi()
      ),
      successParser: toModelObject,
      errorParser: parseErrors,
    })

    if (result.ok) {
      setDoRedirect(true)
    } else if (result.error) {
      setValidationErrors(result.error)
    }
  }, [disruptionRevision, match])

  React.useEffect(() => {
    apiGet<JsonApiResponse>({
      url: "/api/disruptions/" + encodeURIComponent(match.params.id),
      parser: toModelObject,
      defaultResult: "error",
    }).then((result: JsonApiResponse) => {
      if (result instanceof Disruption) {
        const revisionFromResponse = Disruption.revisionFromDisruptionForView(
          result,
          DisruptionView.Draft
        )

        if (typeof revisionFromResponse !== "undefined") {
          setDisruptionRevision(revisionFromResponse)
        }
      } else {
        setDisruptionRevision("error")
      }
    })
  }, [match.params.id])

  if (doRedirect) {
    return (
      <Redirect
        to={"/disruptions/" + encodeURIComponent(match.params.id) + "?v=draft"}
      />
    )
  }

  if (disruptionRevision === "error") {
    return <div>Error loading disruption.</div>
  }

  if (disruptionRevision === null) {
    return <Loading />
  }

  const disruptionDaysOfWeek = fromDaysOfWeek(disruptionRevision.daysOfWeek)

  if (disruptionDaysOfWeek === "error") {
    return <div>Error parsing day of week information.</div>
  }

  const exceptionDates = disruptionRevision.exceptions
    .map((exception) => exception.excludedDate)
    .filter(
      (maybeDate: Date | undefined): maybeDate is Date =>
        typeof maybeDate !== "undefined"
    )

  return (
    <EditDisruptionForm
      disruptionId={match.params.id}
      adjustments={disruptionRevision.adjustments}
      fromDate={disruptionRevision.startDate || null}
      setFromDate={(newDate) => {
        const newDisruptionRevision = new DisruptionRevision({
          ...disruptionRevision,
        })
        if (newDate) {
          newDisruptionRevision.startDate = newDate
        } else {
          delete newDisruptionRevision.startDate
        }
        setDisruptionRevision(newDisruptionRevision)
      }}
      toDate={disruptionRevision.endDate || null}
      setToDate={(newDate) => {
        const newDisruptionRevision = new DisruptionRevision({
          ...disruptionRevision,
        })
        if (newDate) {
          newDisruptionRevision.endDate = newDate
        } else {
          delete newDisruptionRevision.endDate
        }
        setDisruptionRevision(newDisruptionRevision)
      }}
      exceptionDates={exceptionDates}
      setExceptionDates={setExceptionDatesForDisruption(
        new DisruptionRevision({ ...disruptionRevision }),
        setDisruptionRevision
      )}
      disruptionDaysOfWeek={disruptionDaysOfWeek}
      setDisruptionDaysOfWeek={setDisruptionDaysOfWeekForDisruption(
        new DisruptionRevision({ ...disruptionRevision }),
        setDisruptionRevision
      )}
      saveDisruption={saveDisruption}
      validationErrors={validationErrors}
    />
  )
}

const setExceptionDatesForDisruption = (
  disruptionRevision: DisruptionRevision,
  setDisruptionRevision: React.Dispatch<DisruptionRevision>
): React.Dispatch<Date[]> => {
  return (newExceptionDates) => {
    const newExceptionDatesAsTimes = newExceptionDates.map((date) =>
      date.getTime()
    )
    const currentExceptionDates = disruptionRevision.exceptions
      .map((exception) => exception.excludedDate)
      .filter((maybeDate) => maybeDate instanceof Date)
      .map((date) => date.getTime())

    const addedDates = newExceptionDatesAsTimes.filter(
      (date) => !currentExceptionDates.includes(date)
    )
    const removedDates = currentExceptionDates.filter(
      (date) => !newExceptionDatesAsTimes.includes(date)
    )

    // Trim out the removed dates
    disruptionRevision.exceptions = disruptionRevision.exceptions.filter(
      (exception) => {
        return (
          exception.excludedDate instanceof Date &&
          !removedDates.includes(exception.excludedDate.getTime())
        )
      }
    )
    // Add in added dates
    disruptionRevision.exceptions = disruptionRevision.exceptions.concat(
      addedDates.map((date) => new Exception({ excludedDate: new Date(date) }))
    )
    setDisruptionRevision(disruptionRevision)
  }
}

const setDisruptionDaysOfWeekForDisruption = (
  disruptionRevision: DisruptionRevision,
  setDisruptionRevision: React.Dispatch<DisruptionRevision>
): React.Dispatch<DayOfWeekTimeRanges> => {
  return (newDisruptionDaysOfWeek) => {
    for (let i = 0; i < newDisruptionDaysOfWeek.length; i++) {
      if (newDisruptionDaysOfWeek[i] === null) {
        disruptionRevision.daysOfWeek = disruptionRevision.daysOfWeek.filter(
          (dayOfWeek) => dayOfWeek.dayName !== ixToDayName(i)
        )
      } else {
        let startTime
        if ((newDisruptionDaysOfWeek[i] as [Time | null, Time | null])[0]) {
          startTime = timeToString(
            (newDisruptionDaysOfWeek[i] as [
              Time | null,
              Time | null
            ])[0] as Time
          )
        }

        let endTime
        if ((newDisruptionDaysOfWeek[i] as [Time | null, Time | null])[1]) {
          endTime = timeToString(
            (newDisruptionDaysOfWeek[i] as [
              Time | null,
              Time | null
            ])[1] as Time
          )
        }

        const dayOfWeekIndex = disruptionRevision.daysOfWeek.findIndex(
          (dayOfWeek) => dayOfWeek.dayName === ixToDayName(i)
        )

        if (dayOfWeekIndex === -1) {
          disruptionRevision.daysOfWeek = disruptionRevision.daysOfWeek.concat([
            new DayOfWeek({
              startTime,
              endTime,
              dayName: ixToDayName(i),
            }),
          ])
        } else {
          disruptionRevision.daysOfWeek[dayOfWeekIndex].startTime = startTime
          disruptionRevision.daysOfWeek[dayOfWeekIndex].endTime = endTime
        }
      }
    }
    setDisruptionRevision(disruptionRevision)
  }
}

interface EditDisruptionFormProps {
  disruptionId: string
  adjustments: Adjustment[]
  fromDate: Date | null
  setFromDate: React.Dispatch<Date | null>
  toDate: Date | null
  setToDate: React.Dispatch<Date | null>
  exceptionDates: Date[]
  setExceptionDates: React.Dispatch<Date[]>
  disruptionDaysOfWeek: DayOfWeekTimeRanges
  setDisruptionDaysOfWeek: React.Dispatch<DayOfWeekTimeRanges>
  saveDisruption: () => void
  validationErrors: string[]
}

const EditDisruptionForm = ({
  disruptionId,
  adjustments,
  fromDate,
  setFromDate,
  toDate,
  setToDate,
  exceptionDates,
  setExceptionDates,
  disruptionDaysOfWeek,
  setDisruptionDaysOfWeek,
  saveDisruption,
  validationErrors,
}: EditDisruptionFormProps): JSX.Element => {
  const history = useHistory()

  return (
    <Page>
      <Col lg={8}>
        <hr />
        <h1>
          edit disruption{" "}
          <span className="m-disruption-form__header-id">ID</span>{" "}
          <span className="m-disruption-form__header-num">{disruptionId}</span>
        </h1>

        <AdjustmentSummary adjustments={adjustments} />
        <hr />
        {validationErrors.length > 0 && (
          <Alert variant="danger">
            <ul>
              {validationErrors.map((err) => (
                <li key={err}>{err} </li>
              ))}
            </ul>
          </Alert>
        )}

        <div>
          <h4>date range</h4>
          <div className="pl-4">
            <DisruptionDateRange
              fromDate={fromDate}
              setFromDate={setFromDate}
              toDate={toDate}
              setToDate={setToDate}
            />
          </div>
        </div>
        <div>
          <fieldset>
            <h4>time period</h4>
            <div className="pl-4">
              <DisruptionTimePicker
                disruptionDaysOfWeek={disruptionDaysOfWeek}
                setDisruptionDaysOfWeek={setDisruptionDaysOfWeek}
              />
            </div>
          </fieldset>
        </div>
        <div>
          <h4>exceptions</h4>
          <div className="pl-4">
            <DisruptionExceptionDates
              exceptionDates={exceptionDates}
              setExceptionDates={setExceptionDates}
            />
          </div>
        </div>

        <hr className="light-hr" />

        <div className="d-flex justify-content-center">
          <div className="w-25 mr-2">
            <PrimaryButton
              className="w-100"
              filled={true}
              onClick={saveDisruption}
              id="save-disruption-button"
            >
              save
            </PrimaryButton>
          </div>
          <div className="w-25 ml-2">
            <ConfirmationModal
              confirmationText="Any changes you've made to this disruption will not be saved as a draft."
              confirmationButtonText="discard changes"
              cancelButtonText="keep editing"
              onClickConfirm={() => {
                history.goBack()
              }}
              Component={
                <PrimaryButton id="cancel-disruption-button" className="w-100">
                  cancel
                </PrimaryButton>
              }
            />
          </div>
        </div>
      </Col>
    </Page>
  )
}

export default EditDisruption
