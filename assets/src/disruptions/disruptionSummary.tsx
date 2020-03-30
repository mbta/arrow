import * as React from "react"
import Adjustment from "../models/adjustment"

interface DisruptionSummaryProps {
  disruptionId?: string
  adjustments: Adjustment[]
}

const DisruptionSummary = ({
  disruptionId,
  adjustments,
}: DisruptionSummaryProps): JSX.Element => {
  return (
    <ul className="m-disruption-summary__adjustment_list">
      {adjustments.map(adjustment => (
        <li
          className="m-disruption-summary__adjustment"
          key={adjustment.sourceLabel}
        >
          <span className="m-disruption-summary__adjustment_label">
            {adjustment.sourceLabel}
          </span>
          {disruptionId && (
            <div>
              <span className="m-disruption-summary__disruption_id">
                Disruption ID: {disruptionId}
              </span>
            </div>
          )}
          <div>
            <span className="m-disruption-summary__adjustment_route">
              {adjustment.routeId}
            </span>
          </div>
        </li>
      ))}
    </ul>
  )
}

export { DisruptionSummary }
