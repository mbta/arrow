import "phoenix_html"

import ReactPhoenix from "./ReactPhoenix"
import DisruptionCalendar from "./components/DisruptionCalendar"
import DisruptionForm from "./components/DisruptionForm"

declare global {
  interface Window {
    Components: {
      [name: string]: (props: any) => JSX.Element
    }
  }
}

window.Components = { DisruptionCalendar, DisruptionForm }

ReactPhoenix.init()
