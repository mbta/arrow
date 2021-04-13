"use strict"
var __extends =
  (this && this.__extends) ||
  (function () {
    var extendStatics = function (d, b) {
      extendStatics =
        Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array &&
          function (d, b) {
            d.__proto__ = b
          }) ||
        function (d, b) {
          for (var p in b)
            if (Object.prototype.hasOwnProperty.call(b, p)) d[p] = b[p]
        }
      return extendStatics(d, b)
    }
    return function (d, b) {
      if (typeof b !== "function" && b !== null)
        throw new TypeError(
          "Class extends value " + String(b) + " is not a constructor or null"
        )
      extendStatics(d, b)
      function __() {
        this.constructor = d
      }
      d.prototype =
        b === null ? Object.create(b) : ((__.prototype = b.prototype), new __())
    }
  })()
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
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
var jsonApiResourceObject_1 = __importDefault(
  require("../jsonApiResourceObject")
)
var jsonApi_1 = require("../jsonApi")
var disruption_1 = require("./disruption")
var disruptionCalendar_1 = require("../disruptions/disruptionCalendar")
var DisruptionRevision = /** @class */ (function (_super) {
  __extends(DisruptionRevision, _super)
  function DisruptionRevision(_a) {
    var id = _a.id,
      disruptionId = _a.disruptionId,
      startDate = _a.startDate,
      endDate = _a.endDate,
      isActive = _a.isActive,
      insertedAt = _a.insertedAt,
      adjustments = _a.adjustments,
      daysOfWeek = _a.daysOfWeek,
      exceptions = _a.exceptions,
      tripShortNames = _a.tripShortNames,
      _b = _a.status,
      status = _b === void 0 ? disruption_1.DisruptionView.Draft : _b
    var _this = _super.call(this) || this
    _this.id = id
    _this.disruptionId = disruptionId
    _this.startDate = startDate
    _this.endDate = endDate
    _this.isActive = isActive
    _this.insertedAt = insertedAt
    _this.adjustments = adjustments
    _this.daysOfWeek = daysOfWeek
    _this.exceptions = exceptions
    _this.status = status
    _this.tripShortNames = tripShortNames
    return _this
  }
  DisruptionRevision.prototype.toJsonApi = function () {
    return {
      data: this.toJsonApiData(),
    }
  }
  DisruptionRevision.prototype.toJsonApiData = function () {
    return __assign(
      __assign(
        { type: "disruption_revision" },
        this.id && { id: this.id.toString() }
      ),
      {
        attributes: __assign(
          __assign(
            __assign(
              {},
              this.startDate && {
                start_date: this.startDate.toISOString().slice(0, 10),
              }
            ),
            this.endDate && {
              end_date: this.endDate.toISOString().slice(0, 10),
            }
          ),
          { is_active: this.isActive }
        ),
        relationships: {
          adjustments: {
            data: this.adjustments.map(function (adj) {
              return adj.toJsonApiData()
            }),
          },
          days_of_week: {
            data: this.daysOfWeek.map(function (dow) {
              return dow.toJsonApiData()
            }),
          },
          exceptions: {
            data: this.exceptions.map(function (ex) {
              return ex.toJsonApiData()
            }),
          },
          trip_short_names: {
            data: this.tripShortNames.map(function (tsn) {
              return tsn.toJsonApiData()
            }),
          },
        },
      }
    )
  }
  DisruptionRevision.fromJsonObject = function (raw, included) {
    if (
      typeof raw.attributes === "object" &&
      typeof raw.relationships === "object"
    ) {
      return new DisruptionRevision(
        __assign(
          __assign(
            __assign(
              { id: raw.id },
              raw.attributes.start_date && {
                startDate: jsonApi_1.toUTCDate(raw.attributes.start_date),
              }
            ),
            raw.attributes.end_date && {
              endDate: jsonApi_1.toUTCDate(raw.attributes.end_date),
            }
          ),
          {
            isActive: raw.attributes.is_active,
            insertedAt:
              raw.attributes.inserted_at &&
              new Date(raw.attributes.inserted_at),
            adjustments: jsonApi_1
              .loadRelationship(raw.relationships.adjustments, included)
              .sort(function (a, b) {
                return parseInt(a.id, 10) - parseInt(b.id, 10)
              }),
            daysOfWeek: jsonApi_1
              .loadRelationship(raw.relationships.days_of_week, included)
              .sort(function (a, b) {
                return (
                  disruptionCalendar_1.dayNameToInt(a.dayName) -
                  disruptionCalendar_1.dayNameToInt(b.dayName)
                )
              }),
            exceptions: jsonApi_1
              .loadRelationship(raw.relationships.exceptions, included)
              .sort(function (a, b) {
                return a.excludedDate.getTime() - b.excludedDate.getTime()
              }),
            tripShortNames: jsonApi_1.loadRelationship(
              raw.relationships.trip_short_names,
              included
            ),
            status: raw.attributes.status,
          }
        )
      )
    }
    return "error"
  }
  DisruptionRevision.isOfType = function (obj) {
    return obj instanceof DisruptionRevision
  }
  return DisruptionRevision
})(jsonApiResourceObject_1.default)
exports.default = DisruptionRevision
