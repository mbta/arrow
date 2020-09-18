import * as React from "react"
import classnames from "classnames"
import Table from "react-bootstrap/Table"
import { Link } from "react-router-dom"
import { formatDisruptionDate } from "./disruptions"
import DisruptionRevision from "../models/disruptionRevision"
import { parseDaysAndTimes } from "./time"
import { DisruptionView } from "./viewToggle"
import Icon from "../icons"
import { getRouteIcon } from "./disruptionIndex"
import { Button } from "../button"
import DayOfWeek from "../models/dayOfWeek"
import { dayNameToInt } from "./disruptionCalendar"
import Adjustment from "../models/adjustment"

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

interface DisruptionTableRow {
  id?: string
  status?: DisruptionView
  disruptionId?: string
  startDate?: Date
  endDate?: Date
  exceptions: number
  adjustments: Adjustment[]
  label: string
  daysOfWeek: DayOfWeek[]
  daysAndTimes: string
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
    default: {
      return item[key]
    }
  }
}

interface DisruptionTableProps {
  disruptionRevisions: DisruptionRevision[]
}
const DisruptionTable = ({ disruptionRevisions }: DisruptionTableProps) => {
  const [sortState, setSortState] = React.useState<SortState>({
    by: "label",
    order: "asc",
  })

  const disruptionRows = React.useMemo(() => {
    return disruptionRevisions.map(
      (x): DisruptionTableRow => {
        return {
          id: x.id,
          status: x.status,
          disruptionId: x.disruptionId,
          startDate: x.startDate,
          endDate: x.endDate,
          exceptions: x.exceptions.length,
          adjustments: x.adjustments,
          label: x.adjustments.map((adj) => adj.sourceLabel).join(", "),
          daysOfWeek: x.daysOfWeek,
          daysAndTimes:
            x.daysOfWeek.length > 0 ? parseDaysAndTimes(x.daysOfWeek) : "",
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

  const getStatusText = React.useCallback((status: DisruptionView) => {
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
  }, [])

  return (
    <Table className="m-disruption-table border-top-dark">
      <thead>
        <tr>
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
        {sortedDisruptions.map((x, i, self) => (
          <tr
            key={`${x.id}${i}`}
            className={x.status === DisruptionView.Draft ? "bg-light-pink" : ""}
          >
            {x.disruptionId !== self[i - 1]?.disruptionId ||
            x.label !== self[i - 1]?.label ? (
              <td>
                {x.adjustments.map((adj) => (
                  <div
                    key={x.id + adj.id}
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
            ) : (
              <>
                <td className="border-0 text-right">{"\u2198"}</td>
              </>
            )}
            {!!x.startDate && !!x.endDate && (
              <td>
                <div>{formatDisruptionDate(x.startDate)}</div>
                <div>{formatDisruptionDate(x.endDate)}</div>
              </td>
            )}
            <td>{x.exceptions}</td>
            <td>
              {x.daysAndTimes.split(", ").map((line, ix) => (
                <div key={ix}>{line}</div>
              ))}
            </td>
            <td>
              {
                <Button
                  variant={`outline-${
                    x.status === DisruptionView.Draft ? "primary" : "dark"
                  }`}
                >
                  {getStatusText(x.status || DisruptionView.Draft)}
                </Button>
              }
            </td>
            <td>
              <Link
                to={`/disruptions/${x.disruptionId}?v=${
                  x.status === DisruptionView.Draft ? "draft" : ""
                }`}
              >
                {x.disruptionId}
              </Link>
            </td>
          </tr>
        ))}
      </tbody>
    </Table>
  )
}

export { DisruptionTableHeader, DisruptionTable }
