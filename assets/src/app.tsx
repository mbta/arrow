// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
import LiveReact from "./LiveReactPhoenix"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

import ReactPhoenix from "./ReactPhoenix"
import DisruptionCalendar from "./components/DisruptionCalendar"
import DisruptionForm from "./components/DisruptionForm"
import ShapeViewMap from "./components/ShapeViewMap"
import StopViewMap from "./components/StopViewMap"

declare global {
  interface Window {
    liveSocket: LiveSocket
    Components: {
      [name: string]: (props: any) => JSX.Element
    }
  }
}

// https://github.com/fidr/phoenix_live_react
const hooks = { LiveReact }

const csrfToken = document
  .querySelector("meta[name='csrf-token']")!
  .getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  hooks,
  longPollFallbackMs: location.host.startsWith("localhost") ? undefined : 2500,
  params: { _csrf_token: csrfToken },
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

window.Components = {
  DisruptionCalendar,
  DisruptionForm,
  ShapeViewMap,
  StopViewMap,
}

ReactPhoenix.init()
