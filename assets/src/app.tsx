// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
declare function require(name: string): string

// tslint:disable-next-line
require("../css/app.css")

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

// listen for a "changed" auth message and reload
window.addEventListener("message", (e) => {
  if (e.origin !== window.location.origin) {
    return;
  }

  if (e.data === "changed") {
    window.location.reload();
  }
}, false);
