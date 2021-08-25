import "phoenix_html"
import ReactPhoenix from "./ReactPhoenix"

import EditDisruption from "./disruptions/editDisruption"
import { NewDisruption } from "./disruptions/newDisruption"
import ViewDisruption from "./disruptions/viewDisruption"
import { DisruptionCalendar } from "./disruptions/disruptionCalendar"

declare global {
  interface Window {
    Components: {
      [name: string]: (props: any) => JSX.Element
    }
  }
}

window.Components = {
  DisruptionCalendar,
  NewDisruption,
  ViewDisruption,
  EditDisruption,
}

ReactPhoenix.init()
