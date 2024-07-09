/*
  From https://github.com/geolessel/react-phoenix/blob/master/src/react_phoenix.js

  The compiled JS that gets included when installing via the instructions in ../deps/priv
  had scope errors and caused issues with esbuild referring to react / react-dom.
*/

import React from "react"
import { createRoot } from "react-dom/client"

export default class ReactPhoenix {
  static init() {
    const elements = document.querySelectorAll("[data-react-class]")
    Array.prototype.forEach.call(elements, (e) => {
      const targetId = document.getElementById(e.dataset.reactTargetId)
      const targetDiv = targetId ? targetId : e
      const reactProps = e.dataset.reactProps ? e.dataset.reactProps : "{}"
      const reactClass = Array.prototype.reduce.call(
        e.dataset.reactClass.split("."),
        (acc, el) => {
          return acc[el]
        },
        window
      )
      const reactElement = React.createElement(
        reactClass,
        JSON.parse(reactProps)
      )

      const root = createRoot(targetDiv) // createRoot(container!) if you use TypeScript
      root.render(reactElement)
    })
  }
}
