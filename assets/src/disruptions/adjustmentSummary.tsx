import * as React from "react"
import Adjustment from "../models/adjustment"
import Icon from "../icons"
import { getRouteIcon } from "./disruptionIndex"

interface AdjustmentSummaryProps {
  adjustments: Adjustment[]
}

const AdjustmentSummary = ({
  adjustments,
}: AdjustmentSummaryProps): JSX.Element => {
  return (
    <div className="m-disruption-details__adjustments">
      <ul className="m-disruption-details__adjustment-list">
        {adjustments.map((adj) => (
          <li key={adj.id} className="m-disruption-details__adjustment-item">
            <Icon className="mr-3" type={getRouteIcon(adj.routeId)} size="sm" />
            {adj.sourceLabel}
          </li>
        ))}
      </ul>
    </div>
  )
}

export { AdjustmentSummary }
