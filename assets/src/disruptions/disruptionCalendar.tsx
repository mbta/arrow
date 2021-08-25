import * as React from "react"
import FullCalendar from "@fullcalendar/react"
import dayGridPlugin from "@fullcalendar/daygrid"
import { RRule, RRuleSet } from "rrule"
import { getRouteColor } from "./disruptionIndex"
import Disruption from "../models/disruption"
import DisruptionRevision from "../models/disruptionRevision"
import DayOfWeek from "../models/dayOfWeek"
import { toModelObject } from "../jsonApi"

interface DisruptionCalendarProps {
  data: any
  initialDate?: Date
}

const dayNameToInt = (day: DayOfWeek["dayName"]): number => {
  switch (day) {
    case "monday": {
      return 0
    }
    case "tuesday": {
      return 1
    }
    case "wednesday": {
      return 2
    }
    case "thursday": {
      return 3
    }
    case "friday": {
      return 4
    }
    case "saturday": {
      return 5
    }
    case "sunday": {
      return 6
    }
  }
}

const addDay = (date: Date): Date => {
  return new Date(date.setTime(date.getTime() + 60 * 60 * 24 * 1000))
}

// Convert a date to a YYYY-MM-DD string, which FullCalendar will interpret as
// being in the local time zone.
const toISODate = (date: Date): string => date.toISOString().slice(0, 10)

const disruptionsToCalendarEvents = (
  disruptionRevisions: DisruptionRevision[]
) => {
  return disruptionRevisions.reduce(
    (
      disruptionRevisionsAcc: {
        id?: string
        title?: string
        backgroundColor: string
        start: string
        end: string
        url: string
        eventDisplay: "block"
        allDay: true
      }[],
      disruptionRevision: DisruptionRevision
    ) => {
      if (!disruptionRevision.daysOfWeek.length) {
        return disruptionRevisionsAcc
      }
      disruptionRevision.adjustments.forEach((adj) => {
        const ruleSet = new RRuleSet()
        ruleSet.rrule(
          new RRule({
            byweekday: disruptionRevision.daysOfWeek?.map((x) =>
              dayNameToInt(x.dayName)
            ),
            dtstart: disruptionRevision.startDate,
            until: disruptionRevision.endDate,
          })
        )
        disruptionRevision.exceptions.forEach((x) => {
          if (x.excludedDate) {
            ruleSet.exdate(x.excludedDate)
          }
        })

        const dateGroups = ruleSet.all().length
          ? ruleSet.all().reduce(
              (acc, curr) => {
                const last = acc.slice(-1)[0].slice(-1)[0]
                if (
                  !last ||
                  curr.getTime() - last.getTime() === 60 * 60 * 24 * 1000
                ) {
                  acc[acc.length - 1].push(curr)
                } else {
                  acc.push([curr])
                }
                return acc
              },
              [[]] as [Date[]]
            )
          : []
        dateGroups.forEach((group) => {
          disruptionRevisionsAcc.push({
            id: disruptionRevision.id,
            title: adj.sourceLabel,
            backgroundColor: getRouteColor(adj.routeId),
            start: toISODate(group[0]),
            end: toISODate(
              group.length > 1 ? addDay(group.slice(-1)[0]) : group[0]
            ),
            url: `/disruptions/${disruptionRevision.disruptionId}`,
            eventDisplay: "block",
            allDay: true,
          })
        })
      })
      return disruptionRevisionsAcc
    },
    []
  )
}

const DisruptionCalendar = ({ data, initialDate }: DisruptionCalendarProps) => {
  const revisionsOrError = React.useMemo(() => {
    if (Array.isArray(data)) {
      return data
    } else {
      const disruptions = toModelObject(data)

      if (disruptions === "error") {
        return "error"
      } else {
        return (disruptions as Disruption[]).map(
          ({ revisions }) => revisions[0]
        )
      }
    }
  }, [data])

  const calendarEvents = React.useMemo(() => {
    if (revisionsOrError !== "error") {
      return disruptionsToCalendarEvents(
        revisionsOrError as DisruptionRevision[]
      )
    } else {
      return []
    }
  }, [revisionsOrError])

  return (
    <div id="calendar" className="my-3">
      {revisionsOrError === "error" && "Error loading calendar events!"}
      <FullCalendar
        initialDate={initialDate}
        plugins={[dayGridPlugin]}
        initialView="dayGridMonth"
        events={calendarEvents}
      />
    </div>
  )
}

export { DisruptionCalendar, disruptionsToCalendarEvents, dayNameToInt }
