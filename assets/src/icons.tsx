import * as React from "react"
import classnames from "classnames"

type Icon =
  | "blue-line-small"
  | "green-line-b-small"
  | "green-line-c-small"
  | "green-line-d-small"
  | "green-line-e-small"
  | "mattapan-line-small"
  | "red-line-small"
  | "orange-line-small"
  | "mode-commuter-rail-small"

const Icon = ({ type, className }: { type: Icon; className?: string }) => (
  <span
    className={classnames("d-inline-block", className)}
    style={{
      display: "inline-block",
      height: 34,
      width: 34,
      backgroundImage: `url(/images/icon-${type}.svg)`,
    }}
  />
)

export default Icon
