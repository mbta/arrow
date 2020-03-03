import * as React from "react"
import { Adjustment } from "./disruptions"

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
        <li className="m-disruption-summary__adjustment" key={adjustment.label}>
          <span className="m-disruption-summary__adjustment_label">
            {adjustment.label}
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
              {adjustment.route}
            </span>
          </div>
        </li>
      ))}
    </ul>
  )
}

export { DisruptionSummary }
