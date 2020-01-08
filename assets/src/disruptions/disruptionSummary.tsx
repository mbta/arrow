import * as React from "react"
import { Adjustment } from "./disruptions"

interface DisruptionSummaryProps {
  adjustments: Adjustment[]
}

const DisruptionSummary = ({
  adjustments,
}: DisruptionSummaryProps): JSX.Element => {
  return (
    <ul className="m-disruption-summary__adjustment_list">
      {adjustments.map(adjustment => (
        <li className="m-disruption-summary__adjustment" key={adjustment.label}>
          <span className="m-disruption-summary__adjustment_label">
            {adjustment.label}
          </span>
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
