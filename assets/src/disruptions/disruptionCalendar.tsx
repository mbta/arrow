import * as React from "react"
import FullCalendar from "@fullcalendar/react"
import dayGridPlugin from "@fullcalendar/daygrid"
import { RRule, RRuleSet } from "rrule"
import { getRouteColor } from "./disruptionIndex"
import Disruption from "../models/disruption"
import DayOfWeek from "../models/dayOfWeek"

interface DisruptionCalendarProps {
  disruptions: Disruption[]
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

export const disruptionsToCalendarEvents = (disruptions: Disruption[]) => {
  return disruptions.reduce(
    (
      disruptionsAcc: {
        id?: string
        title?: string
        backgroundColor: string
        start: Date
        end: Date
        url: string
        eventDisplay: "block"
        allDay: true
      }[],
      disruption: Disruption
    ) => {
      if (!disruption.daysOfWeek.length) {
        return disruptionsAcc
      }
      disruption.adjustments.forEach((adj) => {
        const ruleSet = new RRuleSet()
        ruleSet.rrule(
          new RRule({
            byweekday: disruption.daysOfWeek?.map((x) =>
              dayNameToInt(x.dayName)
            ),
            dtstart: disruption.startDate,
            until: disruption.endDate,
          })
        )
        disruption.exceptions.forEach((x) => {
          const excludedDate = x.excludedDate
          if (excludedDate) {
            ruleSet.exdate(excludedDate)
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
          disruptionsAcc.push({
            id: disruption.id,
            title: adj.sourceLabel,
            backgroundColor: getRouteColor(adj.routeId),
            start: group[0],
            end: group.length > 1 ? addDay(group.slice(-1)[0]) : group[0],
            url: `/disruptions/${disruption.id}`,
            eventDisplay: "block",
            allDay: true,
          })
        })
      })
      return disruptionsAcc
    },
    []
  )
}

export const DisruptionCalendar = ({
  disruptions,
  initialDate,
}: DisruptionCalendarProps) => {
  const calendarEvents = React.useMemo(() => {
    return disruptionsToCalendarEvents(disruptions)
  }, [disruptions])
  return (
    <div id="calendar" className="mb-3">
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
