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
import DisruptionRevision from "../models/disruptionRevision"
import { apiGet, apiSend } from "../api"
import { JsonApiResponse, toModelObject } from "../jsonApi"
import { Page } from "../page"
import Disruption, { DisruptionView } from "../models/disruption"
import Checkbox from "../checkbox"
import { ConfirmationModal } from "../confirmationModal"

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

type FilterGroupState<G extends string> = {
  [K in G]?: boolean
}

type FilterGroup<G extends string> = {
  state: FilterGroupState<G>
  anyActive: boolean
  isFilterActive: (filter: G) => boolean
  toggleFilter: (filter: G) => void
  clearFilters: () => void
  updateFiltersState: React.Dispatch<FilterGroupState<G>>
}

const revisionMatchesFilters = (
  revision: DisruptionRevision,
  query: string,
  routeFilters: FilterGroup<Routes>,
  statusFilters: FilterGroup<"published" | "ready" | "needs_review">,
  dateFilters: FilterGroup<"include_past">,
  pastThreshold: Date
) =>
  !!(
    (revision.isActive || revision.status !== DisruptionView.Published) &&
    (dateFilters.anyActive ||
      (revision.endDate && revision.endDate > pastThreshold)) &&
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
      (revision.status === DisruptionView.Ready && statusFilters.state.ready) ||
      (revision.status === DisruptionView.Draft &&
        statusFilters.state.needs_review)) &&
    (revision.adjustments || []).some(
      (adj) => adj.sourceLabel && adj.sourceLabel.toLowerCase().includes(query)
    )
  )

const useFilterGroup = <G extends string>(group: G[]): FilterGroup<G> => {
  const [filtersState, updateFiltersState] = React.useState<
    { [filter in G]?: boolean }
  >(
    group.reduce((acc: FilterGroupState<G>, curr: G) => {
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
  fetchDisruptions: () => void
  now?: Date
}

type RevisionActions = "mark_ready"

const DisruptionIndexView = ({
  disruptions,
  fetchDisruptions,
  now,
}: DisruptionIndexProps) => {
  const routeFilters = useFilterGroup<Routes>([
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

  const dateFilters = useFilterGroup(["include_past"])
  const statusFilters = useFilterGroup(["published", "ready", "needs_review"])
  const [view, setView] = React.useState<"table" | "calendar">("table")
  const toggleView = React.useCallback(() => {
    if (view === "table") {
      setView("calendar")
      dateFilters.updateFiltersState({ include_past: true })
      statusFilters.updateFiltersState({ published: true })
    } else {
      dateFilters.clearFilters()
      statusFilters.clearFilters()
      setView("table")
    }
  }, [view, setView, statusFilters, dateFilters])

  const [searchQuery, setSearchQuery] = React.useState<string>("")

  const pastThreshold = React.useMemo(() => {
    const date = now ? new Date(now.valueOf()) : new Date()
    date.setDate(date.getDate() - 7)
    return date
  }, [now])

  const filteredDisruptionRevisions = React.useMemo(() => {
    const query = searchQuery.toLowerCase()
    return disruptions.reduce((acc, curr) => {
      const { published, ready, draft } = curr.getUniqueRevisions()
      const uniqueRevisions = [published, ready, draft].filter(
        (x) => !!x
      ) as DisruptionRevision[]
      const matchingRevisions = uniqueRevisions.filter((revision) =>
        revisionMatchesFilters(
          revision,
          query,
          routeFilters,
          statusFilters,
          dateFilters,
          pastThreshold
        )
      )

      // The table view displays *all* revisions of disruptions which have at
      // least one revision that matches the filters. The calendar view only
      // displays the matching revisions themselves, otherwise there would be
      // duplicate entries.
      if (matchingRevisions.length > 0) {
        if (view === "table") {
          return [...acc, ...uniqueRevisions]
        } else {
          return [...acc, ...matchingRevisions]
        }
      } else {
        return acc
      }
    }, [] as DisruptionRevision[])
  }, [
    disruptions,
    searchQuery,
    routeFilters,
    statusFilters,
    dateFilters,
    pastThreshold,
    view,
  ])

  const [selectedRevisions, setSelectedRevisions] = React.useState<{
    [key: string]: boolean | undefined
  }>({})

  const selectableFilteredRevisions = React.useMemo(() => {
    return filteredDisruptionRevisions.filter(
      (x) => x.status === DisruptionView.Draft
    )
  }, [filteredDisruptionRevisions])

  const selectedFilteredRevisions = React.useMemo(() => {
    return selectableFilteredRevisions.filter(
      (x) => x.id && selectedRevisions[x.id]
    )
  }, [selectableFilteredRevisions, selectedRevisions])

  const availableActions: RevisionActions[] = React.useMemo(() => {
    if (
      selectedFilteredRevisions.length &&
      selectedFilteredRevisions.every((x) => x.status === DisruptionView.Draft)
    ) {
      return ["mark_ready"]
    } else {
      return []
    }
  }, [selectedFilteredRevisions])

  const markReady = React.useCallback(() => {
    const revisionIds = selectedFilteredRevisions.map((x) => x.id).join()
    apiSend({
      method: "POST",
      json: JSON.stringify({
        revision_ids: revisionIds,
      }),
      url: "/api/ready_notice/",
    })
      .then(() => {
        fetchDisruptions()
      })
      .catch(() => {
        // eslint-disable-next-line no-console
        console.log(`failed to mark revisions as ready: ${revisionIds}`)
      })
  }, [selectedFilteredRevisions, fetchDisruptions])

  const toggleRevisionSelection = React.useCallback(
    (id: string) => {
      setSelectedRevisions({
        ...selectedRevisions,
        [id]: !selectedRevisions[id],
      })
    },
    [selectedRevisions, setSelectedRevisions]
  )

  const [actionsMenuOpen, toggleActionsMenuOpen] =
    React.useState<boolean>(false)

  const toggleSelectAll = React.useCallback(() => {
    if (Object.keys(selectedRevisions).some((x) => selectedRevisions[x])) {
      setSelectedRevisions({})
    } else {
      setSelectedRevisions(
        filteredDisruptionRevisions.reduce((acc, curr) => {
          return {
            ...acc,
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            [curr.id!]: true,
          }
        }, {} as { [key: string]: boolean | undefined })
      )
    }
  }, [selectedRevisions, setSelectedRevisions, filteredDisruptionRevisions])

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

            <SecondaryButton
              disabled={view === "calendar"}
              id="date-filter-toggle-include-past"
              className={classnames("mx-2", {
                active: dateFilters.state.include_past,
              })}
              onClick={() => dateFilters.toggleFilter("include_past")}
            >
              include past
            </SecondaryButton>

            {(routeFilters.anyActive ||
              (dateFilters.anyActive && view !== "calendar") ||
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
                  dateFilters.updateFiltersState({
                    include_past: view === "calendar",
                  })
                }}
              >
                reset filters
              </LinkButton>
            )}
            <div className="my-3 ml-auto">
              <SecondaryButton
                disabled={
                  view === "calendar" ||
                  (!actionsMenuOpen && !selectableFilteredRevisions.length)
                }
                className={classnames({
                  active: actionsMenuOpen,
                })}
                id="actions"
                onClick={() => {
                  if (actionsMenuOpen) {
                    toggleActionsMenuOpen(false)
                    setSelectedRevisions({})
                  } else {
                    toggleActionsMenuOpen(!actionsMenuOpen)
                  }
                }}
              >
                actions
              </SecondaryButton>
              <SecondaryButton
                id="view-toggle"
                className="ml-2"
                onClick={toggleView}
              >
                {"\u2b12 " +
                  (view === "calendar" ? "list view" : "calendar view")}
              </SecondaryButton>
            </div>
          </div>
        </Col>
      </Row>
      {actionsMenuOpen && (
        <Row>
          <Col>
            <div className="d-flex p-2 mb-3 border-secondary border rounded">
              <div className="d-flex align-items-center border-right border-secondary mr-3">
                <Checkbox
                  id="toggle-all"
                  checked={selectedFilteredRevisions.length > 0}
                  containerClassName="my-2"
                  onChange={toggleSelectAll}
                />
                <strong className="mx-3">select</strong>
              </div>
              <div className="d-flex">
                <ConfirmationModal
                  confirmationButtonText="yes, mark as ready"
                  confirmationText="Are you sure you want to mark these revisions as ready?"
                  onClickConfirm={markReady}
                  Component={
                    <SecondaryButton
                      id="mark-ready"
                      disabled={!availableActions.includes("mark_ready")}
                    >
                      mark as ready
                    </SecondaryButton>
                  }
                />
              </div>
            </div>
          </Col>
        </Row>
      )}
      <Row>
        <Col>
          {view === "table" ? (
            <DisruptionTable
              selectEnabled={actionsMenuOpen}
              toggleRevisionSelection={toggleRevisionSelection}
              disruptionRevisions={filteredDisruptionRevisions.map(
                (revision) => {
                  return {
                    revision,
                    selected: !!revision.id && !!selectedRevisions[revision.id],
                    selectable: revision.status === DisruptionView.Draft,
                  }
                }
              )}
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

const DisruptionIndex = ({ now }: { now?: Date }) => {
  const [disruptions, setDisruptions] = React.useState<Disruption[] | "error">(
    []
  )

  const fetchDisruptions = React.useCallback(() => {
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
  }, [setDisruptions])

  React.useEffect(() => {
    fetchDisruptions()
  }, [fetchDisruptions])

  if (disruptions === "error") {
    return <div>Something went wrong</div>
  } else {
    return (
      <DisruptionIndexView
        disruptions={disruptions}
        fetchDisruptions={fetchDisruptions}
        now={now}
      />
    )
  }
}

export {
  DisruptionIndex,
  RouteFilterToggle,
  DisruptionIndexView,
  Routes,
  getRouteIcon,
  getRouteColor,
  revisionMatchesFilters,
  FilterGroup,
}
