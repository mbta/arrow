import * as React from "react"

import { formatDisruptionDate, indexToDayOfWeekString } from "./disruptions"
import { DisruptionSummary } from "./disruptionSummary"
import { DayOfWeekTimeRanges, TimeRange } from "./time"
import Adjustment from "../models/adjustment"

interface DayOfWeekPreviewProps {
  dayIndex: number
  timeRange: TimeRange
}

const DayOfWeekPreview = ({
  dayIndex,
  timeRange,
}: DayOfWeekPreviewProps): JSX.Element => {
  const [timeStart, timeEnd] = timeRange
  return (
    <div>
      <span className="m-new-disruption-preview__day_label">
        {indexToDayOfWeekString(dayIndex)}
      </span>
      {timeStart
        ? `${timeStart.hour}:${timeStart.minute}${timeStart.period}`
        : "Start of service"}{" "}
      &ndash;{" "}
      {timeEnd
        ? `${timeEnd.hour}:${timeEnd.minute}${timeEnd.period}`
        : "End of service"}
    </div>
  )
}

interface DisruptionPreviewProps {
  disruptionId?: string
  adjustments: Adjustment[]
  setIsPreview?: React.Dispatch<boolean>
  fromDate: Date | null
  toDate: Date | null
  disruptionDaysOfWeek: DayOfWeekTimeRanges
  exceptionDates: Date[]
  createFn?: any
}

const DisruptionPreview = ({
  disruptionId,
  adjustments,
  setIsPreview,
  fromDate,
  toDate,
  disruptionDaysOfWeek,
  exceptionDates,
  createFn,
}: DisruptionPreviewProps): JSX.Element => {
  const listedDays: JSX.Element[] = []
  disruptionDaysOfWeek.forEach((timeRange, i) => {
    if (timeRange !== null) {
      listedDays.push(
        <li className="m-new-disruption-preview__dow" key={i}>
          <DayOfWeekPreview dayIndex={i} timeRange={timeRange} />
        </li>
      )
    }
  })

  const listedExceptionDates: JSX.Element[] = []
  exceptionDates.forEach((date) => {
    listedExceptionDates.push(
      <li key={formatDisruptionDate(date)}>{formatDisruptionDate(date)}</li>
    )
  })

  const createDisruption = React.useCallback(() => {
    createFn({
      adjustments,
      fromDate,
      toDate,
      disruptionDaysOfWeek,
      exceptionDates,
    })
  }, [
    createFn,
    adjustments,
    fromDate,
    toDate,
    disruptionDaysOfWeek,
    exceptionDates,
  ])

  return (
    <div>
      <DisruptionSummary
        disruptionId={disruptionId}
        adjustments={adjustments}
      />
      <h2>When</h2>
      <p>
        {formatDisruptionDate(fromDate)} &ndash; {formatDisruptionDate(toDate)}
      </p>
      <ul className="m-new-disruption-preview__dow_list">{listedDays}</ul>
      <h3>Date Exceptions</h3>
      {listedExceptionDates.length > 0 ? (
        <ul>{listedExceptionDates}</ul>
      ) : (
        <div>none</div>
      )}
      {createFn && (
        <div>
          <button id="disruption-preview-create" onClick={createDisruption}>
            create disruption
          </button>
        </div>
      )}
      {setIsPreview && (
        <a href="#" onClick={() => setIsPreview(false)} id="back-to-edit-link">
          back to edit
        </a>
      )}
    </div>
  )
}

export { DisruptionPreview }
