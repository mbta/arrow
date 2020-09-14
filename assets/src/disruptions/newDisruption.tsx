import * as React from "react"

import { Redirect } from "react-router-dom"
import Select, { ValueType } from "react-select"

import Button from "react-bootstrap/Button"
import Form from "react-bootstrap/Form"
import Alert from "react-bootstrap/Alert"

import { apiGet, apiSend } from "../api"
import { toModelObject, JsonApiResponse, parseErrors } from "../jsonApi"
import DisruptionRevision from "../models/disruptionRevision"
import Adjustment from "../models/adjustment"
import Exception from "../models/exception"
import { DayOfWeekTimeRanges, dayOfWeekTimeRangesToDayOfWeeks } from "./time"

import Loading from "../loading"
import { DisruptionTimePicker } from "./disruptionTimePicker"
import { TransitMode, modeForRoute } from "./disruptions"
import { DisruptionPreview } from "./disruptionPreview"
import TripShortName from "../models/tripShortName"
import { Page } from "../page"

interface AdjustmentModePickerProps {
  transitMode: TransitMode
  setTransitMode: React.Dispatch<TransitMode>
  setAdjustments: React.Dispatch<Adjustment[]>
}

const AdjustmentModePicker = ({
  transitMode,
  setTransitMode,
  setAdjustments,
}: AdjustmentModePickerProps): JSX.Element => {
  return (
    <fieldset>
      <legend>For which mode?</legend>
      <Form.Group controlId="formTransitMode">
        <Form.Check
          type="radio"
          id="mode-subway"
          label="Subway"
          name="mode-radio"
          checked={transitMode === TransitMode.Subway}
          onChange={() => {
            setAdjustments([])
            setTransitMode(TransitMode.Subway)
          }}
        />
        <Form.Check
          type="radio"
          id="mode-commuter-rail"
          label="Commuter Rail"
          name="mode-radio"
          checked={transitMode === TransitMode.CommuterRail}
          onChange={() => {
            setAdjustments([])
            setTransitMode(TransitMode.CommuterRail)
          }}
        />
      </Form.Group>
    </fieldset>
  )
}

interface AdjustmentsPickerProps {
  allAdjustments: Adjustment[]
  transitMode: TransitMode
  adjustments: Adjustment[]
  setAdjustments: React.Dispatch<Adjustment[]>
}

interface AdjustmentPickerOption {
  label: string
  value: string
  data: Adjustment
}

const AdjustmentsPicker = ({
  allAdjustments,
  transitMode,
  adjustments,
  setAdjustments,
}: AdjustmentsPickerProps): JSX.Element => {
  const modeAdjustmentOptions = React.useMemo(() => {
    return allAdjustments
      .filter(
        (adjustment) =>
          adjustment.routeId && modeForRoute(adjustment.routeId) === transitMode
      )
      .map((adjustment) => {
        return {
          label: adjustment.sourceLabel,
          value: adjustment.id,
          data: adjustment,
        }
      })
  }, [allAdjustments, transitMode])

  const modeAdjustmentValues = React.useMemo(() => {
    return adjustments.map((adj) => {
      return { label: adj.sourceLabel, value: adj.id, data: adj }
    })
  }, [adjustments])

  return (
    <fieldset>
      <legend>For which locations?</legend>
      <Form.Group>
        <Select<AdjustmentPickerOption>
          inputId="adjustment-select"
          classNamePrefix="adjustment-select"
          onChange={(values: ValueType<AdjustmentPickerOption>) => {
            if (Array.isArray(values)) {
              setAdjustments(values.map((adj) => adj.data))
            } else {
              setAdjustments([])
            }
          }}
          value={modeAdjustmentValues}
          options={modeAdjustmentOptions}
          isMulti={true}
        />
      </Form.Group>
    </fieldset>
  )
}

interface TripShortNamesFormProps {
  tripShortNames: string
  setTripShortNames: React.Dispatch<string>
  whichTrips: "all" | "some"
  setWhichTrips: React.Dispatch<"all" | "some">
}

const TripShortNamesForm = ({
  tripShortNames,
  setTripShortNames,
  whichTrips,
  setWhichTrips,
}: TripShortNamesFormProps) => {
  return (
    <div>
      <Form.Group>
        <Form.Check
          type="radio"
          id="trips-all"
          label="All Trips"
          name="which-trips"
          checked={whichTrips === "all"}
          onChange={() => {
            setWhichTrips("all")
            setTripShortNames("")
          }}
        />
        <Form.Check
          type="radio"
          id="trips-some"
          label="Some Trips"
          name="which-trips"
          checked={whichTrips === "some"}
          onChange={() => setWhichTrips("some")}
        />
        {whichTrips === "some" && (
          <Form.Control
            className="mb-3"
            id="trip-short-names"
            type="text"
            value={tripShortNames}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
              setTripShortNames(e.target.value)
            }
            placeholder="Enter comma separated trip short names "
          />
        )}
      </Form.Group>
    </div>
  )
}

interface ApiCreateDisruptionParams {
  adjustments: Adjustment[]
  fromDate: Date | null
  toDate: Date | null
  disruptionDaysOfWeek: DayOfWeekTimeRanges
  exceptionDates: Date[]
  tripShortNames: string
}

const disruptionRevisionFromState = ({
  adjustments,
  fromDate,
  toDate,
  disruptionDaysOfWeek,
  exceptionDates,
  tripShortNames,
}: ApiCreateDisruptionParams): DisruptionRevision => {
  return new DisruptionRevision({
    ...(fromDate && { startDate: fromDate }),
    ...(toDate && { endDate: toDate }),
    isActive: true,
    adjustments,
    daysOfWeek: dayOfWeekTimeRangesToDayOfWeeks(disruptionDaysOfWeek),
    exceptions: Exception.fromDates(exceptionDates),
    tripShortNames: tripShortNames
      ? tripShortNames
          .split(/\s*,\s*/)
          .map((tripShortName) => new TripShortName({ tripShortName }))
      : [],
  })
}

const NewDisruption = ({}): JSX.Element => {
  const [adjustments, setAdjustments] = React.useState<Adjustment[]>([])
  const [fromDate, setFromDate] = React.useState<Date | null>(null)
  const [toDate, setToDate] = React.useState<Date | null>(null)
  const [disruptionDaysOfWeek, setDisruptionDaysOfWeek] = React.useState<
    DayOfWeekTimeRanges
  >([null, null, null, null, null, null, null])
  const [exceptionDates, setExceptionDates] = React.useState<Date[]>([])
  const [tripShortNames, setTripShortNames] = React.useState<string>("")
  const [isPreview, setIsPreview] = React.useState<boolean>(false)
  const [allAdjustments, setAllAdjustments] = React.useState<
    Adjustment[] | "error" | null
  >(null)
  const [validationErrors, setValidationErrors] = React.useState<string[]>([])
  const [doRedirect, setDoRedirect] = React.useState<boolean>(false)
  const [transitMode, setTransitMode] = React.useState<TransitMode>(
    TransitMode.Subway
  )
  const [whichTrips, setWhichTrips] = React.useState<"all" | "some">("all")

  const createFn = async (args: ApiCreateDisruptionParams) => {
    const disruptionRevision = disruptionRevisionFromState(args)

    const result = await apiSend({
      url: "/api/disruptions",
      method: "POST",
      json: JSON.stringify(disruptionRevision.toJsonApi()),
      successParser: toModelObject,
      errorParser: parseErrors,
    })

    if (result.ok) {
      setDoRedirect(true)
    } else if (result.error) {
      setIsPreview(false)
      setValidationErrors(result.error)
    }
  }

  React.useEffect(() => {
    apiGet<JsonApiResponse>({
      url: "/api/adjustments",
      parser: toModelObject,
      defaultResult: "error",
    }).then((result: JsonApiResponse) => {
      if (Array.isArray(result) && result.every(Adjustment.isOfType)) {
        setAllAdjustments(result as Adjustment[])
      } else {
        setAllAdjustments("error")
      }
    })
  }, [])

  if (allAdjustments === null) {
    return <Loading />
  }

  if (allAdjustments === "error") {
    return <div>Error loading or parsing adjustments.</div>
  }

  if (doRedirect) {
    return <Redirect to={`/`} />
  }

  return (
    <Page>
      {isPreview ? (
        <DisruptionPreview
          adjustments={adjustments}
          setIsPreview={setIsPreview}
          fromDate={fromDate}
          toDate={toDate}
          disruptionDaysOfWeek={disruptionDaysOfWeek}
          exceptionDates={exceptionDates}
          tripShortNames={tripShortNames}
          createFn={createFn}
        />
      ) : (
        <>
          {validationErrors.length > 0 && (
            <Alert variant="danger">
              <ul>
                {validationErrors.map((err) => (
                  <li key={err}>{err} </li>
                ))}
              </ul>
            </Alert>
          )}
          <h1>Create new disruption</h1>
          <div>
            <AdjustmentModePicker
              transitMode={transitMode}
              setTransitMode={setTransitMode}
              setAdjustments={setAdjustments}
            />
            <AdjustmentsPicker
              adjustments={adjustments}
              setAdjustments={setAdjustments}
              allAdjustments={allAdjustments}
              transitMode={transitMode}
            />
            {transitMode === TransitMode.CommuterRail && (
              <TripShortNamesForm
                whichTrips={whichTrips}
                setWhichTrips={setWhichTrips}
                tripShortNames={tripShortNames}
                setTripShortNames={setTripShortNames}
              />
            )}
          </div>
          <fieldset>
            <legend>During what time?</legend>
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
          <Button
            variant="primary"
            onClick={() => setIsPreview(true)}
            id="preview-disruption-button"
          >
            preview disruption
          </Button>
        </>
      )}
    </Page>
  )
}

export { NewDisruption }
