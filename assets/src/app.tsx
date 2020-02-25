// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
declare function require(name: string): string
// tslint:disable-next-line
require("../css/app.scss")

import "phoenix_html"
import * as React from "react"
import ReactDOM from "react-dom"
import { BrowserRouter, Route } from "react-router-dom"

import EditDisruption from "./disruptions/editDisruption"
import { NewDisruption } from "./disruptions/newDisruption"
import DisruptionIndex from "./disruptions/disruptionIndex"

const App = (): JSX.Element => {
  return (
    <BrowserRouter>
      <Route
        exact={true}
        path="/"
        render={() => <DisruptionIndex disruptions={[]} />}
      />
      <Route exact={true} path="/disruptions/new" component={NewDisruption} />
      <Route
        exact={true}
        path="/disruptions/:id/edit"
        component={EditDisruption}
      />
    </BrowserRouter>
  )
}

ReactDOM.render(<App />, document.getElementById("app"))
