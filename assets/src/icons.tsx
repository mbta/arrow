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

const Icon = ({
  type,
  size,
  className,
}: {
  type: Icon
  size: "sm" | "lg"
  className?: string
}) => (
  <span
    className={classnames(`m-icon m-icon-${size}`, className)}
    style={{
      backgroundImage: `url(/images/icon-${type}.svg)`,
    }}
  />
)

export default Icon
