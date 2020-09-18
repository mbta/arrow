import * as React from "react"
import { Link } from "react-router-dom"
import classnames from "classnames"
import Row from "react-bootstrap/Row"
import Col from "react-bootstrap/Col"
import Form from "react-bootstrap/Form"
import { PrimaryButton, SecondaryButton, LinkButton } from "../button"
import Icon from "../icons"
import { DisruptionTable } from "./disruptionTable"
import { DisruptionCalendar } from "./disruptionCalendar"
import Disruption from "../models/disruption"
import DisruptionRevision from "../models/disruptionRevision"
import { apiGet } from "../api"
import { JsonApiResponse, toModelObject } from "../jsonApi"
import { Page } from "../page"
import {
  useDisruptionViewParam,
  DisruptionView,
  revisionFromDisruptionForView,
} from "./viewToggle"

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

const getRouteColor = (route?: string): string => {
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
        <Icon size="lg" type={getRouteIcon(route)} />
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

const useFilterGroup = <G extends string>(
  group: G[]
): {
  state: { [filter in G]?: boolean }
  anyActive: boolean
  isFilterActive: (filter: G) => boolean
  toggleFilter: (filter: G) => void
  clearFilters: () => void
  updateFiltersState: React.Dispatch<{ [filter in G]?: boolean }>
} => {
  const [filtersState, updateFiltersState] = React.useState<
    { [filter in G]?: boolean }
  >(
    group.reduce((acc: { [filter in G]?: boolean }, curr: G) => {
      return { ...acc, [curr]: false }
    }, {})
  )

  const toggleFilter = React.useCallback(
    (filter: G) => {
      updateFiltersState({ ...filtersState, [filter]: !filtersState[filter] })
    },
    [filtersState, updateFiltersState]
  )
  const clearFilters = React.useCallback(() => {
    updateFiltersState({})
  }, [updateFiltersState])

  const anyActive: boolean = React.useMemo(() => {
    return Object.values(filtersState).some(Boolean)
  }, [filtersState])

  const isFilterActive = React.useCallback(
    (route: keyof { [filter in G]?: boolean }) => {
      return !anyActive || !!filtersState[route]
    },
    [anyActive, filtersState]
  )

  return {
    state: filtersState,
    anyActive,
    isFilterActive,
    toggleFilter,
    clearFilters,
    updateFiltersState,
  }
}

interface DisruptionIndexProps {
  disruptions: Disruption[]
}

const DisruptionIndexView = ({ disruptions }: DisruptionIndexProps) => {
  const routeFilters = useFilterGroup([
    "Red",
    "Blue",
    "Orange",
    "Green-B",
    "Green-C",
    "Green-D",
    "Green-E",
    "Mattapan",
    "Commuter",
  ])

  const statusFilters = useFilterGroup(["published", "ready", "needs_review"])
  const [view, setView] = React.useState<"table" | "calendar">("table")
  const toggleView = React.useCallback(() => {
    if (view === "table") {
      setView("calendar")
      statusFilters.updateFiltersState({ published: true })
    } else {
      statusFilters.clearFilters()
      setView("table")
    }
  }, [view, setView, statusFilters])

  const [searchQuery, setSearchQuery] = React.useState<string>("")
  const filteredDisruptionRevisions = React.useMemo(() => {
    const query = searchQuery.toLowerCase()
    return disruptions.reduce((acc, curr) => {
      const uniqueRevisions = [
        revisionFromDisruptionForView(curr, DisruptionView.Published),
        revisionFromDisruptionForView(curr, DisruptionView.Ready),
        revisionFromDisruptionForView(curr, DisruptionView.Draft),
        ,
      ].filter(
        (x, i, self) =>
          !!x && self.indexOf(self.find((y) => y?.id === x.id)) === i
      )

      const anyMatches = uniqueRevisions.some((revision) => {
        return (
          !!revision &&
          (!routeFilters.anyActive ||
            (revision.adjustments || []).some(
              (adj) =>
                adj.routeId &&
                (routeFilters.state[adj.routeId as Routes] ||
                  (routeFilters.state.Commuter && adj.routeId.includes("CR-")))
            )) &&
          (!statusFilters.anyActive ||
            (revision.status === DisruptionView.Published &&
              statusFilters.state.published) ||
            (revision.status === DisruptionView.Ready &&
              statusFilters.state.ready) ||
            (revision.status === DisruptionView.Draft &&
              statusFilters.state.needs_review)) &&
          (revision.adjustments || []).some(
            (adj) =>
              adj.sourceLabel && adj.sourceLabel.toLowerCase().includes(query)
          ) &&
          revision.isActive
        )
      })

      if (anyMatches) {
        return [...acc, ...(uniqueRevisions as DisruptionRevision[])]
      } else {
        return acc
      }
    }, [] as DisruptionRevision[])
  }, [
    disruptions,
    searchQuery,
    routeFilters.anyActive,
    routeFilters.state,
    statusFilters.anyActive,
    statusFilters.state,
  ])

  return (
    <Page includeHomeLink={false}>
      <Row className="my-3">
        <Col>
          <Link id="new-disruption-link" to="/disruptions/new">
            <PrimaryButton filled>+ create new</PrimaryButton>
          </Link>
        </Col>
        <Col xs={3}>
          <Form.Control
            type="text"
            value={searchQuery}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
              setSearchQuery(e.target.value)
            }
            placeholder="search"
          />
        </Col>
      </Row>
      <Row>
        <Col>
          <div className="d-flex align-items-center">
            <RouteFilterToggleGroup
              routes={[
                "Red",
                "Blue",
                "Orange",
                "Green-B",
                "Green-C",
                "Green-D",
                "Green-E",
                "Mattapan",
                "Commuter",
              ]}
              toggleRouteFilterState={routeFilters.toggleFilter}
              isRouteActive={routeFilters.isFilterActive}
            />
            <div>
              <SecondaryButton
                id="status-filter-toggle-published-ready"
                disabled={view === "calendar"}
                className={classnames("mx-2", {
                  active:
                    statusFilters.state.published && statusFilters.state.ready,
                })}
                onClick={() =>
                  statusFilters.updateFiltersState({
                    ...statusFilters.state,
                    published: !statusFilters.state.published,
                    ready: !statusFilters.state.ready,
                  })
                }
              >
                published/ready
              </SecondaryButton>
              <SecondaryButton
                disabled={view === "calendar"}
                id="status-filter-toggle-needs-review"
                className={classnames("mx-2", {
                  active: statusFilters.state.needs_review,
                })}
                onClick={() => statusFilters.toggleFilter("needs_review")}
              >
                needs review
              </SecondaryButton>
            </div>
            {(routeFilters.anyActive ||
              (statusFilters.anyActive && view !== "calendar")) && (
              <LinkButton
                id="clear-filter"
                onClick={(e) => {
                  e.preventDefault()
                  routeFilters.clearFilters()
                  statusFilters.updateFiltersState({
                    needs_review: false,
                    ready: false,
                    published: view === "calendar",
                  })
                }}
              >
                clear filter
              </LinkButton>
            )}
            <SecondaryButton
              id="view-toggle"
              className="my-3 ml-auto"
              onClick={toggleView}
            >
              {"\u2b12 " +
                (view === "calendar" ? "list view" : "calendar view")}
            </SecondaryButton>
          </div>
        </Col>
      </Row>
      <Row>
        <Col>
          {view === "table" ? (
            <DisruptionTable
              disruptionRevisions={filteredDisruptionRevisions}
            />
          ) : (
            <DisruptionCalendar
              disruptionRevisions={filteredDisruptionRevisions}
            />
          )}
        </Col>
      </Row>
    </Page>
  )
}

const DisruptionIndex = () => {
  const view = useDisruptionViewParam()
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
  }, [view])

  if (disruptions === "error") {
    return <div>Something went wrong</div>
  } else {
    return <DisruptionIndexView disruptions={disruptions} />
  }
}

export {
  DisruptionIndex,
  RouteFilterToggle,
  DisruptionIndexView,
  Routes,
  getRouteIcon,
  getRouteColor,
}
