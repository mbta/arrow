import * as React from "react"
import { Link } from "react-router-dom"
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome"
import { faTimes } from "@fortawesome/free-solid-svg-icons"
import classnames from "classnames"
import Row from "react-bootstrap/Row"
import Col from "react-bootstrap/Col"
import Form from "react-bootstrap/Form"
import Header from "../header"
import Button from "react-bootstrap/Button"
import Icon from "../icons"
import DisruptionTable from "./disruptionTable"
import DisruptionCalendar from "./disruptionCalendar"
import Disruption from "../models/disruption"
import { apiGet } from "../api"
import { ModelObject, toModelObject } from "../jsonApi"
import DayOfWeek, { DayName } from "../models/dayOfWeek"
import {dayToIx, parseDaysAndTimes} from "../disruptions/time"

type Routes =
  | "Red"
  | "Blue"
  | "Mattapan"
  | "Orange"
  | "Green-B"
  | "Green-C"
  | "Green-D"
  | "Green-E"
  | "Commuter"

type RouteFilterState = {
  [route in Routes]?: boolean
}

export interface DisruptionRow {
  id?: string
  routes?: Routes[]
  label?: string
  startDate?: Date
  endDate?: Date
  daysAndTimes?: string
}

const ROUTE_ICONS: { [route in Routes]: Icon } = {
  Red: "red-line-small",
  Blue: "blue-line-small",
  Mattapan: "mattapan-line-small",
  Orange: "orange-line-small",
  "Green-B": "green-line-b-small",
  "Green-C": "green-line-c-small",
  "Green-D": "green-line-d-small",
  "Green-E": "green-line-e-small",
  Commuter: "mode-commuter-rail-small",
}

interface RouteFilterToggleProps {
  route: keyof RouteFilterState
  active: boolean
  onClick: (route: keyof RouteFilterState) => void
}
// eslint-disable-next-line react/display-name
export const RouteFilterToggle = React.memo(
  ({ route, active, onClick }: RouteFilterToggleProps) => {
    return (
      <a
        className={classnames("mr-2 m-disruption-index__route_filter", {
          active,
        })}
        onClick={() => onClick(route)}
      >
        <Icon type={ROUTE_ICONS[route]} />
      </a>
    )
  }
)

interface RouteFilterToggleGroupProps {
  routes: Routes[]
  toggleRouteFilterState: (route: Routes) => void
  isRouteActive: (route: Routes) => boolean
}

const RouteFilterToggleGroup = ({
  routes,
  toggleRouteFilterState,
  isRouteActive,
}: RouteFilterToggleGroupProps) => {
  return (
    <div className="mb-1">
      {routes.map(route => {
        return (
          <RouteFilterToggle
            key={route}
            route={route}
            onClick={() => toggleRouteFilterState(route)}
            active={isRouteActive(route)}
          />
        )
      })}
    </div>
  )
}

interface DisruptionIndexProps {
  disruptions: DisruptionRow[]
}

export const DisruptionIndexView = ({ disruptions }: DisruptionIndexProps) => {
  const [view, setView] = React.useState<"table" | "calendar">("table")
  const toggleView = React.useCallback(() => {
    if (view === "table") {
      setView("calendar")
    } else {
      setView("table")
    }
  }, [view, setView])

  const [searchQuery, setSearchQuery] = React.useState<string>("")
  const [routeFilters, updateRouteFilters] = React.useState<RouteFilterState>(
    {}
  )
  const toggleRouteFilterState = React.useCallback(
    (route: keyof RouteFilterState) => {
      updateRouteFilters({ ...routeFilters, [route]: !routeFilters[route] })
    },
    [routeFilters, updateRouteFilters]
  )
  const clearRouteFilters = React.useCallback(() => {
    updateRouteFilters({})
  }, [updateRouteFilters])

  const anyRouteFiltersActive: boolean = React.useMemo(() => {
    return Object.values(routeFilters).some(Boolean)
  }, [routeFilters])

  const isRouteActive = React.useCallback(
    (route: keyof RouteFilterState) => {
      return !anyRouteFiltersActive || !!routeFilters[route]
    },
    [anyRouteFiltersActive, routeFilters]
  )

  const filteredDisruptions = React.useMemo(() => {
    const query = searchQuery.toLowerCase()
    return disruptions.filter(
      x =>
        (!anyRouteFiltersActive ||
          (x.routes || []).some(route => routeFilters[route])) &&
        (x.label || "").toLowerCase().includes(query)
    )
  }, [disruptions, searchQuery, routeFilters, anyRouteFiltersActive])

  return (
    <div>
      <Header includeHomeLink={false} />
      <h1>Disruptions</h1>
      <Row>
        <Col xs={9}>
          {view === "table" ? (
            <DisruptionTable disruptions={filteredDisruptions} />
          ) : (
            <DisruptionCalendar />
          )}
        </Col>
        <Col>
          <Button
            id="view-toggle"
            className="mb-3 border"
            variant="light"
            onClick={toggleView}
          >
            {view === "calendar" ? "list view" : "calendar view"}
          </Button>
          <Form.Control
            className="mb-3"
            type="text"
            value={searchQuery}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
              setSearchQuery(e.target.value)
            }
            placeholder="Search Disruptions"
          />
          <h6>Filter by route</h6>
          <RouteFilterToggleGroup
            routes={["Blue", "Mattapan", "Orange", "Red"]}
            toggleRouteFilterState={toggleRouteFilterState}
            isRouteActive={isRouteActive}
          />
          <RouteFilterToggleGroup
            routes={["Green-B", "Green-C", "Green-D", "Green-E"]}
            toggleRouteFilterState={toggleRouteFilterState}
            isRouteActive={isRouteActive}
          />
          <RouteFilterToggleGroup
            routes={["Commuter"]}
            toggleRouteFilterState={toggleRouteFilterState}
            isRouteActive={isRouteActive}
          />
          {anyRouteFiltersActive && (
            <a
              className="m-disruption-index__clear_filter_button"
              id="clear-filter"
              onClick={clearRouteFilters}
            >
              <FontAwesomeIcon icon={faTimes} className="mr-1" />
              clear filter
            </a>
          )}
        </Col>
      </Row>
      <Row>
        <Col>
          <Link to="/disruptions/new">
            <Button>create new disruption</Button>
          </Link>
        </Col>
      </Row>
    </div>
  )
}

const DisruptionIndexConnected = () => {
  const [disruptions, setDisruptions] = React.useState<Disruption[] | "error">(
    []
  )

  const disruptionRows = React.useMemo(() => {
    if (disruptions === "error") {
      return []
    } else {
      return disruptions.map(x => {
        return {
          id: x.id,
          startDate: x.startDate,
          endDate: x.endDate,
          label: x.adjustments.map(adj => adj.sourceLabel).join(", "),
          routes: x.adjustments
            .map(adj => {
              if (adj.routeId && adj.routeId.startsWith("CR-")) {
                return "Commuter"
              } else {
                return adj.routeId
              }
            })
            .filter(
              (routeId: string | undefined): routeId is Routes => !!routeId
            ),
          daysAndTimes: parseDaysAndTimes(x.daysOfWeek),
        }
      })
    }
  }, [disruptions])

  React.useEffect(() => {
    apiGet<ModelObject | ModelObject[] | "error">({
      url: "/api/disruptions",
      parser: toModelObject,
      defaultResult: "error",
    }).then((result: ModelObject | ModelObject[] | "error") => {
      if (
        Array.isArray(result) &&
        result.every(res => res instanceof Disruption)
      ) {
        setDisruptions(result as Disruption[])
      } else {
        setDisruptions("error")
      }
    })
  }, [])

  if (disruptions === "error") {
    return <div>Something went wrong</div>
  } else {
    return <DisruptionIndexView disruptions={disruptionRows} />
  }
}

export default DisruptionIndexConnected
