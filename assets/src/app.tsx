// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
import LiveReact from "./LiveReactPhoenix"
import live_select from "live_select"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocketInstanceInterface, ViewHook } from "phoenix_live_view"
import Sortable from "sortablejs"

import ReactPhoenix from "./ReactPhoenix"
import DisruptionCalendar from "./components/DisruptionCalendar"
import DisruptionForm from "./components/DisruptionForm"
import ShapeViewMap from "./components/ShapeViewMap"
import StopViewMap from "./components/stops/StopViewMap"
import ShapeStopViewMap from "./components/ShapeStopViewMap"

declare global {
  interface Window {
    liveSocket: typeof LiveSocketInstanceInterface
    Components: {
      [name: string]: (props: any) => JSX.Element
    }
  }
}

interface DownloadFileEventDetails {
  base64?: boolean
  filename: string
  content_type: string
  contents: string
}

window.addEventListener("phx:download-file", (event: unknown) => {
  if (event == null || typeof event != "object" || !("detail" in event)) {
    throw new Error(`download-file event missing 'detail'`)
  }

  const {
    base64 = false,
    filename,
    content_type: contentType,
    contents,
  } = event.detail as DownloadFileEventDetails
  const encodedContents = encodeURIComponent(contents)
  const element = document.createElement("a")
  element.setAttribute(
    "href",
    `data:${contentType}${base64 ? ";base64" : ""},${encodedContents}`
  )
  element.setAttribute("download", filename)
  element.style.display = "none"
  document.body.appendChild(element)
  element.click()
  document.body.removeChild(element)
})

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
        if (e.oldDraggableIndex && e.newDraggableIndex) {
          const params = {
            old: e.oldDraggableIndex - 1,
            new: e.newDraggableIndex - 1,
            ...e.item.dataset,
            ...this.el.dataset,
          }
          this.pushEventTo(this.el, "reorder_stops", params)
        }
      },
    })
  },
} as ViewHook

const LimitTime = {
  mounted() {
    this.el.addEventListener("input", () => {
      const el = this.el as HTMLInputElement
      const match = el.value.match(/^(\d{2})(\d{2})$/)
      if (match) {
        el.value = `${match[1]}:${match[2]}`
      }
    })
  },
} as ViewHook

// https://github.com/fidr/phoenix_live_react
const hooks = {
  LiveReact,
  sortable,
  ...live_select,
  LimitTime,
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
