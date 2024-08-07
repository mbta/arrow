import React from "react"
import FullCalendar from "@fullcalendar/react"
import dayGridPlugin from "@fullcalendar/daygrid"
import { CalendarOptions } from "@fullcalendar/core"

const DisruptionCalendar = (props: CalendarOptions) => (
  <FullCalendar
    eventOrder="statusOrder,kindOrder,title"
    initialView="dayGridMonth"
    plugins={[dayGridPlugin]}
    {...props}
  />
)

export default DisruptionCalendar
