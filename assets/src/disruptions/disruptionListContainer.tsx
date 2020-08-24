import * as React from "react"
import { withRouter, RouteComponentProps } from "react-router"
import { NavLink } from "react-router-dom"

const DisruptionListContainer = withRouter(
  ({ children }: RouteComponentProps & { children: React.ReactNode }) => {
    return (
      <div>
        <div className="d-flex border-bottom">
          <NavLink
            to="/"
            exact={true}
            className="m-disruption-list-container_nav-link"
            activeClassName="active"
          >
            <h3>Disruptions</h3>
          </NavLink>
          <NavLink
            to="/disruptions/needs_review"
            exact={true}
            className="m-disruption-list-container_nav-link"
            activeClassName="active"
          >
            <h3>Needs Review</h3>
          </NavLink>
        </div>
        {children}
      </div>
    )
  }
)

export { DisruptionListContainer }
