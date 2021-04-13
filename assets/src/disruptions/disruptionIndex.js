"use strict"
var __assign =
  (this && this.__assign) ||
  function () {
    __assign =
      Object.assign ||
      function (t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
          s = arguments[i]
          for (var p in s)
            if (Object.prototype.hasOwnProperty.call(s, p)) t[p] = s[p]
        }
        return t
      }
    return __assign.apply(this, arguments)
  }
var __createBinding =
  (this && this.__createBinding) ||
  (Object.create
    ? function (o, m, k, k2) {
        if (k2 === undefined) k2 = k
        Object.defineProperty(o, k2, {
          enumerable: true,
          get: function () {
            return m[k]
          },
        })
      }
    : function (o, m, k, k2) {
        if (k2 === undefined) k2 = k
        o[k2] = m[k]
      })
var __setModuleDefault =
  (this && this.__setModuleDefault) ||
  (Object.create
    ? function (o, v) {
        Object.defineProperty(o, "default", { enumerable: true, value: v })
      }
    : function (o, v) {
        o["default"] = v
      })
var __importStar =
  (this && this.__importStar) ||
  function (mod) {
    if (mod && mod.__esModule) return mod
    var result = {}
    if (mod != null)
      for (var k in mod)
        if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k))
          __createBinding(result, mod, k)
    __setModuleDefault(result, mod)
    return result
  }
var __spreadArray =
  (this && this.__spreadArray) ||
  function (to, from) {
    for (var i = 0, il = from.length, j = to.length; i < il; i++, j++)
      to[j] = from[i]
    return to
  }
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
exports.revisionMatchesFilters = exports.getRouteColor = exports.getRouteIcon = exports.DisruptionIndexView = exports.RouteFilterToggle = exports.DisruptionIndex = void 0
var React = __importStar(require("react"))
var react_router_dom_1 = require("react-router-dom")
var classnames_1 = __importDefault(require("classnames"))
var Row_1 = __importDefault(require("react-bootstrap/Row"))
var Col_1 = __importDefault(require("react-bootstrap/Col"))
var Form_1 = __importDefault(require("react-bootstrap/Form"))
var button_1 = require("../button")
var icons_1 = __importDefault(require("../icons"))
var disruptionTable_1 = require("./disruptionTable")
var disruptionCalendar_1 = require("./disruptionCalendar")
var api_1 = require("../api")
var jsonApi_1 = require("../jsonApi")
var page_1 = require("../page")
var disruption_1 = __importStar(require("../models/disruption"))
var checkbox_1 = __importDefault(require("../checkbox"))
var confirmationModal_1 = require("../confirmationModal")
var getRouteIcon = function (route) {
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
exports.getRouteIcon = getRouteIcon
var getRouteColor = function (route) {
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
exports.getRouteColor = getRouteColor
// eslint-disable-next-line react/display-name
var RouteFilterToggle = React.memo(function (_a) {
  var route = _a.route,
    active = _a.active,
    onClick = _a.onClick
  return React.createElement(
    "a",
    {
      className: classnames_1.default("mr-2 m-disruption-index__route_filter", {
        active: active,
      }),
      id: "route-filter-toggle-" + route,
      onClick: function () {
        return onClick(route)
      },
    },
    React.createElement(icons_1.default, {
      size: "lg",
      type: getRouteIcon(route),
    })
  )
})
exports.RouteFilterToggle = RouteFilterToggle
var RouteFilterToggleGroup = function (_a) {
  var routes = _a.routes,
    toggleRouteFilterState = _a.toggleRouteFilterState,
    isRouteActive = _a.isRouteActive
  return React.createElement(
    "div",
    { className: "mb-1" },
    routes.map(function (route) {
      return React.createElement(RouteFilterToggle, {
        key: route,
        route: route,
        onClick: function () {
          return toggleRouteFilterState(route)
        },
        active: isRouteActive(route),
      })
    })
  )
}
var revisionMatchesFilters = function (
  revision,
  query,
  routeFilters,
  statusFilters,
  dateFilters,
  pastThreshold
) {
  return !!(
    (revision.isActive ||
      revision.status !== disruption_1.DisruptionView.Published) &&
    (dateFilters.anyActive ||
      (revision.endDate && revision.endDate > pastThreshold)) &&
    (!routeFilters.anyActive ||
      (revision.adjustments || []).some(function (adj) {
        return (
          adj.routeId &&
          (routeFilters.state[adj.routeId] ||
            (routeFilters.state.Commuter && adj.routeId.includes("CR-")))
        )
      })) &&
    (!statusFilters.anyActive ||
      (revision.status === disruption_1.DisruptionView.Published &&
        statusFilters.state.published) ||
      (revision.status === disruption_1.DisruptionView.Ready &&
        statusFilters.state.ready) ||
      (revision.status === disruption_1.DisruptionView.Draft &&
        statusFilters.state.needs_review)) &&
    (revision.adjustments || []).some(function (adj) {
      return adj.sourceLabel && adj.sourceLabel.toLowerCase().includes(query)
    })
  )
}
exports.revisionMatchesFilters = revisionMatchesFilters
var useFilterGroup = function (group) {
  var _a = React.useState(
      group.reduce(function (acc, curr) {
        var _a
        return __assign(__assign({}, acc), ((_a = {}), (_a[curr] = false), _a))
      }, {})
    ),
    filtersState = _a[0],
    updateFiltersState = _a[1]
  var toggleFilter = React.useCallback(
    function (filter) {
      var _a
      updateFiltersState(
        __assign(
          __assign({}, filtersState),
          ((_a = {}), (_a[filter] = !filtersState[filter]), _a)
        )
      )
    },
    [filtersState, updateFiltersState]
  )
  var clearFilters = React.useCallback(
    function () {
      updateFiltersState({})
    },
    [updateFiltersState]
  )
  var anyActive = React.useMemo(
    function () {
      return Object.values(filtersState).some(Boolean)
    },
    [filtersState]
  )
  var isFilterActive = React.useCallback(
    function (route) {
      return !anyActive || !!filtersState[route]
    },
    [anyActive, filtersState]
  )
  return {
    state: filtersState,
    anyActive: anyActive,
    isFilterActive: isFilterActive,
    toggleFilter: toggleFilter,
    clearFilters: clearFilters,
    updateFiltersState: updateFiltersState,
  }
}
var DisruptionIndexView = function (_a) {
  var disruptions = _a.disruptions,
    fetchDisruptions = _a.fetchDisruptions,
    now = _a.now
  var routeFilters = useFilterGroup([
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
  var dateFilters = useFilterGroup(["include_past"])
  var statusFilters = useFilterGroup(["published", "ready", "needs_review"])
  var _b = React.useState("table"),
    view = _b[0],
    setView = _b[1]
  var toggleView = React.useCallback(
    function () {
      if (view === "table") {
        setView("calendar")
        dateFilters.updateFiltersState({ include_past: true })
        statusFilters.updateFiltersState({ published: true })
      } else {
        dateFilters.clearFilters()
        statusFilters.clearFilters()
        setView("table")
      }
    },
    [view, setView, statusFilters, dateFilters]
  )
  var _c = React.useState(""),
    searchQuery = _c[0],
    setSearchQuery = _c[1]
  var pastThreshold = React.useMemo(
    function () {
      var date = now ? new Date(now.valueOf()) : new Date()
      date.setDate(date.getDate() - 7)
      return date
    },
    [now]
  )
  var filteredDisruptionRevisions = React.useMemo(
    function () {
      var query = searchQuery.toLowerCase()
      return disruptions.reduce(function (acc, curr) {
        var _a = curr.getUniqueRevisions(),
          published = _a.published,
          ready = _a.ready,
          draft = _a.draft
        var uniqueRevisions = [published, ready, draft].filter(function (x) {
          return !!x
        })
        var matchingRevisions = uniqueRevisions.filter(function (revision) {
          return revisionMatchesFilters(
            revision,
            query,
            routeFilters,
            statusFilters,
            dateFilters,
            pastThreshold
          )
        })
        // The table view displays *all* revisions of disruptions which have at
        // least one revision that matches the filters. The calendar view only
        // displays the matching revisions themselves, otherwise there would be
        // duplicate entries.
        if (matchingRevisions.length > 0) {
          if (view === "table") {
            return __spreadArray(__spreadArray([], acc), uniqueRevisions)
          } else {
            return __spreadArray(__spreadArray([], acc), matchingRevisions)
          }
        } else {
          return acc
        }
      }, [])
    },
    [
      disruptions,
      searchQuery,
      routeFilters,
      statusFilters,
      dateFilters,
      pastThreshold,
      view,
    ]
  )
  var _d = React.useState({}),
    selectedRevisions = _d[0],
    setSelectedRevisions = _d[1]
  var selectableFilteredRevisions = React.useMemo(
    function () {
      return filteredDisruptionRevisions.filter(function (x) {
        return x.status === disruption_1.DisruptionView.Draft
      })
    },
    [filteredDisruptionRevisions]
  )
  var selectedFilteredRevisions = React.useMemo(
    function () {
      return selectableFilteredRevisions.filter(function (x) {
        return x.id && selectedRevisions[x.id]
      })
    },
    [selectableFilteredRevisions, selectedRevisions]
  )
  var availableActions = React.useMemo(
    function () {
      if (
        selectedFilteredRevisions.length &&
        selectedFilteredRevisions.every(function (x) {
          return x.status === disruption_1.DisruptionView.Draft
        })
      ) {
        return ["mark_ready"]
      } else {
        return []
      }
    },
    [selectedFilteredRevisions]
  )
  var markReady = React.useCallback(
    function () {
      var revisionIds = selectedFilteredRevisions
        .map(function (x) {
          return x.id
        })
        .join()
      api_1
        .apiSend({
          method: "POST",
          json: JSON.stringify({
            revision_ids: revisionIds,
          }),
          url: "/api/ready_notice/",
        })
        .then(function () {
          fetchDisruptions()
        })
        .catch(function () {
          // eslint-disable-next-line no-console
          console.log("failed to mark revisions as ready: " + revisionIds)
        })
    },
    [selectedFilteredRevisions, fetchDisruptions]
  )
  var toggleRevisionSelection = React.useCallback(
    function (id) {
      var _a
      setSelectedRevisions(
        __assign(
          __assign({}, selectedRevisions),
          ((_a = {}), (_a[id] = !selectedRevisions[id]), _a)
        )
      )
    },
    [selectedRevisions, setSelectedRevisions]
  )
  var _e = React.useState(false),
    actionsMenuOpen = _e[0],
    toggleActionsMenuOpen = _e[1]
  var toggleSelectAll = React.useCallback(
    function () {
      if (
        Object.keys(selectedRevisions).some(function (x) {
          return selectedRevisions[x]
        })
      ) {
        setSelectedRevisions({})
      } else {
        setSelectedRevisions(
          filteredDisruptionRevisions.reduce(function (acc, curr) {
            var _a
            return __assign(
              __assign({}, acc),
              ((_a = {}), (_a[curr.id] = true), _a)
            )
          }, {})
        )
      }
    },
    [selectedRevisions, setSelectedRevisions, filteredDisruptionRevisions]
  )
  return React.createElement(
    page_1.Page,
    { includeHomeLink: false },
    React.createElement(
      Row_1.default,
      { className: "my-3" },
      React.createElement(
        Col_1.default,
        null,
        React.createElement(
          react_router_dom_1.Link,
          { id: "new-disruption-link", to: "/disruptions/new" },
          React.createElement(
            button_1.PrimaryButton,
            { filled: true },
            "+ create new"
          )
        )
      ),
      React.createElement(
        Col_1.default,
        { xs: 3 },
        React.createElement(Form_1.default.Control, {
          type: "text",
          value: searchQuery,
          onChange: function (e) {
            return setSearchQuery(e.target.value)
          },
          placeholder: "search",
        })
      )
    ),
    React.createElement(
      Row_1.default,
      null,
      React.createElement(
        Col_1.default,
        null,
        React.createElement(
          "div",
          { className: "d-flex align-items-center" },
          React.createElement(RouteFilterToggleGroup, {
            routes: [
              "Red",
              "Blue",
              "Orange",
              "Green-B",
              "Green-C",
              "Green-D",
              "Green-E",
              "Mattapan",
              "Commuter",
            ],
            toggleRouteFilterState: routeFilters.toggleFilter,
            isRouteActive: routeFilters.isFilterActive,
          }),
          React.createElement(
            button_1.SecondaryButton,
            {
              disabled: view === "calendar",
              id: "status-filter-toggle-needs-review",
              className: classnames_1.default("mx-2", {
                active: statusFilters.state.needs_review,
              }),
              onClick: function () {
                return statusFilters.toggleFilter("needs_review")
              },
            },
            "needs review"
          ),
          React.createElement(
            button_1.SecondaryButton,
            {
              disabled: view === "calendar",
              id: "date-filter-toggle-include-past",
              className: classnames_1.default("mx-2", {
                active: dateFilters.state.include_past,
              }),
              onClick: function () {
                return dateFilters.toggleFilter("include_past")
              },
            },
            "include past"
          ),
          (routeFilters.anyActive ||
            (dateFilters.anyActive && view !== "calendar") ||
            (statusFilters.anyActive && view !== "calendar")) &&
            React.createElement(
              button_1.LinkButton,
              {
                id: "clear-filter",
                onClick: function (e) {
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
                },
              },
              "reset filters"
            ),
          React.createElement(
            "div",
            { className: "my-3 ml-auto" },
            React.createElement(
              button_1.SecondaryButton,
              {
                disabled:
                  view === "calendar" ||
                  (!actionsMenuOpen && !selectableFilteredRevisions.length),
                className: classnames_1.default({
                  active: actionsMenuOpen,
                }),
                id: "actions",
                onClick: function () {
                  if (actionsMenuOpen) {
                    toggleActionsMenuOpen(false)
                    setSelectedRevisions({})
                  } else {
                    toggleActionsMenuOpen(!actionsMenuOpen)
                  }
                },
              },
              "actions"
            ),
            React.createElement(
              button_1.SecondaryButton,
              { id: "view-toggle", className: "ml-2", onClick: toggleView },
              "\u2b12 " + (view === "calendar" ? "list view" : "calendar view")
            )
          )
        )
      )
    ),
    actionsMenuOpen &&
      React.createElement(
        Row_1.default,
        null,
        React.createElement(
          Col_1.default,
          null,
          React.createElement(
            "div",
            { className: "d-flex p-2 mb-3 border-secondary border rounded" },
            React.createElement(
              "div",
              {
                className:
                  "d-flex align-items-center border-right border-secondary mr-3",
              },
              React.createElement(checkbox_1.default, {
                id: "toggle-all",
                checked: selectedFilteredRevisions.length > 0,
                containerClassName: "my-2",
                onChange: toggleSelectAll,
              }),
              React.createElement("strong", { className: "mx-3" }, "select")
            ),
            React.createElement(
              "div",
              { className: "d-flex" },
              React.createElement(confirmationModal_1.ConfirmationModal, {
                confirmationButtonText: "yes, mark as ready",
                confirmationText:
                  "Are you sure you want to mark these revisions as ready?",
                onClickConfirm: markReady,
                Component: React.createElement(
                  button_1.SecondaryButton,
                  {
                    id: "mark-ready",
                    disabled: !availableActions.includes("mark_ready"),
                  },
                  "mark as ready"
                ),
              })
            )
          )
        )
      ),
    React.createElement(
      Row_1.default,
      null,
      React.createElement(
        Col_1.default,
        null,
        view === "table"
          ? React.createElement(disruptionTable_1.DisruptionTable, {
              selectEnabled: actionsMenuOpen,
              toggleRevisionSelection: toggleRevisionSelection,
              disruptionRevisions: filteredDisruptionRevisions.map(function (
                revision
              ) {
                return {
                  revision: revision,
                  selected: !!revision.id && !!selectedRevisions[revision.id],
                  selectable:
                    revision.status === disruption_1.DisruptionView.Draft,
                }
              }),
            })
          : React.createElement(disruptionCalendar_1.DisruptionCalendar, {
              disruptionRevisions: filteredDisruptionRevisions,
            })
      )
    )
  )
}
exports.DisruptionIndexView = DisruptionIndexView
var DisruptionIndex = function (_a) {
  var now = _a.now
  var _b = React.useState([]),
    disruptions = _b[0],
    setDisruptions = _b[1]
  var fetchDisruptions = React.useCallback(
    function () {
      api_1
        .apiGet({
          url: "/api/disruptions",
          parser: jsonApi_1.toModelObject,
          defaultResult: "error",
        })
        .then(function (result) {
          if (
            Array.isArray(result) &&
            result.every(function (res) {
              return res instanceof disruption_1.default
            })
          ) {
            setDisruptions(result)
          } else {
            setDisruptions("error")
          }
        })
    },
    [setDisruptions]
  )
  React.useEffect(
    function () {
      fetchDisruptions()
    },
    [fetchDisruptions]
  )
  if (disruptions === "error") {
    return React.createElement("div", null, "Something went wrong")
  } else {
    return React.createElement(DisruptionIndexView, {
      disruptions: disruptions,
      fetchDisruptions: fetchDisruptions,
      now: now,
    })
  }
}
exports.DisruptionIndex = DisruptionIndex
