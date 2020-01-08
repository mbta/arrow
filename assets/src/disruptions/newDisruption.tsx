import * as React from "react"

import Button from "react-bootstrap/Button"
import Form from "react-bootstrap/Form"

import {
  DayOfWeekTimeRanges,
  DisruptionTimePicker,
  TimeRange,
} from "./disruptionTimePicker"

import { Adjustment, TransitMode } from "./disruptions"

import Header from "../header"
import { NewDisruptionPreview } from "./newDisruptionPreview"

const modeForRoute = (route: string): TransitMode => {
  switch (route) {
    case "Red":
      return TransitMode.Subway
    case "Green-D":
      return TransitMode.Subway
    case "CR-Fairmount":
      return TransitMode.CommuterRail
    default:
      return TransitMode.Subway
  }
}

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
    adjustment => modeForRoute(adjustment.route) === transitMode
  )

  const appendAdjustment = (evt: React.FormEvent) => {
    const val = (evt.target as HTMLSelectElement).value
    const adjustmentForLabel = allAdjustments.find(a => val === a.label)

    if (adjustmentForLabel) {
      setIsAddingAdjustment(false)
      setAdjustments(adjustments.slice().concat([adjustmentForLabel]))
    }
  }

  const updateAdjustment = (evt: React.FormEvent, i: number) => {
    const val = (evt.target as HTMLSelectElement).value
    const adjustmentForLabel = allAdjustments.find(a => val === a.label)

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
            <Form.Row key={adjustment.label}>
              <Form.Control
                as="select"
                id={"adjustment-select-" + i}
                value={adjustment.label}
                onChange={evt => updateAdjustment(evt, i)}
              >
                {modeAdjustments
                  .filter(
                    modeAdjustment =>
                      adjustments.findIndex(
                        a => modeAdjustment.label === a.label
                      ) === -1
                  )
                  .map(a => (
                    <option key={a.label}>{a.label}</option>
                  ))}
                <option>{adjustment.label}</option>
              </Form.Control>
              <a
                href="#"
                id={"adjustment-delete-" + i}
                onClick={() => deleteAdjustment(i)}
              >
                delete
              </a>
            </Form.Row>
          )
        })}
        {!isAddingAdjustment ? (
          <a
            href="#"
            id="add-another-adjustment-link"
            onClick={() => setIsAddingAdjustment(true)}
          >
            + another
          </a>
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
                      a => modeAdjustment.label === a.label
                    ) === -1
                )
                .map(modeAdjustment => (
                  <option key={modeAdjustment.label}>
                    {modeAdjustment.label}
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

  const allAdjustments: Adjustment[] = [
    { label: "Broadway--Kendall/MIT", route: "Red" },
    { label: "Kenmore--Newton Highlands", route: "Green-D" },
    { label: "Fairmount--Newmarket", route: "CR-Fairmount" },
  ]

  return (
    <div>
      <Header />
      {isPreview ? (
        <NewDisruptionPreview
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
