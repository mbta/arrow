import * as React from "react"

import Alert from "react-bootstrap/Alert"
import Button from "react-bootstrap/Button"
import ButtonGroup from "react-bootstrap/ButtonGroup"

import { Redirect } from "react-router-dom"
import { RouteComponentProps, Link } from "react-router-dom"

import { apiGet, apiSend } from "../api"

import Header from "../header"
import Loading from "../loading"
import { DisruptionSummary } from "./disruptionSummary"
import {
  Time,
  DayOfWeekTimeRanges,
  fromDaysOfWeek,
  timeToString,
  ixToDayName,
} from "./time"
import { DisruptionTimePicker } from "./disruptionTimePicker"

import Adjustment from "../models/adjustment"
import Disruption from "../models/disruption"
import Exception from "../models/exception"
import { JsonApiResponse, toModelObject, parseErrors } from "../jsonApi"
import DayOfWeek from "../models/dayOfWeek"

interface TParams {
  id: string
}

interface SaveCancelButtonProps {
  disruptionId: string
  saveFn: () => void
}

const SaveCancelButton = ({
  disruptionId,
  saveFn,
}: SaveCancelButtonProps): JSX.Element => {
  return (
    <ButtonGroup vertical>
      <Button variant="primary" onClick={saveFn} id="save-changes-button">
        save changes
      </Button>
      <Link
        to={"/disruptions/" + encodeURIComponent(disruptionId)}
        id="cancel-button"
        className="btn btn-light"
      >
        cancel
      </Link>
    </ButtonGroup>
  )
}

const EditDisruption = ({
  match,
}: RouteComponentProps<TParams>): JSX.Element => {
  const [disruption, setDisruption] = React.useState<
    Disruption | "error" | null
  >(null)
  const [validationErrors, setValidationErrors] = React.useState<string[]>([])
  const [doRedirect, setDoRedirect] = React.useState<boolean>(false)

  const saveDisruption = React.useCallback(async () => {
    const result = await apiSend({
      url: "/api/disruptions/" + encodeURIComponent(match.params.id),
      method: "PATCH",
      json: JSON.stringify((disruption as Disruption).toJsonApi()),
      successParser: toModelObject,
      errorParser: parseErrors,
    })

    if (result.ok) {
      setDoRedirect(true)
    } else if (result.error) {
      setValidationErrors(result.error)
    }
  }, [disruption, match])

  React.useEffect(() => {
    apiGet<JsonApiResponse>({
      url: "/api/disruptions/" + encodeURIComponent(match.params.id),
      parser: toModelObject,
      defaultResult: "error",
    }).then((result: JsonApiResponse) => {
      if (result instanceof Disruption) {
        setDisruption(result)
      } else {
        setDisruption("error")
      }
    })
  }, [match.params.id])

  if (doRedirect) {
    return (
      <Redirect to={"/disruptions/" + +encodeURIComponent(match.params.id)} />
    )
  }

  if (disruption === "error") {
    return <div>Error loading disruption.</div>
  }

  if (disruption === null) {
    return <Loading />
  }

  const disruptionDaysOfWeek = fromDaysOfWeek(disruption.daysOfWeek)

  if (disruptionDaysOfWeek === "error") {
    return <div>Error parsing day of week information.</div>
  }

  const exceptionDates = disruption.exceptions
    .map((exception) => exception.excludedDate)
    .filter(
      (maybeDate: Date | undefined): maybeDate is Date =>
        typeof maybeDate !== "undefined"
    )

  return (
    <EditDisruptionForm
      disruptionId={match.params.id}
      adjustments={disruption.adjustments}
      fromDate={disruption.startDate || null}
      setFromDate={(newDate) => {
        const newDisruption = new Disruption({ ...disruption })
        if (newDate) {
          newDisruption.startDate = newDate
        } else {
          delete newDisruption.startDate
        }
        setDisruption(newDisruption)
      }}
      toDate={disruption.endDate || null}
      setToDate={(newDate) => {
        const newDisruption = new Disruption({ ...disruption })
        if (newDate) {
          newDisruption.endDate = newDate
        } else {
          delete newDisruption.endDate
        }
        setDisruption(newDisruption)
      }}
      exceptionDates={exceptionDates}
      setExceptionDates={setExceptionDatesForDisruption(
        new Disruption({ ...disruption }),
        setDisruption
      )}
      disruptionDaysOfWeek={disruptionDaysOfWeek}
      setDisruptionDaysOfWeek={setDisruptionDaysOfWeekForDisruption(
        new Disruption({ ...disruption }),
        setDisruption
      )}
      saveDisruption={saveDisruption}
      validationErrors={validationErrors}
    />
  )
}

const setExceptionDatesForDisruption = (
  disruption: Disruption,
  setDisruption: React.Dispatch<Disruption>
): React.Dispatch<Date[]> => {
  return (newExceptionDates) => {
    const newExceptionDatesAsTimes = newExceptionDates.map((date) =>
      date.getTime()
    )
    const currentExceptionDates = (disruption.exceptions
      .map((exception) => exception.excludedDate)
      .filter((maybeDate) => maybeDate instanceof Date) as Date[]).map((date) =>
      date.getTime()
    )

    const addedDates = newExceptionDatesAsTimes.filter(
      (date) => !currentExceptionDates.includes(date)
    )
    const removedDates = currentExceptionDates.filter(
      (date) => !newExceptionDatesAsTimes.includes(date)
    )

    // Trim out the removed dates
    disruption.exceptions = disruption.exceptions.filter((exception) => {
      return (
        exception.excludedDate instanceof Date &&
        !removedDates.includes(exception.excludedDate.getTime())
      )
    })
    // Add in added dates
    disruption.exceptions = disruption.exceptions.concat(
      addedDates.map((date) => new Exception({ excludedDate: new Date(date) }))
    )
    setDisruption(disruption)
  }
}

const setDisruptionDaysOfWeekForDisruption = (
  disruption: Disruption,
  setDisruption: React.Dispatch<Disruption>
): React.Dispatch<DayOfWeekTimeRanges> => {
  return (newDisruptionDaysOfWeek) => {
    for (let i = 0; i < newDisruptionDaysOfWeek.length; i++) {
      if (newDisruptionDaysOfWeek[i] === null) {
        disruption.daysOfWeek = disruption.daysOfWeek.filter(
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

        const dayOfWeekIndex = disruption.daysOfWeek.findIndex(
          (dayOfWeek) => dayOfWeek.dayName === ixToDayName(i)
        )

        if (dayOfWeekIndex === -1) {
          disruption.daysOfWeek = disruption.daysOfWeek.concat([
            new DayOfWeek({
              startTime,
              endTime,
              dayName: ixToDayName(i),
            }),
          ])
        } else {
          disruption.daysOfWeek[dayOfWeekIndex].startTime = startTime
          disruption.daysOfWeek[dayOfWeekIndex].endTime = endTime
        }
      }
    }
    setDisruption(disruption)
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
  return (
    <div>
      <Header />
      {validationErrors.length > 0 && (
        <Alert variant="danger">
          <ul>
            {validationErrors.map((err) => (
              <li key={err}>{err} </li>
            ))}
          </ul>
        </Alert>
      )}
      <DisruptionSummary
        disruptionId={disruptionId}
        adjustments={adjustments}
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
      <SaveCancelButton disruptionId={disruptionId} saveFn={saveDisruption} />
    </div>
  )
}

export default EditDisruption
