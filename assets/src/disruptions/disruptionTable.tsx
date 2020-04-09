import * as React from "react"
import classnames from "classnames"
import Table from "react-bootstrap/Table"
import { Link } from "react-router-dom"
import { DisruptionRow } from "./disruptionIndex"
import { formatDisruptionDate } from "./disruptions"

interface DisruptionTableHeaderProps {
  active?: boolean
  sortable?: boolean
  sortOrder?: "asc" | "desc"
  label: string
  onClick?: () => void
}

export const DisruptionTableHeader = ({
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
  disruptions: DisruptionRow[]
}
const DisruptionTable = ({ disruptions }: DisruptionTableProps) => {
  const [sortState, setSortState] = React.useState<SortState>({
    by: "label",
    order: "asc",
  })

  const sortedDisruptions = React.useMemo(() => {
    const { by, order } = sortState
    return disruptions.sort((a, b) => {
      if (!a[by] || !b[by]) {
        return 0
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
  }, [sortState, disruptions])

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
    <Table striped>
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
          <th />
        </tr>
      </thead>
      <tbody>
        {sortedDisruptions.map(x => (
          <tr key={x.id}>
            <td>{x.label}</td>
            {!!x.startDate && !!x.endDate && (
              <td>{`${formatDisruptionDate(
                x.startDate
              )} - ${formatDisruptionDate(x.endDate)}`}</td>
            )}
            <td>{x.daysAndTimes}</td>
            <td>
              <Link to={`/disruptions/${x.id}`}>See details</Link>
            </td>
          </tr>
        ))}
      </tbody>
    </Table>
  )
}

export default DisruptionTable
