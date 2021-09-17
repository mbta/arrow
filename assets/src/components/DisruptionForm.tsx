import React, { useState, useMemo } from "react"
import Select from "react-select"
import DatePicker from "./DatePicker"
import TimePicker from "./TimePicker"

enum TransitMode {
  Subway,
  CommuterRail,
}

type TimeRange = { start: string | null; end: string | null }
type Adjustment = { id: number; label: string; routeId: string }
type DaysOfWeek = { [dayName: string]: TimeRange }
type DisruptionRevision = {
  startDate: string | null
  endDate: string | null
  adjustments: Adjustment[]
  daysOfWeek: DaysOfWeek
  exceptions: string[]
  tripShortNames: string
}

const days = [
  "monday",
  "tuesday",
  "wednesday",
  "thursday",
  "friday",
  "saturday",
  "sunday",
]

const transitModeLabels: [TransitMode, string][] = [
  [TransitMode.Subway, "Subway"],
  [TransitMode.CommuterRail, "Commuter Rail"],
]

const whichTripsLabels: ["all" | "some", string][] = [
  ["all", "All Trips"],
  ["some", "Some Trips"],
]

const adjustmentSelectOption = (adjustment: Adjustment) => {
  return {
    label: adjustment.label,
    value: adjustment.id,
    data: adjustment,
  }
}

const modeForRoute = (route: string): TransitMode =>
  route.startsWith("CR-") ? TransitMode.CommuterRail : TransitMode.Subway

interface DisruptionFormProps {
  allAdjustments: Adjustment[]
  disruptionRevision: DisruptionRevision
}

/**
 * Provides form fields for creating a new disruption revision, with specified
 * initial values. All fields have input tags (directly or via hidden inputs)
 * named `revision[...]`, to enable normal browser form submission when inside
 * a form tag (not included).
 */

const DisruptionForm = ({
  allAdjustments,
  disruptionRevision: {
    startDate: initialStartDate,
    endDate: initialEndDate,
    adjustments: initialAdjustments,
    daysOfWeek: initialDaysOfWeek,
    exceptions: initialExceptions,
    tripShortNames: initialTripShortNames,
  },
}: DisruptionFormProps) => {
  const [transitMode, setTransitMode] = useState<TransitMode>(
    initialAdjustments.length === 0
      ? TransitMode.Subway
      : modeForRoute(initialAdjustments[0].routeId)
  )

  const [adjustments, setAdjustments] = useState(initialAdjustments)
  const adjustmentSelectOptions = useMemo(() => {
    return allAdjustments
      .filter((adjustment) => modeForRoute(adjustment.routeId) === transitMode)
      .map(adjustmentSelectOption)
  }, [allAdjustments, transitMode])
  const adjustmentSelectValues = useMemo(
    () => adjustments.map(adjustmentSelectOption),
    [adjustments]
  )

  const [whichTrips, setWhichTrips] = useState<"all" | "some">(
    initialTripShortNames === "" ? "all" : "some"
  )
  const [tripShortNames, setTripShortNames] = useState(initialTripShortNames)

  const [daysOfWeek, setDaysOfWeek] = useState<Map<string, TimeRange | null>>(
    new Map(days.map((day) => [day, initialDaysOfWeek[day] || null]))
  )
  const toggleDayOfWeek = (day: string) => {
    const newValue = daysOfWeek.get(day) ? null : { start: null, end: null }
    setDaysOfWeek((prev) => new Map(prev).set(day, newValue))
  }

  const [exceptions, setExceptions] =
    useState<(string | null)[]>(initialExceptions)

  const updateException = (index: number, date: string | null) =>
    setExceptions(
      exceptions
        .slice(0, index)
        .concat([date])
        .concat(exceptions.slice(index + 1))
    )

  const removeException = (index: number) =>
    setExceptions(
      exceptions.slice(0, index).concat(exceptions.slice(index + 1))
    )

  return (
    <>
      <fieldset>
        <legend>mode</legend>

        {transitModeLabels.map(([mode, label]) => (
          <label key={mode} className="form-check form-check-label">
            <input
              className="form-check-input"
              type="radio"
              name="mode"
              checked={transitMode === mode}
              onChange={() => {
                setAdjustments([])
                setTransitMode(mode)
              }}
            />
            {label}
          </label>
        ))}
      </fieldset>

      <fieldset>
        <legend>adjustment location</legend>

        <Select
          classNamePrefix="adjustment-select"
          name="revision[adjustments][][id]"
          isMulti={true}
          options={adjustmentSelectOptions}
          value={adjustmentSelectValues}
          onChange={(value) => {
            setAdjustments(value.map((option) => option.data))
          }}
        />
      </fieldset>

      {transitMode === TransitMode.CommuterRail && (
        <fieldset>
          <legend>trips</legend>

          {whichTripsLabels.map(([which, label]) => (
            <label key={which} className="form-check form-check-label">
              <input
                className="form-check-input"
                type="radio"
                name="which"
                checked={whichTrips === which}
                onChange={() => {
                  setTripShortNames("")
                  setWhichTrips(which)
                }}
              />
              {label}
            </label>
          ))}

          {whichTrips === "some" && (
            <div className="form-group">
              <input
                className="form-control mb-3"
                type="text"
                aria-label="Trip short names"
                placeholder="Enter comma-separated trip short names"
                value={tripShortNames}
                onChange={(event) => setTripShortNames(event.target.value)}
              />

              {tripShortNames.split(/\s*,\s*/).map((name, index) => (
                <input
                  key={index}
                  type="hidden"
                  name="revision[trip_short_names][][trip_short_name]"
                  value={name}
                />
              ))}
            </div>
          )}
        </fieldset>
      )}

      <fieldset>
        <legend>date range</legend>

        <div className="row">
          <div className="col-lg-4">
            {/*
              react-datepicker does not work correctly when wrapped in a label,
              see: https://github.com/Hacker0x01/react-datepicker/issues/1012
            */}
            <div>
              <label htmlFor="start-date-input">start</label>
            </div>
            <DatePicker
              id="start-date-input"
              name="revision[start_date]"
              required={true}
              selected={initialStartDate}
            />
          </div>

          <div className="col">
            <div>
              <label htmlFor="end-date-input">end</label>
            </div>
            <DatePicker
              id="end-date-input"
              name="revision[end_date]"
              required={true}
              selected={initialEndDate}
            />
          </div>
        </div>
      </fieldset>

      <fieldset>
        <legend>time period</legend>

        <fieldset>
          <legend>Choose days of week</legend>

          {days.map((day) => (
            <span key={day} className="m-disruption-form__day-of-week">
              <div className="form-check form-check-inline">
                <input
                  id={`day-input-${day}`}
                  className="form-check-input"
                  type="checkbox"
                  checked={daysOfWeek.get(day) !== null}
                  onChange={() => toggleDayOfWeek(day)}
                />

                <label
                  className="form-check-label"
                  htmlFor={`day-input-${day}`}
                >
                  {day.slice(0, 1).toUpperCase() + day.slice(1, 3)}
                </label>
              </div>
            </span>
          ))}
        </fieldset>

        {days
          .filter((day) => daysOfWeek.get(day) !== null)
          .map((day, index) => (
            <fieldset key={day}>
              <legend>{day.slice(0, 1).toUpperCase() + day.slice(1)}</legend>

              <input
                type="hidden"
                name={`revision[days_of_week][${index}][day_name]`}
                value={day}
              />

              <div className="row">
                <div className="col-5">
                  <TimePicker
                    id={`${day}-start-input`}
                    name={`revision[days_of_week][${index}][start_time]`}
                    initialValue={(daysOfWeek.get(day) as TimeRange).start}
                    ariaLabel="start"
                    nullLabel="Start of service"
                  />
                </div>
                until
                <div className="col-5">
                  <TimePicker
                    id={`${day}-end-input`}
                    name={`revision[days_of_week][${index}][end_time]`}
                    initialValue={(daysOfWeek.get(day) as TimeRange).end}
                    ariaLabel="end"
                    nullLabel="End of service"
                  />
                </div>
              </div>
            </fieldset>
          ))}
      </fieldset>

      <fieldset>
        <legend>exceptions</legend>

        {exceptions.map((exception, index) => (
          <div key={index} className="row mb-2 ml-0">
            <DatePicker
              name="revision[exceptions][][excluded_date]"
              required={true}
              selected={exception}
              excludeDates={exceptions.filter((e) => e !== null) as string[]}
              onChange={(date) => updateException(index, date)}
            />

            <button
              aria-label="remove"
              className="btn btn-link"
              onClick={(event) => {
                event.preventDefault()
                removeException(index)
              }}
            >
              &#xe161;
            </button>
          </div>
        ))}

        {(exceptions.length === 0 || exceptions.slice(-1)[0] !== null) && (
          <div className="row">
            <button
              className="btn btn-link"
              onClick={(event) => {
                event.preventDefault()
                setExceptions(exceptions.concat([null]))
              }}
            >
              &#xe15f; add an exception
            </button>
          </div>
        )}
      </fieldset>
    </>
  )
}

export default DisruptionForm
