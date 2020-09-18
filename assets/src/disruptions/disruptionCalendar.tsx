import * as React from "react"
import FullCalendar from "@fullcalendar/react"
import dayGridPlugin from "@fullcalendar/daygrid"
import { RRule, RRuleSet } from "rrule"
import { getRouteColor } from "./disruptionIndex"
import DisruptionRevision from "../models/disruptionRevision"
import { DisruptionView } from "../models/disruption"
import DayOfWeek from "../models/dayOfWeek"
import { useDisruptionViewParam } from "./viewToggle"

interface DisruptionCalendarProps {
  disruptionRevisions: DisruptionRevision[]
  initialDate?: Date
  timeZone?: string
}

export const dayNameToInt = (day: DayOfWeek["dayName"]): number => {
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

export const disruptionsToCalendarEvents = (
  disruptionRevisions: DisruptionRevision[],
  view: DisruptionView
) => {
  return disruptionRevisions.reduce(
    (
      disruptionRevisionsAcc: {
        id?: string
        title?: string
        backgroundColor: string
        start: Date
        end: Date
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
            start: group[0],
            end: group.length > 1 ? addDay(group.slice(-1)[0]) : group[0],
            url:
              `/disruptions/${disruptionRevision.disruptionId}` +
              (view === DisruptionView.Draft ? "?v=draft" : ""),
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

export const DisruptionCalendar = ({
  disruptionRevisions,
  initialDate,
}: DisruptionCalendarProps) => {
  const view = useDisruptionViewParam()
  const calendarEvents = React.useMemo(() => {
    return disruptionsToCalendarEvents(disruptionRevisions, view)
  }, [disruptionRevisions, view])
  return (
    <div id="calendar" className="my-3">
      <FullCalendar
        initialDate={initialDate}
        timeZone="UTC"
        plugins={[dayGridPlugin]}
        initialView="dayGridMonth"
        events={calendarEvents}
      />
    </div>
  )
}
