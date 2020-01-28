import * as React from "react"

import {
  Adjustment,
  formatDisruptionDate,
  indexToDayOfWeekString,
} from "./disruptions"
import { DisruptionSummary } from "./disruptionSummary"
import { DayOfWeekTimeRanges, TimeRange } from "./disruptionTimePicker"

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
      {timeStart} &ndash; {timeEnd}
    </div>
  )
}

interface NewDisruptionPreviewProps {
  adjustments: Adjustment[]
  setIsPreview: React.Dispatch<boolean>
  fromDate: Date | null
  toDate: Date | null
  disruptionDaysOfWeek: DayOfWeekTimeRanges
  exceptionDates: Date[]
}

const NewDisruptionPreview = ({
  adjustments,
  setIsPreview,
  fromDate,
  toDate,
  disruptionDaysOfWeek,
  exceptionDates,
}: NewDisruptionPreviewProps): JSX.Element => {
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
  exceptionDates.forEach(date => {
    listedExceptionDates.push(
      <li key={formatDisruptionDate(date)}>{formatDisruptionDate(date)}</li>
    )
  })

  return (
    <div>
      <DisruptionSummary adjustments={adjustments} />
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
      <a href="#" onClick={() => setIsPreview(false)} id="back-to-edit-link">
        back to edit
      </a>
    </div>
  )
}

export { NewDisruptionPreview }
