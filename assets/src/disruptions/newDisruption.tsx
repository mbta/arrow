import * as React from "react"

import Select, { ValueType } from "react-select"

import { PrimaryButton } from "../button"
import Form from "react-bootstrap/Form"
import Alert from "react-bootstrap/Alert"
import Col from "react-bootstrap/Col"
import Row from "react-bootstrap/Row"

import { apiGet, apiSend } from "../api"
import { toModelObject, JsonApiResponse, parseErrors } from "../jsonApi"
import { redirectTo } from "../navigation"
import DisruptionRevision from "../models/disruptionRevision"
import Adjustment from "../models/adjustment"
import Exception from "../models/exception"
import { DayOfWeekTimeRanges, dayOfWeekTimeRangesToDayOfWeeks } from "./time"

import Loading from "../loading"
import { ConfirmationModal } from "../confirmationModal"
import { DisruptionTimePicker } from "./disruptionTimePicker"
import { DisruptionDateRange } from "./disruptionDateRange"
import { TransitMode, modeForRoute } from "./disruptions"
import TripShortName from "../models/tripShortName"
import { DisruptionExceptionDates } from "./disruptionExceptionDates"

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
      <Row>
        <Col lg={10}>
          <Form.Group>
            <Select<AdjustmentPickerOption, true>
              inputId="adjustment-select"
              classNamePrefix="adjustment-select"
              onChange={(value: ValueType<AdjustmentPickerOption, true>) => {
                if (Array.isArray(value)) {
                  setAdjustments(value.map((adj) => adj.data))
                } else {
                  setAdjustments([])
                }
              }}
              value={modeAdjustmentValues}
              options={modeAdjustmentOptions}
              isMulti={true}
            />
          </Form.Group>
        </Col>
      </Row>
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

const createFn = async (args: ApiCreateDisruptionParams) => {
  const disruptionRevision = disruptionRevisionFromState(args)

  return await apiSend({
    url: "/api/disruptions",
    method: "POST",
    json: JSON.stringify(disruptionRevision.toJsonApi()),
    successParser: toModelObject,
    errorParser: parseErrors,
  })
}

const NewDisruption = ({}): JSX.Element => {
  const [adjustments, setAdjustments] = React.useState<Adjustment[]>([])
  const [fromDate, setFromDate] = React.useState<Date | null>(null)
  const [toDate, setToDate] = React.useState<Date | null>(null)
  const [disruptionDaysOfWeek, setDisruptionDaysOfWeek] =
    React.useState<DayOfWeekTimeRanges>([
      null,
      null,
      null,
      null,
      null,
      null,
      null,
    ])
  const [exceptionDates, setExceptionDates] = React.useState<Date[]>([])
  const [tripShortNames, setTripShortNames] = React.useState<string>("")
  const [allAdjustments, setAllAdjustments] = React.useState<
    Adjustment[] | "error" | null
  >(null)
  const [validationErrors, setValidationErrors] = React.useState<string[]>([])
  const [doRedirect, setDoRedirect] = React.useState<boolean>(false)
  const [transitMode, setTransitMode] = React.useState<TransitMode>(
    TransitMode.Subway
  )
  const [whichTrips, setWhichTrips] = React.useState<"all" | "some">("all")

  const createDisruption = React.useCallback(async () => {
    const result = await createFn({
      adjustments,
      fromDate,
      toDate,
      disruptionDaysOfWeek,
      exceptionDates,
      tripShortNames,
    })

    if (result.ok) {
      setDoRedirect(true)
    } else if (result.error) {
      setValidationErrors(result.error)
    }
  }, [
    adjustments,
    fromDate,
    toDate,
    disruptionDaysOfWeek,
    exceptionDates,
    tripShortNames,
  ])

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
    redirectTo("/")
  }

  return (
    <>
      <Col lg={8}>
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
        <h1>create new disruption</h1>
        <div>
          <h4>mode</h4>
          <div className="pl-4">
            <AdjustmentModePicker
              transitMode={transitMode}
              setTransitMode={setTransitMode}
              setAdjustments={setAdjustments}
            />
          </div>
        </div>
        <div>
          <h4>adjustment location</h4>
          <div className="pl-4">
            <AdjustmentsPicker
              adjustments={adjustments}
              setAdjustments={setAdjustments}
              allAdjustments={allAdjustments}
              transitMode={transitMode}
            />
          </div>
        </div>
        {transitMode === TransitMode.CommuterRail && (
          <div>
            <h4>trips</h4>
            <div className="pl-4">
              <TripShortNamesForm
                whichTrips={whichTrips}
                setWhichTrips={setWhichTrips}
                tripShortNames={tripShortNames}
                setTripShortNames={setTripShortNames}
              />
            </div>
          </div>
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
              onClick={createDisruption}
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
                redirectTo("/")
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
    </>
  )
}

export { NewDisruption }
