// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
declare function require(name: string): string
// tslint:disable-next-line
require("../css/app.scss")

import "phoenix_html"
import * as React from "react"
import ReactDOM from "react-dom"
import { BrowserRouter, Route, Switch } from "react-router-dom"
import "react-phoenix"

import EditDisruption from "./disruptions/editDisruption"
import { NewDisruption } from "./disruptions/newDisruption"
import ViewDisruption from "./disruptions/viewDisruption"
import { DisruptionIndex } from "./disruptions/disruptionIndex"
import DisruptionFormWrapper from "./disruptions/DisruptionForm"

declare global {
  interface Window {
    Components: {
      [name: string]: (props: any) => JSX.Element
    }
  }
}

const App = (): JSX.Element => {
  return (
    <BrowserRouter>
      <Switch>
        <Route exact={true} path="/" component={DisruptionIndex} />
        <Route exact={true} path="/disruptions/new" component={NewDisruption} />
        <Route
          exact={true}
          path="/disruptions/:id"
          component={ViewDisruption}
        />
        <Route
          exact={true}
          path="/disruptions/:id/edit"
          component={EditDisruption}
        />
      </Switch>
    </BrowserRouter>
  )
}

if (document.getElementById("app")) {
  ReactDOM.render(<App />, document.getElementById("app"))
}

window.Components = {
  DisruptionFormWrapper
}
