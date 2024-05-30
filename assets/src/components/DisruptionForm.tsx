import React, { useState, useMemo } from "react"
import Select from "react-select"
import DatePicker from "./DatePicker"
import TimePicker from "./TimePicker"

// See also the `Adjustment` Elixir module
type AdjustmentKind =
  | "blue_line"
  | "bus"
  | "commuter_rail"
  | "green_line"
  | "green_line_b"
  | "green_line_c"
  | "green_line_d"
  | "green_line_e"
  | "mattapan_line"
  | "orange_line"
  | "red_line"
  | "silver_line"

type Adjustment = { id: number; label: string; kind: AdjustmentKind }
type TimeRange = { start: string | null; end: string | null }
type DaysOfWeek = { [dayName: string]: TimeRange }

type DisruptionRevision = {
  description: string
  startDate: string | null
  endDate: string | null
  rowApproved: boolean
  adjustmentKind: AdjustmentKind | null
  adjustments: Adjustment[]
  daysOfWeek: DaysOfWeek
  exceptions: string[]
  tripShortNames: string,
  title: string
}

const modeAdjustmentKinds = ["bus", "commuter_rail", "silver_line"] as const

const subwayLineAdjustmentKinds = [
  "blue_line",
  "green_line",
  "green_line_b",
  "green_line_c",
  "green_line_d",
  "green_line_e",
  "mattapan_line",
  "orange_line",
  "red_line",
] as const

type Mode = typeof modeAdjustmentKinds[number] | "subway"
type SubwayLine = typeof subwayLineAdjustmentKinds[number]

const days = [
  "monday",
  "tuesday",
  "wednesday",
  "thursday",
  "friday",
  "saturday",
  "sunday",
]

const modeLabels: [Mode, string][] = [
  ["subway", "Subway"],
  ["commuter_rail", "Commuter Rail"],
  ["bus", "Bus"],
  ["silver_line", "Silver Line"],
]

const rowStatusLabels: [boolean, string][] = [
  [true, "Approved"],
  [false, "Pending"],
]

const subwayLineLabels: [SubwayLine, string][] = [
  ["red_line", "Red Line"],
  ["orange_line", "Orange Line"],
  ["blue_line", "Blue Line"],
  ["green_line_b", "Green B"],
  ["green_line_c", "Green C"],
  ["green_line_d", "Green D"],
  ["green_line_e", "Green E"],
  ["green_line", "GL Trunk"],
  ["mattapan_line", "Mattapan"],
]

const whichTripsLabels: ["all" | "some", string][] = [
  ["all", "All Trips"],
  ["some", "Some Trips"],
]

const adjustmentKindForMode = (mode: Mode | null): AdjustmentKind | null =>
  mode === "subway" ? null : mode

const adjustmentMatchesMode = (
  { kind }: Adjustment,
  mode: Mode | null
): boolean => {
  if (mode === "subway") {
    return (subwayLineAdjustmentKinds as readonly string[]).includes(kind)
  } else {
    return kind === mode
  }
}

const adjustmentSelectOption = (adjustment: Adjustment) => {
  return {
    label: adjustment.label,
    value: adjustment.id,
    data: adjustment,
  }
}

const defaultTimeRange = (mode: Mode | null, day: string): TimeRange => {
  if (mode === "subway" && day !== "saturday" && day !== "sunday") {
    return { start: "20:45:00", end: null }
  } else {
    return { start: null, end: null }
  }
}

const initialMode = (
  adjustments: Adjustment[],
  adjustmentKind: AdjustmentKind | null
): Mode | null => {
  if (adjustmentKind !== null) {
    return modeForAdjustmentKind(adjustmentKind)
  } else if (adjustments.length > 0) {
    return modeForAdjustmentKind(adjustments[0].kind)
  } else {
    return null
  }
}

const modeForAdjustmentKind = (adjustmentKind: AdjustmentKind): Mode | null => {
  if ((modeAdjustmentKinds as readonly string[]).includes(adjustmentKind)) {
    return adjustmentKind as Mode
  } else if (
    (subwayLineAdjustmentKinds as readonly string[]).includes(adjustmentKind)
  ) {
    return "subway"
  } else {
    return null
  }
}

interface DisruptionFormProps {
  allAdjustments: Adjustment[]
  disruptionRevision: DisruptionRevision
  iconPaths: { [icon: string]: string }
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
    title: initialTitle,
    description: initialDescription,
    startDate: initialStartDate,
    endDate: initialEndDate,
    rowApproved: initialRowApproved,
    adjustmentKind: initialAdjustmentKind,
    adjustments: initialAdjustments,
    daysOfWeek: initialDaysOfWeek,
    exceptions: initialExceptions,
    tripShortNames: initialTripShortNames,
  },
  iconPaths,
}: DisruptionFormProps) => {
  const [isRowApproved, setIsRowApproved] = useState(initialRowApproved)
  const [title, setTitle] = useState(initialTitle)
  const [description, setDescription] = useState(initialDescription)
  const [adjustmentKind, setAdjustmentKind] = useState(initialAdjustmentKind)
  const [hasAdjustments, setHasAdjustments] = useState(adjustmentKind === null)
  const [adjustments, setAdjustments] = useState(initialAdjustments)

  const [mode, setMode] = useState<Mode | null>(
    initialMode(adjustments, adjustmentKind)
  )

  const adjustmentSelectOptions = useMemo(() => {
    return allAdjustments
      .filter((adjustment) => adjustmentMatchesMode(adjustment, mode))
      .map(adjustmentSelectOption)
  }, [allAdjustments, mode])
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
    const newValue = daysOfWeek.get(day) ? null : defaultTimeRange(mode, day)
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
      <input
        type="hidden"
        name="revision[adjustment_kind]"
        value={adjustmentKind || ""}
      />

      <fieldset>
        <legend>approval status</legend>
        {rowStatusLabels.map(([rowValue, rowLabel]) => (
          <label key={rowLabel} className="form-check form-check-label">
            <input
              className="form-check-input"
              type="radio"
              name="revision[row_approved]"
              value={`${rowValue}`}
              checked={rowValue === isRowApproved}
              onChange={() => {
                setIsRowApproved(rowValue)
              }}
            />
            {rowLabel}
          </label>
        ))}
      </fieldset>

      <fieldset>
        <legend>mode</legend>

        {modeLabels.map(([value, label]) => (
          <label key={value} className="form-check form-check-label">
            <input
              className="form-check-input"
              type="radio"
              name="mode"
              checked={mode === value}
              onChange={() => {
                setMode(value)
                setAdjustments([])
                setAdjustmentKind(adjustmentKindForMode(value))
              }}
            />

            <span
              className="m-icon m-icon-sm mr-1"
              style={{ backgroundImage: `url(${iconPaths[value]})` }}
            ></span>

            {label}
          </label>
        ))}
      </fieldset>

      <fieldset>
        <legend>title</legend>
        <input
          className="form-control"
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          name="revision[title]"
          aria-describedby="titleHelp"
          aria-label="title"
          required
        />
      </fieldset>

      <fieldset>
        <legend>description</legend>
        <textarea
          className="form-control"
          cols={30}
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          name="revision[description]"
          aria-describedby="descriptionHelp"
          aria-label="description"
          required
        />
        <small id="descriptionHelp" className="form-text">
          please include: types of disruption, place, and reason
        </small>
      </fieldset>

      {mode && mode !== "bus" && (
        <fieldset>
          <legend>limits</legend>

          <label className="form-check form-check-label">
            <input
              className="form-check-input"
              type="radio"
              name="limits"
              checked={hasAdjustments}
              onChange={() => {
                setAdjustmentKind(null)
                setHasAdjustments(true)
              }}
            />
            select existing diverted route(s)
          </label>

          {hasAdjustments && (
            <Select
              className="ml-4 mb-4"
              classNamePrefix="adjustment-select"
              name="revision[adjustments][id][]"
              isMulti={true}
              options={adjustmentSelectOptions}
              value={adjustmentSelectValues}
              onChange={(value) => {
                setAdjustments(value.map((option) => option.data))
              }}
            />
          )}

          <label className="form-check form-check-label">
            <input
              className="form-check-input"
              type="radio"
              name="limits"
              checked={!hasAdjustments}
              onChange={() => {
                setAdjustments([])
                setHasAdjustments(false)
              }}
            />
            request a new diverted route
          </label>

          {!hasAdjustments && mode === "subway" && (
            <fieldset className="ml-4">
              <legend className="sr-only">diversion type</legend>

              {subwayLineLabels.map(([line, label]) => (
                <label key={line} className="form-check form-check-label">
                  <input
                    className="form-check-input"
                    type="radio"
                    name="line"
                    value={line}
                    checked={adjustmentKind === line}
                    onChange={() => setAdjustmentKind(line)}
                  />

                  <span
                    className="m-icon m-icon-sm mr-1"
                    style={{ backgroundImage: `url(${iconPaths[line]})` }}
                  ></span>

                  {label}
                </label>
              ))}
            </fieldset>
          )}
        </fieldset>
      )}

      {mode === "commuter_rail" && (
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
                  name={`revision[trip_short_names][${index}][trip_short_name]`}
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
              name={`revision[exceptions][${index}][excluded_date]`}
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
