// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
import LiveReact from "./LiveReactPhoenix"
import live_select from "live_select"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket, ViewHook } from "phoenix_live_view"
import Sortable from "sortablejs"

import ReactPhoenix from "./ReactPhoenix"
import DisruptionCalendar from "./components/DisruptionCalendar"
import DisruptionForm from "./components/DisruptionForm"
import ShapeViewMap from "./components/ShapeViewMap"
import StopViewMap from "./components/stops/StopViewMap"
import ShapeStopViewMap from "./components/ShapeStopViewMap"

declare global {
  interface Window {
    liveSocket: LiveSocket
    Components: {
      [name: string]: (props: any) => JSX.Element
    }
  }
}

const sortable = {
  mounted() {
    new Sortable(this.el, {
      animation: 150,
      handle: ".drag-handle",
      draggable: ".item",
      dragClass: "drag-item",
      ghostClass: "drag-ghost",
      forceFallback: true,
      onEnd: (e) => {
        const params = {
          old: e.oldDraggableIndex,
          new: e.newDraggableIndex,
          ...e.item.dataset,
          ...this.el.dataset,
        }
        this.pushEventTo(this.el, "reorder_stops", params)
      },
    })
  },
} as ViewHook

// https://github.com/fidr/phoenix_live_react
const hooks = {
  LiveReact,
  sortable,
  ...live_select,
}

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
  ShapeStopViewMap,
}

ReactPhoenix.init()
