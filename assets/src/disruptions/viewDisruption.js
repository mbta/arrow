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
var __awaiter =
  (this && this.__awaiter) ||
  function (thisArg, _arguments, P, generator) {
    function adopt(value) {
      return value instanceof P
        ? value
        : new P(function (resolve) {
            resolve(value)
          })
    }
    return new (P || (P = Promise))(function (resolve, reject) {
      function fulfilled(value) {
        try {
          step(generator.next(value))
        } catch (e) {
          reject(e)
        }
      }
      function rejected(value) {
        try {
          step(generator["throw"](value))
        } catch (e) {
          reject(e)
        }
      }
      function step(result) {
        result.done
          ? resolve(result.value)
          : adopt(result.value).then(fulfilled, rejected)
      }
      step((generator = generator.apply(thisArg, _arguments || [])).next())
    })
  }
var __generator =
  (this && this.__generator) ||
  function (thisArg, body) {
    var _ = {
        label: 0,
        sent: function () {
          if (t[0] & 1) throw t[1]
          return t[1]
        },
        trys: [],
        ops: [],
      },
      f,
      y,
      t,
      g
    return (
      (g = { next: verb(0), throw: verb(1), return: verb(2) }),
      typeof Symbol === "function" &&
        (g[Symbol.iterator] = function () {
          return this
        }),
      g
    )
    function verb(n) {
      return function (v) {
        return step([n, v])
      }
    }
    function step(op) {
      if (f) throw new TypeError("Generator is already executing.")
      while (_)
        try {
          if (
            ((f = 1),
            y &&
              (t =
                op[0] & 2
                  ? y["return"]
                  : op[0]
                  ? y["throw"] || ((t = y["return"]) && t.call(y), 0)
                  : y.next) &&
              !(t = t.call(y, op[1])).done)
          )
            return t
          if (((y = 0), t)) op = [op[0] & 2, t.value]
          switch (op[0]) {
            case 0:
            case 1:
              t = op
              break
            case 4:
              _.label++
              return { value: op[1], done: false }
            case 5:
              _.label++
              y = op[1]
              op = [0]
              continue
            case 7:
              op = _.ops.pop()
              _.trys.pop()
              continue
            default:
              if (
                !((t = _.trys), (t = t.length > 0 && t[t.length - 1])) &&
                (op[0] === 6 || op[0] === 2)
              ) {
                _ = 0
                continue
              }
              if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) {
                _.label = op[1]
                break
              }
              if (op[0] === 6 && _.label < t[1]) {
                _.label = t[1]
                t = op
                break
              }
              if (t && _.label < t[2]) {
                _.label = t[2]
                _.ops.push(op)
                break
              }
              if (t[2]) _.ops.pop()
              _.trys.pop()
              continue
          }
          op = body.call(thisArg, _)
        } catch (e) {
          op = [6, e]
          y = 0
        } finally {
          f = t = 0
        }
      if (op[0] & 5) throw op[1]
      return { value: op[0] ? op[1] : void 0, done: true }
    }
  }
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var React = __importStar(require("react"))
var react_router_dom_1 = require("react-router-dom")
var Alert_1 = __importDefault(require("react-bootstrap/Alert"))
var button_1 = require("../button")
var api_1 = require("../api")
var loading_1 = __importDefault(require("../loading"))
var time_1 = require("./time")
var jsonApi_1 = require("../jsonApi")
var page_1 = require("../page")
var disruption_1 = __importStar(require("../models/disruption"))
var viewToggle_1 = require("./viewToggle")
var Row_1 = __importDefault(require("react-bootstrap/Row"))
var Col_1 = __importDefault(require("react-bootstrap/Col"))
var disruptions_1 = require("./disruptions")
var confirmationModal_1 = require("../confirmationModal")
var adjustmentSummary_1 = require("./adjustmentSummary")
var ViewDisruption = function (_a) {
  var match = _a.match
  return React.createElement(ViewDisruptionForm, {
    disruptionId: match.params.id,
  })
}
var ViewDisruptionForm = function (_a) {
  var disruptionId = _a.disruptionId
  var _b = React.useState(null),
    disruption = _b[0],
    setDisruption = _b[1]
  var history = react_router_dom_1.useHistory()
  var _c = React.useState(false),
    doRedirect = _c[0],
    setDoRedirect = _c[1]
  var _d = React.useState([]),
    deletionErrors = _d[0],
    setDeletionErrors = _d[1]
  var fetchDisruption = React.useCallback(
    function () {
      return api_1
        .apiGet({
          url: "/api/disruptions/" + encodeURIComponent(disruptionId),
          parser: jsonApi_1.toModelObject,
          defaultResult: "error",
        })
        .then(function (result) {
          if (result instanceof disruption_1.default) {
            setDisruption(result)
          } else {
            setDisruption("error")
          }
        })
    },
    [disruptionId, setDisruption]
  )
  React.useEffect(
    function () {
      fetchDisruption()
    },
    [disruptionId, fetchDisruption]
  )
  var view = viewToggle_1.useDisruptionViewParam()
  if (doRedirect) {
    return React.createElement(react_router_dom_1.Redirect, { to: "/" })
  }
  if (disruption && disruption !== "error" && disruption.id) {
    var _e = disruption.getUniqueRevisions(),
      published = _e.published,
      ready = _e.ready,
      draft = _e.draft
    var disruptionRevision_1 = disruption_1.default.uniqueRevisionFromDisruptionForView(
      disruption,
      view
    )
    var exceptionDates = (
      (disruptionRevision_1 === null || disruptionRevision_1 === void 0
        ? void 0
        : disruptionRevision_1.exceptions) || []
    )
      .map(function (exception) {
        return exception.excludedDate
      })
      .filter(function (maybeDate) {
        return typeof maybeDate !== "undefined"
      })
    var disruptionDaysOfWeek = time_1.fromDaysOfWeek(
      (disruptionRevision_1 === null || disruptionRevision_1 === void 0
        ? void 0
        : disruptionRevision_1.daysOfWeek) || []
    )
    var anyDeleted = [published, ready, draft].some(function (x) {
      return !!x && !x.isActive
    })
    if (disruptionDaysOfWeek !== "error") {
      return React.createElement(
        page_1.Page,
        null,
        React.createElement(
          Row_1.default,
          null,
          React.createElement(
            Col_1.default,
            { lg: 7 },
            deletionErrors.length > 0 &&
              React.createElement(
                Alert_1.default,
                { variant: "danger" },
                React.createElement(
                  "ul",
                  null,
                  deletionErrors.map(function (err) {
                    return React.createElement("li", { key: err }, err, " ")
                  })
                )
              ),
            React.createElement(
              "div",
              { className: "m-disruption-details__header" },
              React.createElement(
                "div",
                { className: "d-flex align-items-end" },
                React.createElement("h2", { className: "mb-0" }, "adjustment"),
                React.createElement(
                  "h5",
                  null,
                  "ID",
                  React.createElement(
                    "span",
                    { className: "ml-2 font-weight-normal" },
                    disruptionId
                  )
                )
              ),
              disruptionRevision_1 &&
                (anyDeleted
                  ? React.createElement("div", null, "Marked for deletion")
                  : disruptionRevision_1 &&
                    disruptionRevision_1.startDate &&
                    disruptionRevision_1.startDate >=
                      new Date(new Date().toDateString())
                  ? React.createElement(confirmationModal_1.ConfirmationModal, {
                      confirmationText:
                        !published && !ready
                          ? "Since this draft is not published or ready, this will delete this disruption from Arrow permanently."
                          : "Since this draft is published or ready, this change must be approved first before it is added to GTFS.",
                      confirmationButtonText:
                        !published && !ready
                          ? "yes, delete"
                          : "mark for deletion",
                      onClickConfirm: function () {
                        return __awaiter(void 0, void 0, void 0, function () {
                          var result
                          return __generator(this, function (_a) {
                            switch (_a.label) {
                              case 0:
                                return [
                                  4 /*yield*/,
                                  api_1.apiSend({
                                    url:
                                      "/api/disruptions/" +
                                      encodeURIComponent(disruptionId),
                                    method: "DELETE",
                                    json: "",
                                    successParser: function () {
                                      return true
                                    },
                                    errorParser: jsonApi_1.parseErrors,
                                  }),
                                ]
                              case 1:
                                result = _a.sent()
                                if (result.ok) {
                                  setDoRedirect(true)
                                } else if (result.error) {
                                  setDeletionErrors(result.error)
                                }
                                return [2 /*return*/]
                            }
                          })
                        })
                      },
                      Component: React.createElement(
                        button_1.LinkButton,
                        { id: "delete-disruption-button" },
                        "delete"
                      ),
                    })
                  : null)
            ),
            disruptionRevision_1 &&
              React.createElement(adjustmentSummary_1.AdjustmentSummary, {
                adjustments: disruptionRevision_1.adjustments,
              }),
            React.createElement(
              "div",
              null,
              React.createElement(
                "div",
                { className: "mb-2" },
                React.createElement("strong", null, "select view")
              ),
              React.createElement(
                "div",
                {
                  className:
                    "m-disruption-details__view-toggle-group d-flex flex-column",
                },
                published &&
                  React.createElement(
                    react_router_dom_1.NavLink,
                    {
                      id: "published",
                      to: "?",
                      className: "m-disruption-details__view-toggle",
                      activeClassName: "active",
                      isActive: function () {
                        return view === disruption_1.DisruptionView.Published
                      },
                    },
                    React.createElement(
                      "strong",
                      { className: "mr-3" },
                      "published"
                    ),
                    React.createElement(
                      "span",
                      { className: "text-muted" },
                      "In GTFS",
                      " ",
                      disruptions_1.formatDisruptionDate(
                        disruption.lastPublishedAt || null
                      )
                    )
                  ),
                ready &&
                  React.createElement(
                    react_router_dom_1.NavLink,
                    {
                      id: "ready",
                      className: "m-disruption-details__view-toggle",
                      to: "?v=ready",
                      activeClassName: "active",
                      isActive: function () {
                        return view === disruption_1.DisruptionView.Ready
                      },
                      replace: true,
                    },
                    React.createElement(
                      "strong",
                      { className: "mr-3" },
                      "ready"
                    ),
                    React.createElement(
                      "span",
                      { className: "text-muted" },
                      "Created ",
                      disruptions_1.formatDisruptionDate(
                        ready.insertedAt || null
                      )
                    )
                  ),
                draft
                  ? React.createElement(
                      react_router_dom_1.NavLink,
                      {
                        id: "draft",
                        className:
                          "m-disruption-details__view-toggle text-primary",
                        to: "?v=draft",
                        activeClassName: "active",
                        isActive: function () {
                          return view === disruption_1.DisruptionView.Draft
                        },
                        replace: true,
                      },
                      React.createElement(
                        "strong",
                        { className: "mr-3" },
                        "needs review"
                      ),
                      React.createElement(
                        "span",
                        { className: "text-muted" },
                        "Created ",
                        disruptions_1.formatDisruptionDate(
                          draft.insertedAt || null
                        )
                      )
                    )
                  : !anyDeleted
                  ? React.createElement(
                      react_router_dom_1.Link,
                      {
                        className:
                          "m-disruption-details__view-toggle text-primary",
                        to: "/disruptions/" + disruption.id + "/edit",
                      },
                      React.createElement("strong", null, "create new draft")
                    )
                  : null
              )
            ),
            React.createElement("hr", { className: "my-3" }),
            disruptionRevision_1
              ? React.createElement(
                  "div",
                  null,
                  React.createElement(
                    Row_1.default,
                    null,
                    anyDeleted &&
                      React.createElement(
                        Col_1.default,
                        { xs: 12 },
                        React.createElement(
                          "div",
                          {
                            className:
                              "m-disruption-details__deletion-indicator",
                          },
                          React.createElement(
                            "span",
                            { className: "text-blue-grey mr-3" },
                            "\uE14E"
                          ),
                          React.createElement("strong", null, "Note"),
                          " This disruption is marked for deletion"
                        )
                      ),
                    React.createElement(
                      Col_1.default,
                      { md: 10 },
                      React.createElement(
                        "div",
                        { className: anyDeleted ? "text-muted" : "" },
                        React.createElement(
                          "div",
                          { className: "mb-3" },
                          React.createElement("h4", null, "date range"),
                          React.createElement(
                            "div",
                            { className: "pl-3" },
                            disruptions_1.formatDisruptionDate(
                              disruptionRevision_1.startDate || null
                            ),
                            " ",
                            "\u2013",
                            " ",
                            disruptions_1.formatDisruptionDate(
                              disruptionRevision_1.endDate || null
                            )
                          )
                        ),
                        React.createElement(
                          "div",
                          { className: "mb-3" },
                          React.createElement("h4", null, "time period"),
                          React.createElement(
                            "div",
                            { className: "pl-3" },
                            disruptionRevision_1.daysOfWeek.map(function (d) {
                              return React.createElement(
                                "div",
                                { key: d.id },
                                React.createElement(
                                  "div",
                                  null,
                                  React.createElement(
                                    "strong",
                                    null,
                                    d.dayName.charAt(0).toUpperCase() +
                                      d.dayName.slice(1)
                                  )
                                ),
                                React.createElement(
                                  "div",
                                  null,
                                  time_1.timePeriodDescription(
                                    d.startTime,
                                    d.endTime
                                  )
                                )
                              )
                            })
                          )
                        ),
                        disruptionRevision_1.tripShortNames.length > 0 &&
                          React.createElement(
                            "div",
                            { className: "mb-3" },
                            React.createElement("h4", null, "trips"),
                            React.createElement(
                              "div",
                              { className: "pl-3" },
                              disruptionRevision_1.tripShortNames
                                .map(function (x) {
                                  return x.tripShortName
                                })
                                .join(", ")
                            )
                          ),
                        exceptionDates.length > 0 &&
                          React.createElement(
                            "div",
                            { className: "mb-3" },
                            React.createElement("h4", null, "exceptions"),
                            React.createElement(
                              "div",
                              { className: "pl-3" },
                              exceptionDates.map(function (exc) {
                                return React.createElement(
                                  "div",
                                  { key: exc.toISOString() },
                                  disruptions_1.formatDisruptionDate(exc)
                                )
                              })
                            )
                          )
                      )
                    ),
                    React.createElement(
                      Col_1.default,
                      { md: 2 },
                      view === disruption_1.DisruptionView.Draft &&
                        disruptionRevision_1.isActive &&
                        React.createElement(
                          react_router_dom_1.Link,
                          { to: "/disruptions/" + disruption.id + "/edit" },
                          React.createElement(
                            button_1.PrimaryButton,
                            {
                              id: "edit-disruption-link",
                              className: "w-100",
                              filled: true,
                            },
                            "edit"
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
                      view === disruption_1.DisruptionView.Draft &&
                        React.createElement(
                          "div",
                          null,
                          React.createElement("hr", { className: "my-3" }),
                          React.createElement(
                            "div",
                            { className: "d-flex justify-content-center" },
                            React.createElement(
                              confirmationModal_1.ConfirmationModal,
                              {
                                onClickConfirm: function () {
                                  api_1
                                    .apiSend({
                                      method: "POST",
                                      json: JSON.stringify({
                                        revision_ids: disruptionRevision_1.id,
                                      }),
                                      url: "/api/ready_notice/",
                                    })
                                    .then(function () {
                                      return __awaiter(
                                        void 0,
                                        void 0,
                                        void 0,
                                        function () {
                                          return __generator(
                                            this,
                                            function (_a) {
                                              switch (_a.label) {
                                                case 0:
                                                  return [
                                                    4 /*yield*/,
                                                    fetchDisruption(),
                                                  ]
                                                case 1:
                                                  _a.sent()
                                                  history.replace(
                                                    "/disruptions/" +
                                                      encodeURIComponent(
                                                        disruptionRevision_1.disruptionId ||
                                                          ""
                                                      ) +
                                                      "?v=ready"
                                                  )
                                                  return [2 /*return*/]
                                              }
                                            }
                                          )
                                        }
                                      )
                                    })
                                    .catch(function () {
                                      // eslint-disable-next-line no-console
                                      console.log(
                                        "failed to mark revision as ready: " +
                                          disruptionRevision_1.id
                                      )
                                    })
                                },
                                confirmationButtonText: "yes, mark as ready",
                                confirmationText:
                                  "Are you sure you want to mark these revisions as ready?",
                                Component: React.createElement(
                                  button_1.SecondaryButton,
                                  { id: "mark-ready" },
                                  "mark as ready" +
                                    (disruptionRevision_1.isActive
                                      ? ""
                                      : " for deletion")
                                ),
                              }
                            )
                          )
                        )
                    )
                  )
                )
              : React.createElement(
                  "div",
                  null,
                  "Disruption ",
                  disruption.id,
                  " has no",
                  " ",
                  view === disruption_1.DisruptionView.Draft
                    ? "draft"
                    : view === disruption_1.DisruptionView.Ready
                    ? "ready"
                    : "published",
                  " ",
                  "revision"
                )
          )
        )
      )
    } else {
      return React.createElement(
        "div",
        null,
        "Error parsing day of week information."
      )
    }
  } else if (disruption === "error") {
    return React.createElement(
      "div",
      null,
      "Error fetching or parsing disruption."
    )
  } else {
    return React.createElement(loading_1.default, null)
  }
}
exports.default = ViewDisruption
