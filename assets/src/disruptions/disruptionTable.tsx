import * as React from "react"
import classnames from "classnames"
import Table from "react-bootstrap/Table"
import { Link } from "react-router-dom"
import { formatDisruptionDate } from "./disruptions"
import DisruptionRevision from "../models/disruptionRevision"
import { parseDaysAndTimes } from "./time"
import { DisruptionView } from "../models/disruption"
import Icon from "../icons"
import { getRouteIcon } from "./disruptionIndex"
import { Button } from "../button"
import DayOfWeek from "../models/dayOfWeek"
import { dayNameToInt } from "./disruptionCalendar"
import Adjustment from "../models/adjustment"
import Exception from "../models/exception"
import Checkbox from "../checkbox"

interface DisruptionTableHeaderProps {
  active?: boolean

  sortable?: boolean
  sortOrder?: "asc" | "desc"
  label: string
  onClick?: () => void
}

const DisruptionTableHeader = ({
  sortable,
  sortOrder,
  active,
  label,
  onClick,
}: DisruptionTableHeaderProps) => {
  return (
    <th>
      <span
        onClick={onClick}
        className={classnames({
          "m-disruption-table__sortable": sortable,
          active,
        })}
      >
        {label}
        <span className={"m-disruption-table__sortable-indicator mx-1"}>
          {sortable && (active && sortOrder === "desc" ? "\u2193" : "\u2191")}
        </span>
      </span>
    </th>
  )
}

interface SortState {
  by:
    | "label"
    | "startDate"
    | "exceptions"
    | "daysAndTimes"
    | "status"
    | "disruptionId"
  order: "asc" | "desc"
}

const convertSortable = (
  key: SortState["by"],
  item: DisruptionTableRow
): string | number | Date | undefined => {
  switch (key) {
    case "daysAndTimes": {
      return dayNameToInt(item.daysOfWeek[0].dayName)
    }
    case "disruptionId": {
      return item.disruptionId && parseInt(item.disruptionId, 10)
    }
    case "exceptions": {
      return item.exceptions.length
    }
    default: {
      return item[key]
    }
  }
}

const getStatusText = (status: DisruptionView) => {
  switch (status) {
    case DisruptionView.Draft: {
      return "needs review"
    }
    case DisruptionView.Ready: {
      return "ready"
    }
    case DisruptionView.Published: {
      return "published"
    }
  }
}

const isDiff = (
  baseValue: undefined | string | number | (string | number)[],
  currentValue: string | number | (string | number)[]
) => {
  return Array.isArray(baseValue) && Array.isArray(currentValue)
    ? baseValue.length !== currentValue.length ||
        baseValue.some((x, i) => x !== currentValue[i])
    : baseValue == null || baseValue !== currentValue
}

interface DisruptionTableRow {
  id?: string
  status?: DisruptionView
  disruptionId?: string
  startDate?: Date
  endDate?: Date
  exceptions: Exception[]
  adjustments: Adjustment[]
  label: string
  daysOfWeek: DayOfWeek[]
  daysAndTimes: string
  selectable: boolean
  selected: boolean
}

const DisruptionTableRow = ({
  base,
  current,
  selectEnabled,
  selected,
  selectable,
  toggleSelection,
}: {
  base: DisruptionTableRow | null
  current: DisruptionTableRow
  selected: boolean
  selectable: boolean
  selectEnabled: boolean
  toggleSelection: (id: string) => void
}) => {
  const adjustmentsEqual =
    current.disruptionId === base?.disruptionId && current.label === base?.label
  return (
    <tr
      data-revision-id={current.id}
      className={current.status === DisruptionView.Draft ? "bg-light-pink" : ""}
    >
      {selectEnabled && (
        <td className={adjustmentsEqual ? "border-0" : ""}>
          {selectable && (
            <Checkbox
              id={`revision-${current.id}-toggle`}
              checked={selected}
              onChange={() => current.id && toggleSelection(current.id)}
            />
          )}
        </td>
      )}
      {adjustmentsEqual ? (
        <td className="border-0 text-right">{"\u2198"}</td>
      ) : (
        <td className={isDiff(base?.label, current.label) ? "" : "text-muted"}>
          {current.adjustments.map((adj) => (
            <div
              key={current.id + adj.id}
              className="d-flex align-items-center"
            >
              <Icon
                size="sm"
                key={adj.routeId}
                type={getRouteIcon(adj.routeId)}
                className="mr-3"
              />
              {adj.sourceLabel}
            </div>
          ))}
        </td>
      )}
      {!!current.startDate && !!current.endDate && (
        <td>
          <div
            className={
              isDiff(base?.startDate?.getTime(), current.startDate.getTime())
                ? ""
                : "text-muted"
            }
          >
            {formatDisruptionDate(current.startDate)}
          </div>
          <div
            className={
              isDiff(base?.endDate?.getTime(), current.endDate.getTime())
                ? ""
                : "text-muted"
            }
          >
            {formatDisruptionDate(current.endDate)}
          </div>
        </td>
      )}
      <td
        className={
          isDiff(
            base?.exceptions.map((exc) => exc.excludedDate.getTime()),
            current.exceptions.map((exc) => exc.excludedDate.getTime())
          )
            ? ""
            : "text-muted"
        }
      >
        {current.exceptions.length}
      </td>
      <td
        className={
          isDiff(base?.daysAndTimes, current.daysAndTimes) ? "" : "text-muted"
        }
      >
        {current.daysAndTimes.split(", ").map((line, ix) => (
          <div key={ix}>{line}</div>
        ))}
      </td>
      <td>
        {
          <Button
            className="m-disruption-table__status-indicator"
            variant={`outline-${
              current.status === DisruptionView.Draft ? "primary" : "dark"
            }`}
          >
            {getStatusText(current.status || DisruptionView.Draft)}
          </Button>
        }
      </td>
      <td>
        <Link
          to={`/disruptions/${current.disruptionId}?v=${
            current.status === DisruptionView.Draft
              ? "draft"
              : current.status === DisruptionView.Ready
              ? "ready"
              : "published"
          }`}
        >
          {current.disruptionId}
        </Link>
      </td>
    </tr>
  )
}

interface DisruptionTableProps {
  disruptionRevisions: {
    revision: DisruptionRevision
    selectable: boolean
    selected: boolean
  }[]
  selectEnabled: boolean
  toggleRevisionSelection: (id: string) => void
}
const DisruptionTable = ({
  disruptionRevisions,
  selectEnabled,
  toggleRevisionSelection,
}: DisruptionTableProps) => {
  const [sortState, setSortState] = React.useState<SortState>({
    by: "label",
    order: "asc",
  })

  const disruptionRows = React.useMemo(() => {
    return disruptionRevisions.map(
      ({ revision, selected, selectable }): DisruptionTableRow => {
        return {
          id: revision.id,
          status: revision.status,
          disruptionId: revision.disruptionId,
          startDate: revision.startDate,
          endDate: revision.endDate,
          exceptions: revision.exceptions,
          daysOfWeek: revision.daysOfWeek,
          daysAndTimes:
            revision.daysOfWeek.length > 0
              ? parseDaysAndTimes(revision.daysOfWeek)
              : "",
          label: revision.adjustments.reduce((acc, curr) => {
            return acc + curr.sourceLabel
          }, ""),
          adjustments: revision.adjustments,
          selected,
          selectable,
        }
      }
    )
  }, [disruptionRevisions])

  const sortedDisruptions = React.useMemo(() => {
    const { by, order } = sortState
    return disruptionRows.sort((aRaw, bRaw) => {
      const a = convertSortable(by, aRaw)
      const b = convertSortable(by, bRaw)
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      if (a! > b!) {
        return order === "asc" ? 1 : -1
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      } else if (a! < b!) {
        return order === "asc" ? -1 : 1
      } else {
        return 0
      }
    })
  }, [sortState, disruptionRows])

  const handleChangeSort = React.useCallback(
    (field: SortState["by"]) => {
      setSortState({
        by: field,
        order:
          field !== sortState.by || sortState.order === "desc" ? "asc" : "desc",
      })
    },
    [sortState]
  )

  return (
    <Table className="m-disruption-table border-top-dark">
      <thead>
        <tr>
          {selectEnabled && <td />}
          <DisruptionTableHeader
            label="adjustments"
            sortable
            sortOrder={sortState.order}
            active={sortState.by === "label"}
            onClick={() => handleChangeSort("label")}
          />
          <DisruptionTableHeader
            label="date range"
            sortable
            sortOrder={sortState.order}
            active={sortState.by === "startDate"}
            onClick={() => handleChangeSort("startDate")}
          />
          <DisruptionTableHeader
            label="except"
            sortable
            sortOrder={sortState.order}
            active={sortState.by === "exceptions"}
            onClick={() => handleChangeSort("exceptions")}
          />
          <DisruptionTableHeader
            label="time period"
            sortable
            sortOrder={sortState.order}
            active={sortState.by === "daysAndTimes"}
            onClick={() => handleChangeSort("daysAndTimes")}
          />
          <DisruptionTableHeader
            label="status"
            sortable
            sortOrder={sortState.order}
            active={sortState.by === "status"}
            onClick={() => handleChangeSort("status")}
          />
          <DisruptionTableHeader
            label="ID"
            sortable
            sortOrder={sortState.order}
            active={sortState.by === "disruptionId"}
            onClick={() => handleChangeSort("disruptionId")}
          />
        </tr>
      </thead>
      <tbody>
        {sortedDisruptions.map((x, i, self) => {
          const base =
            self[i - 1] && self[i - 1].disruptionId === x.disruptionId
              ? self[i - 1]
              : null
          return (
            <DisruptionTableRow
              key={`${x.id}-${i}`}
              base={base}
              current={x}
              selectEnabled={selectEnabled}
              selectable={x.selectable}
              selected={x.selected}
              toggleSelection={toggleRevisionSelection}
            />
          )
        })}
      </tbody>
    </Table>
  )
}

export { DisruptionTableHeader, DisruptionTable }
