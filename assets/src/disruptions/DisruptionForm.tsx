import * as React from "react"
import Form from "react-bootstrap/form"
import Select, { ValueType } from "react-select"

interface Adjustment {
  id: string
  routeId: string
  sourceLabel: string
}

enum TransitMode {
  Subway,
  CR,
}

const modeForRoute = (route: string): TransitMode => {
  if (route.startsWith("CR-")) {
    return TransitMode.CR
  } else {
    return TransitMode.Subway
  }
}

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
          checked={transitMode === TransitMode.CR}
          onChange={() => {
            setAdjustments([])
            setTransitMode(TransitMode.CR)
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
      <div className="row">
        <div className="col-lg-10">
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
        </div>
      </div>
    </fieldset>
  )
}

interface DisruptionFormProps {
  disruptionId: string
  initialAdjustments: Adjustment[]
  allAdjustments: Adjustment[]
}

function DisruptionForm({
  disruptionId,
  initialAdjustments,
  allAdjustments,
}: DisruptionFormProps): JSX.Element {
  const [adjustments, setAdjustments] =
    React.useState<Adjustment[]>(initialAdjustments)

  let initialTransitMode: TransitMode = TransitMode.Subway

  const adjustment = adjustments[0]
  if (adjustment) {
    initialTransitMode = modeForRoute(adjustment.routeId)
  }

  const [transitMode, setTransitMode] =
    React.useState<TransitMode>(initialTransitMode)

  return (
    <>
      <h1>disruption {disruptionId}</h1>
      <div>
        <h4>mode</h4>
        <AdjustmentModePicker
          transitMode={transitMode}
          setTransitMode={setTransitMode}
          setAdjustments={setAdjustments}
        />
      </div>
      <div>
        <h4>adjustment location</h4>
        <div className="pl-4">
          <input
            type="hidden"
            name="disruption-adjustments"
            value={adjustments.map((a) => a.id).join(",")}
          />
          <AdjustmentsPicker
            adjustments={adjustments}
            setAdjustments={setAdjustments}
            allAdjustments={allAdjustments}
            transitMode={transitMode}
          />
        </div>
      </div>
      <input
        type="submit"
        value="save"
        className="btn btn-primary btn-outline"
      />
    </>
  )
}

interface DisruptionFormWrapperProps {
  disruptionId: string
  adjustments: Adjustment[]
  allAdjustments: Adjustment[]
}

export default function DisruptionFormWrapper({
  disruptionId,
  adjustments,
  allAdjustments,
}: DisruptionFormWrapperProps): JSX.Element {
  return (
    <DisruptionForm
      disruptionId={disruptionId}
      initialAdjustments={adjustments}
      allAdjustments={allAdjustments}
    />
  )
}
