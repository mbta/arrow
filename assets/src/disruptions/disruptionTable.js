"use strict"
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
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
exports.DisruptionTable = exports.DisruptionTableHeader = void 0
var React = __importStar(require("react"))
var classnames_1 = __importDefault(require("classnames"))
var Table_1 = __importDefault(require("react-bootstrap/Table"))
var react_router_dom_1 = require("react-router-dom")
var disruptions_1 = require("./disruptions")
var time_1 = require("./time")
var disruption_1 = require("../models/disruption")
var icons_1 = __importDefault(require("../icons"))
var disruptionIndex_1 = require("./disruptionIndex")
var button_1 = require("../button")
var disruptionCalendar_1 = require("./disruptionCalendar")
var checkbox_1 = __importDefault(require("../checkbox"))
var DisruptionTableHeader = function (_a) {
  var sortable = _a.sortable,
    sortOrder = _a.sortOrder,
    active = _a.active,
    label = _a.label,
    onClick = _a.onClick
  return React.createElement(
    "th",
    null,
    React.createElement(
      "span",
      {
        onClick: onClick,
        className: classnames_1.default({
          "m-disruption-table__sortable": sortable,
          active: active,
        }),
      },
      label,
      React.createElement(
        "span",
        { className: "m-disruption-table__sortable-indicator mx-1" },
        sortable && (active && sortOrder === "desc" ? "\u2193" : "\u2191")
      )
    )
  )
}
exports.DisruptionTableHeader = DisruptionTableHeader
var convertSortable = function (key, item) {
  switch (key) {
    case "daysAndTimes": {
      return disruptionCalendar_1.dayNameToInt(item.daysOfWeek[0].dayName)
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
var getStatusText = function (status) {
  switch (status) {
    case disruption_1.DisruptionView.Draft: {
      return "needs review"
    }
    case disruption_1.DisruptionView.Ready: {
      return "ready"
    }
    case disruption_1.DisruptionView.Published: {
      return "published"
    }
  }
}
var isDiff = function (baseValue, currentValue) {
  return Array.isArray(baseValue) && Array.isArray(currentValue)
    ? baseValue.length !== currentValue.length ||
        baseValue.some(function (x, i) {
          return x !== currentValue[i]
        })
    : baseValue == null || baseValue !== currentValue
}
var DisruptionTableRow = function (_a) {
  var _b, _c
  var base = _a.base,
    current = _a.current,
    selectEnabled = _a.selectEnabled,
    selected = _a.selected,
    selectable = _a.selectable,
    toggleSelection = _a.toggleSelection
  var adjustmentsEqual =
    current.disruptionId ===
      (base === null || base === void 0 ? void 0 : base.disruptionId) &&
    current.label === (base === null || base === void 0 ? void 0 : base.label)
  return React.createElement(
    "tr",
    {
      "data-revision-id": current.id,
      className:
        current.status === disruption_1.DisruptionView.Draft
          ? "bg-light-pink"
          : "",
    },
    selectEnabled &&
      React.createElement(
        "td",
        { className: adjustmentsEqual ? "border-0" : "" },
        selectable &&
          React.createElement(checkbox_1.default, {
            id: "revision-" + current.id + "-toggle",
            checked: selected,
            onChange: function () {
              return current.id && toggleSelection(current.id)
            },
          })
      ),
    adjustmentsEqual
      ? React.createElement(
          "td",
          { className: "border-0 text-right" },
          "\u2198"
        )
      : React.createElement(
          "td",
          {
            className: isDiff(
              base === null || base === void 0 ? void 0 : base.label,
              current.label
            )
              ? ""
              : "text-muted",
          },
          current.adjustments.map(function (adj) {
            return React.createElement(
              "div",
              {
                key: current.id + adj.id,
                className: "d-flex align-items-center",
              },
              React.createElement(icons_1.default, {
                size: "sm",
                key: adj.routeId,
                type: disruptionIndex_1.getRouteIcon(adj.routeId),
                className: "mr-3",
              }),
              adj.sourceLabel
            )
          })
        ),
    !!current.startDate && !!current.endDate && current.isActive
      ? React.createElement(
          "td",
          null,
          React.createElement(
            "div",
            {
              className: isDiff(
                (_b =
                  base === null || base === void 0
                    ? void 0
                    : base.startDate) === null || _b === void 0
                  ? void 0
                  : _b.getTime(),
                current.startDate.getTime()
              )
                ? ""
                : "text-muted",
            },
            disruptions_1.formatDisruptionDate(current.startDate)
          ),
          React.createElement(
            "div",
            {
              className: isDiff(
                (_c =
                  base === null || base === void 0 ? void 0 : base.endDate) ===
                  null || _c === void 0
                  ? void 0
                  : _c.getTime(),
                current.endDate.getTime()
              )
                ? ""
                : "text-muted",
            },
            disruptions_1.formatDisruptionDate(current.endDate)
          )
        )
      : React.createElement("td", null, "Marked for deletion"),
    React.createElement(
      "td",
      {
        className: isDiff(
          base === null || base === void 0
            ? void 0
            : base.exceptions.map(function (exc) {
                return exc.excludedDate.getTime()
              }),
          current.exceptions.map(function (exc) {
            return exc.excludedDate.getTime()
          })
        )
          ? ""
          : "text-muted",
      },
      current.isActive && current.exceptions.length
    ),
    React.createElement(
      "td",
      {
        className: isDiff(
          base === null || base === void 0 ? void 0 : base.daysAndTimes,
          current.daysAndTimes
        )
          ? ""
          : "text-muted",
      },
      current.isActive &&
        current.daysAndTimes.split(", ").map(function (line, ix) {
          return React.createElement("div", { key: ix }, line)
        })
    ),
    React.createElement(
      "td",
      null,
      React.createElement(
        button_1.Button,
        {
          className: "m-disruption-table__status-indicator",
          variant:
            "outline-" +
            (current.status === disruption_1.DisruptionView.Draft
              ? "primary"
              : "dark"),
        },
        getStatusText(current.status || disruption_1.DisruptionView.Draft)
      )
    ),
    React.createElement(
      "td",
      null,
      React.createElement(
        react_router_dom_1.Link,
        {
          to:
            "/disruptions/" +
            current.disruptionId +
            "?v=" +
            (current.status === disruption_1.DisruptionView.Draft
              ? "draft"
              : current.status === disruption_1.DisruptionView.Ready
              ? "ready"
              : "published"),
        },
        current.disruptionId
      )
    )
  )
}
var DisruptionTable = function (_a) {
  var disruptionRevisions = _a.disruptionRevisions,
    selectEnabled = _a.selectEnabled,
    toggleRevisionSelection = _a.toggleRevisionSelection
  var _b = React.useState({
      by: "label",
      order: "asc",
    }),
    sortState = _b[0],
    setSortState = _b[1]
  var disruptionRows = React.useMemo(
    function () {
      return disruptionRevisions.map(function (_a) {
        var revision = _a.revision,
          selected = _a.selected,
          selectable = _a.selectable
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
              ? time_1.parseDaysAndTimes(revision.daysOfWeek)
              : "",
          label: revision.adjustments.reduce(function (acc, curr) {
            return acc + curr.sourceLabel
          }, ""),
          adjustments: revision.adjustments,
          isActive: revision.isActive,
          selected: selected,
          selectable: selectable,
        }
      })
    },
    [disruptionRevisions]
  )
  var sortedDisruptions = React.useMemo(
    function () {
      var by = sortState.by,
        order = sortState.order
      return disruptionRows.sort(function (aRaw, bRaw) {
        var a = convertSortable(by, aRaw)
        var b = convertSortable(by, bRaw)
        // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        if (a > b) {
          return order === "asc" ? 1 : -1
          // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
        } else if (a < b) {
          return order === "asc" ? -1 : 1
        } else {
          return 0
        }
      })
    },
    [sortState, disruptionRows]
  )
  var handleChangeSort = React.useCallback(
    function (field) {
      setSortState({
        by: field,
        order:
          field !== sortState.by || sortState.order === "desc" ? "asc" : "desc",
      })
    },
    [sortState]
  )
  return React.createElement(
    Table_1.default,
    { className: "m-disruption-table border-top-dark" },
    React.createElement(
      "thead",
      null,
      React.createElement(
        "tr",
        null,
        selectEnabled && React.createElement("td", null),
        React.createElement(DisruptionTableHeader, {
          label: "adjustments",
          sortable: true,
          sortOrder: sortState.order,
          active: sortState.by === "label",
          onClick: function () {
            return handleChangeSort("label")
          },
        }),
        React.createElement(DisruptionTableHeader, {
          label: "date range",
          sortable: true,
          sortOrder: sortState.order,
          active: sortState.by === "startDate",
          onClick: function () {
            return handleChangeSort("startDate")
          },
        }),
        React.createElement(DisruptionTableHeader, {
          label: "except",
          sortable: true,
          sortOrder: sortState.order,
          active: sortState.by === "exceptions",
          onClick: function () {
            return handleChangeSort("exceptions")
          },
        }),
        React.createElement(DisruptionTableHeader, {
          label: "time period",
          sortable: true,
          sortOrder: sortState.order,
          active: sortState.by === "daysAndTimes",
          onClick: function () {
            return handleChangeSort("daysAndTimes")
          },
        }),
        React.createElement(DisruptionTableHeader, {
          label: "status",
          sortable: true,
          sortOrder: sortState.order,
          active: sortState.by === "status",
          onClick: function () {
            return handleChangeSort("status")
          },
        }),
        React.createElement(DisruptionTableHeader, {
          label: "ID",
          sortable: true,
          sortOrder: sortState.order,
          active: sortState.by === "disruptionId",
          onClick: function () {
            return handleChangeSort("disruptionId")
          },
        })
      )
    ),
    React.createElement(
      "tbody",
      null,
      sortedDisruptions.map(function (x, i, self) {
        var base =
          self[i - 1] && self[i - 1].disruptionId === x.disruptionId
            ? self[i - 1]
            : null
        return React.createElement(DisruptionTableRow, {
          key: x.id + "-" + i,
          base: base,
          current: x,
          selectEnabled: selectEnabled,
          selectable: x.selectable,
          selected: x.selected,
          toggleSelection: toggleRevisionSelection,
        })
      })
    )
  )
}
exports.DisruptionTable = DisruptionTable
