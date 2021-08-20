// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
declare function require(name: string): string
// tslint:disable-next-line
require("../css/app.css")

import "phoenix_html"
import "react-phoenix"

import EditDisruption from "./disruptions/editDisruption"
import { NewDisruption } from "./disruptions/newDisruption"
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
  EditDisruption,
}
