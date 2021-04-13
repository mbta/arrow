"use strict"
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
exports.loadSingleRelationship = exports.loadRelationship = exports.toUTCDate = exports.parseErrors = exports.toModelObject = void 0
var adjustment_1 = __importDefault(require("./models/adjustment"))
var dayOfWeek_1 = __importDefault(require("./models/dayOfWeek"))
var disruption_1 = __importDefault(require("./models/disruption"))
var disruptionRevision_1 = __importDefault(
  require("./models/disruptionRevision")
)
var exception_1 = __importDefault(require("./models/exception"))
var tripShortName_1 = __importDefault(require("./models/tripShortName"))
var toUTCDate = function (dateStr) {
  var _a = dateStr.split("-"),
    year = _a[0],
    month = _a[1],
    date = _a[2]
  return new Date(
    Date.UTC(parseInt(year, 10), parseInt(month, 10) - 1, parseInt(date, 10))
  )
}
exports.toUTCDate = toUTCDate
var toModelObject = function (response) {
  var includedObjects = {}
  if (
    Array.isArray(
      response === null || response === void 0 ? void 0 : response.included
    )
  ) {
    for (var _i = 0, _a = response.included; _i < _a.length; _i++) {
      var obj = _a[_i]
      // On this first pass, we use {} for the included objects
      var model = modelFromJsonApiResource(obj, {})
      if (model === "error") {
        return "error"
      } else {
        includedObjects[obj.type + "-" + obj.id] = model
      }
    }
    for (var _b = 0, _c = response.included; _b < _c.length; _b++) {
      var obj = _c[_b]
      // On this second pass we can now load the nested included objects
      var model = modelFromJsonApiResource(obj, includedObjects)
      includedObjects[obj.type + "-" + obj.id] = model
    }
  } else if (
    typeof (response === null || response === void 0
      ? void 0
      : response.included) !== "undefined"
  ) {
    return "error"
  }
  if (Array.isArray(response.data)) {
    var modelObjects = []
    for (var _d = 0, _e = response.data; _d < _e.length; _d++) {
      var data = _e[_d]
      var model = modelFromJsonApiResource(data, includedObjects)
      if (model === "error") {
        return "error"
      } else {
        modelObjects.push(model)
      }
    }
    return modelObjects
  } else {
    return modelFromJsonApiResource(response.data, includedObjects)
  }
}
exports.toModelObject = toModelObject
var parseErrors = function (raw) {
  var errors = []
  if (typeof raw === "object") {
    var rawErrors = raw === null || raw === void 0 ? void 0 : raw.errors
    if (Array.isArray(rawErrors)) {
      rawErrors.forEach(function (err) {
        var rawDetail = err === null || err === void 0 ? void 0 : err.detail
        if (typeof rawDetail === "string") {
          errors.push(rawDetail)
        }
      })
    }
  }
  return errors
}
exports.parseErrors = parseErrors
var modelFromJsonApiResource = function (raw, includedObjects) {
  if (typeof raw === "object") {
    switch (raw.type) {
      case "adjustment":
        return adjustment_1.default.fromJsonObject(raw)
      case "day_of_week":
        return dayOfWeek_1.default.fromJsonObject(raw)
      case "disruption":
        return disruption_1.default.fromJsonObject(raw, includedObjects)
      case "disruption_revision":
        return disruptionRevision_1.default.fromJsonObject(raw, includedObjects)
      case "exception":
        return exception_1.default.fromJsonObject(raw)
      case "trip_short_name":
        return tripShortName_1.default.fromJsonObject(raw)
      default:
        return "error"
    }
  }
  return "error"
}
var loadRelationship = function (relationship, included) {
  if (typeof relationship === "object") {
    if (Array.isArray(relationship.data)) {
      return relationship.data
        .map(function (r) {
          return included[r.type + "-" + r.id]
        })
        .filter(function (o) {
          return typeof o !== "undefined"
        })
    } else if (relationship.data && typeof relationship.data === "object") {
      var key = relationship.data
      return [included[key.type + "-" + key.id]]
    }
  }
  return []
}
exports.loadRelationship = loadRelationship
var loadSingleRelationship = function (relationship, included) {
  var loaded = loadRelationship(relationship, included)
  return loaded[0]
}
exports.loadSingleRelationship = loadSingleRelationship
