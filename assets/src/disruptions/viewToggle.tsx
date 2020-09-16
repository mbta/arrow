import * as React from "react"
import { NavLink, useHistory } from "react-router-dom"
import queryString from "query-string"

import Disruption from "../models/disruption"
import DisruptionRevision from "../models/disruptionRevision"

enum DisruptionView {
  Draft,
  Ready,
  Published,
}

const useDisruptionViewParam = (): DisruptionView => {
  const { v } = queryString.parse(useHistory().location.search)
  switch (v) {
    case "draft": {
      return DisruptionView.Draft
    }
    default: {
      return DisruptionView.Ready
    }
  }
}

const DisruptionViewToggle = () => {
  const view = useDisruptionViewParam()
  return (
    <div className="d-flex flex-column">
      <h5>Select View</h5>
      <NavLink
        id="draft"
        className="btn m-disruption-view-toggle_button"
        to="?v=draft"
        activeClassName="active"
        isActive={() => view === DisruptionView.Draft}
        replace
      >
        create or edit
      </NavLink>
      <NavLink
        id="ready"
        className="btn m-disruption-view-toggle_button"
        to="?"
        activeClassName="active"
        isActive={() => view === DisruptionView.Ready}
        replace
      >
        ready
      </NavLink>
    </div>
  )
}

const revisionFromDisruptionForView = (
  disruption: Disruption,
  view: DisruptionView
): DisruptionRevision | undefined => {
  switch (view) {
    case DisruptionView.Draft: {
      const sortedRevisions = disruption.revisions.sort((r1, r2) => {
        return parseInt(r1.id || "", 10) - parseInt(r2.id || "", 10)
      })

      return sortedRevisions[sortedRevisions.length - 1]
    }
    case DisruptionView.Ready: {
      return disruption.readyRevision
    }
    case DisruptionView.Published: {
      return disruption.publishedRevision
    }
  }
}

export {
  DisruptionViewToggle,
  DisruptionView,
  useDisruptionViewParam,
  revisionFromDisruptionForView,
}
