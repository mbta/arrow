import * as React from "react"
import classnames from "classnames"
import Table from "react-bootstrap/Table"
import { Link } from "react-router-dom"
import { formatDisruptionDate } from "./disruptions"
import DisruptionRevision from "../models/disruptionRevision"
import { parseDaysAndTimes } from "./time"
import { useDisruptionViewParam, DisruptionView } from "./viewToggle"

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
    <th className="border-0">
      <span
        onClick={onClick}
        className={classnames({
          "m-disruption-table__sortable": sortable,
          asc: active && sortOrder === "asc",
          desc: active && sortOrder === "desc",
        })}
      >
        {label}
      </span>
    </th>
  )
}

interface SortState {
  by: "label" | "startDate"
  order: "asc" | "desc"
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
    return disruptionRevisions.map((x) => {
      return {
        disruptionId: x.disruptionId,
        startDate: x.startDate,
        endDate: x.endDate,
        label: x.adjustments.map((adj) => adj.sourceLabel).join(", "),
        daysOfWeek: x.daysOfWeek,
        daysAndTimes:
          x.daysOfWeek.length > 0 ? parseDaysAndTimes(x.daysOfWeek) : "",
      }
    })
  }, [disruptionRevisions])

  const sortedDisruptions = React.useMemo(() => {
    const { by, order } = sortState
    return disruptionRows.sort((a, b) => {
      if (!a[by] || !b[by]) {
        return -1
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      } else if (a[by]! > b[by]!) {
        return order === "asc" ? 1 : -1
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      } else if (a[by]! < b[by]!) {
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

  const view = useDisruptionViewParam()
  return (
    <Table className="m-disruption-table" striped>
      <thead>
        <tr>
          <DisruptionTableHeader
            label="stops"
            sortable
            sortOrder={sortState.order}
            active={sortState.by === "label"}
            onClick={() => handleChangeSort("label")}
          />
          <DisruptionTableHeader
            label="dates"
            sortable
            sortOrder={sortState.order}
            active={sortState.by === "startDate"}
            onClick={() => handleChangeSort("startDate")}
          />
          <DisruptionTableHeader label="days + times" />
          <th className="border-0" />
        </tr>
      </thead>
      <tbody>
        {sortedDisruptions.map((x, i, self) => (
          <tr
            key={i}
            className={x.status === DisruptionView.Draft ? "bg-light-pink" : ""}
          >
            {x.disruptionId !== self[i - 1]?.disruptionId ||
            x.label !== self[i - 1]?.label ? (
              <>
                <td>
                  {x.routes.map((route, i) => (
                    <Icon key={i} type={getRouteIcon(route)} className="mr-1" />
                  ))}
                </td>
                <td>{x.label}</td>
              </>
            ) : (
              <>
                <td className="border-0" />
                <td className="border-0 text-right">{"\u2198"}</td>
              </>
            )}
            {!!x.startDate && !!x.endDate && (
              <td>{`${formatDisruptionDate(
                x.startDate
              )} - ${formatDisruptionDate(x.endDate)}`}</td>
            )}
            <td>{x.exceptions}</td>
            <td>
              {x.daysAndTimes.split(", ").map((x, i) => (
                <div key={i}>{x}</div>
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
                to={
                  `/disruptions/${x.disruptionId}` +
                  (view === DisruptionView.Draft ? "?v=draft" : "")
                }
              >
                See details
              </Link>
            </td>
          </tr>
        ))}
      </tbody>
    </Table>
  )
}

export { DisruptionTableHeader, DisruptionTable }
