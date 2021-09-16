import React from "react"
import FullCalendar from "@fullcalendar/react"
import dayGridPlugin from "@fullcalendar/daygrid"
import { CalendarOptions } from "@fullcalendar/common"

const DisruptionCalendar = (props: CalendarOptions) => (
  <FullCalendar
    initialView="dayGridMonth"
    plugins={[dayGridPlugin]}
    {...props}
  />
)

export default DisruptionCalendar
