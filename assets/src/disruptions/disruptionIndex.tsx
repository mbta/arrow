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
import { DisruptionTable } from "./disruptionTable"
import DisruptionCalendar from "./disruptionCalendar"
import Disruption from "../models/disruption"
import { apiGet } from "../api"
import { JsonApiResponse, toModelObject } from "../jsonApi"

export type Routes =
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

const getRouteIcon = (route?: string): Icon => {
  switch (route) {
    case "Red": {
      return "red-line-small"
    }
    case "Blue": {
      return "blue-line-small"
    }
    case "Mattapan": {
      return "mattapan-line-small"
    }
    case "Orange": {
      return "orange-line-small"
    }
    case "Green-B": {
      return "green-line-b-small"
    }
    case "Green-C": {
      return "green-line-c-small"
    }
    case "Green-D": {
      return "green-line-d-small"
    }
    case "Green-E": {
      return "green-line-e-small"
    }
    default: {
      return "mode-commuter-rail-small"
    }
  }
}

export const getRouteColor = (route?: string): string => {
  switch (route) {
    case "Red": {
      return "#da291c"
    }
    case "Blue": {
      return "#003da5"
    }
    case "Mattapan": {
      return "#da291c"
    }
    case "Orange": {
      return "#ed8b00"
    }
    case "Green-B": {
      return "#00843d"
    }
    case "Green-C": {
      return "#00843d"
    }
    case "Green-D": {
      return "#00843d"
    }
    case "Green-E": {
      return "#00843d"
    }
    default: {
      return "#80276c"
    }
  }
}

interface RouteFilterToggleProps {
  route: keyof RouteFilterState
  active: boolean
  onClick: (route: keyof RouteFilterState) => void
}
// eslint-disable-next-line react/display-name
const RouteFilterToggle = React.memo(
  ({ route, active, onClick }: RouteFilterToggleProps) => {
    return (
      <a
        className={classnames("mr-2 m-disruption-index__route_filter", {
          active,
        })}
        id={"route-filter-toggle-" + route}
        onClick={() => onClick(route)}
      >
        <Icon type={getRouteIcon(route)} />
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
      {routes.map((route) => {
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
  disruptions: Disruption[]
}

const DisruptionIndexView = ({ disruptions }: DisruptionIndexProps) => {
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
    return disruptions.filter((x) => {
      return (
        (!anyRouteFiltersActive ||
          (x.adjustments || []).some(
            (adj) =>
              adj.routeId &&
              (routeFilters[adj.routeId as Routes] ||
                (routeFilters.Commuter && adj.routeId.includes("CR-")))
          )) &&
        (x.adjustments || []).some(
          (adj) =>
            adj.sourceLabel && adj.sourceLabel.toLowerCase().includes(query)
        )
      )
    })
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
            <DisruptionCalendar disruptions={filteredDisruptions} />
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

const DisruptionIndex = () => {
  const [disruptions, setDisruptions] = React.useState<Disruption[] | "error">(
    []
  )
  React.useEffect(() => {
    apiGet<JsonApiResponse>({
      url: "/api/disruptions",
      parser: toModelObject,
      defaultResult: "error",
    }).then((result: JsonApiResponse) => {
      if (
        Array.isArray(result) &&
        result.every((res) => res instanceof Disruption)
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
    return <DisruptionIndexView disruptions={disruptions} />
  }
}

export { DisruptionIndex, RouteFilterToggle, DisruptionIndexView }
