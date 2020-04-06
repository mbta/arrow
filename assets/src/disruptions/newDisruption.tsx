import * as React from "react"

import Button from "react-bootstrap/Button"
import Form from "react-bootstrap/Form"

import { DayOfWeekTimeRanges, TimeRange } from "./time"
import { DisruptionTimePicker } from "./disruptionTimePicker"
import { apiGet } from "../api"

import { TransitMode, modeForRoute } from "./disruptions"
import Header from "../header"
import Loading from "../loading"
import { DisruptionPreview } from "./disruptionPreview"

import Adjustment from "../models/adjustment"
import { toModelObject, ModelObject } from "../jsonApi"

interface AdjustmentModePickerProps {
  transitMode: TransitMode
  setTransitMode: React.Dispatch<TransitMode>
  setAdjustments: React.Dispatch<Adjustment[]>
  setIsAddingAdjustment: React.Dispatch<boolean>
}

const AdjustmentModePicker = ({
  transitMode,
  setTransitMode,
  setAdjustments,
  setIsAddingAdjustment,
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
            setIsAddingAdjustment(true)
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
            setIsAddingAdjustment(true)
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
  isAddingAdjustment: boolean
  setIsAddingAdjustment: React.Dispatch<boolean>
}

const AdjustmentsPicker = ({
  allAdjustments,
  transitMode,
  adjustments,
  setAdjustments,
  isAddingAdjustment,
  setIsAddingAdjustment,
}: AdjustmentsPickerProps): JSX.Element => {
  const modeAdjustments = allAdjustments.filter(
    adjustment =>
      adjustment.routeId && modeForRoute(adjustment.routeId) === transitMode
  )

  const appendAdjustment = (evt: React.FormEvent) => {
    const val = (evt.target as HTMLSelectElement).value
    const adjustmentForLabel = allAdjustments.find(a => val === a.sourceLabel)

    if (adjustmentForLabel) {
      setIsAddingAdjustment(false)
      setAdjustments(adjustments.slice().concat([adjustmentForLabel]))
    }
  }

  const updateAdjustment = (evt: React.FormEvent, i: number) => {
    const val = (evt.target as HTMLSelectElement).value
    const adjustmentForLabel = allAdjustments.find(a => val === a.sourceLabel)

    if (adjustmentForLabel) {
      setAdjustments(
        adjustments
          .slice(0, i)
          .concat([adjustmentForLabel])
          .concat(adjustments.slice(i + 1))
      )
    }
  }

  const deleteAdjustment = (i: number) => {
    setAdjustments(adjustments.slice(0, i).concat(adjustments.slice(i + 1)))
  }

  return (
    <fieldset>
      <legend>For which locations?</legend>
      <Form.Group>
        {adjustments.map((adjustment, i) => {
          return (
            <Form.Row key={adjustment.sourceLabel}>
              <Form.Control
                as="select"
                id={"adjustment-select-" + i}
                value={adjustment.sourceLabel}
                onChange={evt => updateAdjustment(evt, i)}
              >
                {modeAdjustments
                  .filter(
                    modeAdjustment =>
                      adjustments.findIndex(
                        a => modeAdjustment.sourceLabel === a.sourceLabel
                      ) === -1
                  )
                  .map(a => (
                    <option key={a.sourceLabel}>{a.sourceLabel}</option>
                  ))}
                <option>{adjustment.sourceLabel}</option>
              </Form.Control>
              <button
                className="btn btn-link"
                id={"adjustment-delete-" + i}
                onClick={() => deleteAdjustment(i)}
              >
                delete
              </button>
            </Form.Row>
          )
        })}
        {!isAddingAdjustment ? (
          <button
            id="add-another-adjustment-link"
            className="btn btn-link"
            onClick={() => setIsAddingAdjustment(true)}
          >
            + another
          </button>
        ) : (
          <Form.Row>
            <Form.Control
              as="select"
              id={"adjustment-select-" + adjustments.length}
              onChange={appendAdjustment}
            >
              <option>Choose Location</option>
              {modeAdjustments
                .filter(
                  modeAdjustment =>
                    adjustments.findIndex(
                      a => modeAdjustment.sourceLabel === a.sourceLabel
                    ) === -1
                )
                .map(modeAdjustment => (
                  <option key={modeAdjustment.sourceLabel}>
                    {modeAdjustment.sourceLabel}
                  </option>
                ))}
            </Form.Control>
          </Form.Row>
        )}
      </Form.Group>
    </fieldset>
  )
}

interface AdjustmentFormProps {
  adjustments: Adjustment[]
  setAdjustments: React.Dispatch<Adjustment[]>
  allAdjustments: Adjustment[]
}

const AdjustmentForm = ({
  adjustments,
  setAdjustments,
  allAdjustments,
}: AdjustmentFormProps): JSX.Element => {
  const [transitMode, setTransitMode] = React.useState<TransitMode>(
    TransitMode.Subway
  )
  const [isAddingAdjustment, setIsAddingAdjustment] = React.useState<boolean>(
    adjustments.length === 0
  )

  return (
    <div>
      <AdjustmentModePicker
        transitMode={transitMode}
        setTransitMode={setTransitMode}
        setAdjustments={setAdjustments}
        setIsAddingAdjustment={setIsAddingAdjustment}
      />
      <AdjustmentsPicker
        adjustments={adjustments}
        setAdjustments={setAdjustments}
        allAdjustments={allAdjustments}
        transitMode={transitMode}
        isAddingAdjustment={isAddingAdjustment}
        setIsAddingAdjustment={setIsAddingAdjustment}
      />
    </div>
  )
}

const NewDisruption = ({}): JSX.Element => {
  const [adjustments, setAdjustments] = React.useState<Adjustment[]>([])
  const [fromDate, setFromDate] = React.useState<Date | null>(null)
  const [toDate, setToDate] = React.useState<Date | null>(null)
  const [disruptionDaysOfWeek, setDisruptionDaysOfWeek] = React.useState<
    DayOfWeekTimeRanges
  >([null, null, null, null, null, null, null])
  const [exceptionDates, setExceptionDates] = React.useState<Date[]>([])
  const [isPreview, setIsPreview] = React.useState<boolean>(false)
  const [allAdjustments, setAllAdjustments] = React.useState<
    Adjustment[] | "error" | null
  >(null)

  React.useEffect(() => {
    apiGet<ModelObject | ModelObject[] | "error">({
      url: "/api/adjustments",
      parser: toModelObject,
      defaultResult: "error",
    }).then((result: ModelObject | ModelObject[] | "error") => {
      if (
        Array.isArray(result) &&
        result.every(res => res instanceof Adjustment)
      ) {
        setAllAdjustments(result)
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

  return (
    <div>
      <Header />
      {isPreview ? (
        <DisruptionPreview
          adjustments={adjustments}
          setIsPreview={setIsPreview}
          fromDate={fromDate}
          toDate={toDate}
          disruptionDaysOfWeek={disruptionDaysOfWeek}
          exceptionDates={exceptionDates}
        />
      ) : (
        <>
          <h1>Create new disruption</h1>
          <AdjustmentForm
            adjustments={adjustments}
            setAdjustments={setAdjustments}
            allAdjustments={allAdjustments}
          />
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
    </div>
  )
}

export { NewDisruption, TimeRange }
