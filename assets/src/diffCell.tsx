import * as React from "react"

type Value = string | number | (string | number)[]

interface DiffCellProps<T extends Value[] | Value = string> {
  currentValue: T
  baseValue?: T
  element?: "td" | "div" | "span"
  children: React.ReactNode | string
}

const DiffCell = <T extends Value[] | Value = string>({
  currentValue,
  baseValue,
  children,
  element = "td",
}: DiffCellProps<T>) => {
  const isDiff =
    Array.isArray(baseValue) && Array.isArray(currentValue)
      ? baseValue.length !== currentValue.length ||
        baseValue.some((x, i) => x !== currentValue[i])
      : baseValue == null || baseValue !== currentValue

  const Element = element
  return <Element className={isDiff ? "" : "text-muted"}>{children}</Element>
}

export { DiffCell, DiffCellProps }
