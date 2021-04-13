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
var __importDefault =
  (this && this.__importDefault) ||
  function (mod) {
    return mod && mod.__esModule ? mod : { default: mod }
  }
Object.defineProperty(exports, "__esModule", { value: true })
exports.DisruptionView = void 0
var jsonApiResourceObject_1 = __importDefault(
  require("../jsonApiResourceObject")
)
var jsonApi_1 = require("../jsonApi")
var DisruptionView
;(function (DisruptionView) {
  DisruptionView[(DisruptionView["Draft"] = 0)] = "Draft"
  DisruptionView[(DisruptionView["Ready"] = 1)] = "Ready"
  DisruptionView[(DisruptionView["Published"] = 2)] = "Published"
})(DisruptionView || (DisruptionView = {}))
exports.DisruptionView = DisruptionView
var Disruption = /** @class */ (function (_super) {
  __extends(Disruption, _super)
  function Disruption(_a) {
    var id = _a.id,
      lastPublishedAt = _a.lastPublishedAt,
      readyRevision = _a.readyRevision,
      publishedRevision = _a.publishedRevision,
      draftRevision = _a.draftRevision,
      revisions = _a.revisions
    var _this = _super.call(this) || this
    _this.id = id
    _this.lastPublishedAt = lastPublishedAt
    _this.readyRevision = readyRevision
    _this.publishedRevision = publishedRevision
    _this.draftRevision = draftRevision
    _this.revisions = revisions
    return _this
  }
  Disruption.prototype.toJsonApi = function () {
    return {
      data: this.toJsonApiData(),
    }
  }
  Disruption.prototype.toJsonApiData = function () {
    // Implement later if we actually need it
    return {
      type: "disruption",
      attributes: {},
    }
  }
  Disruption.fromJsonObject = function (raw, included) {
    if (
      typeof raw.attributes === "object" &&
      typeof raw.relationships === "object"
    ) {
      var revisions = jsonApi_1
        .loadRelationship(raw.relationships.revisions, included)
        .sort(function (r1, r2) {
          return parseInt(r1.id || "", 10) - parseInt(r2.id || "", 10)
        })
      var disruption = new Disruption({
        id: raw.id,
        lastPublishedAt:
          raw.attributes.last_published_at &&
          new Date(raw.attributes.last_published_at),
        readyRevision: jsonApi_1.loadSingleRelationship(
          raw.relationships.ready_revision,
          included
        ),
        publishedRevision: jsonApi_1.loadSingleRelationship(
          raw.relationships.published_revision,
          included
        ),
        draftRevision: revisions[revisions.length - 1],
        revisions: revisions,
      })
      if (disruption.draftRevision) {
        disruption.draftRevision.disruptionId = raw.id
        disruption.draftRevision.status = DisruptionView.Draft
      }
      if (disruption.readyRevision) {
        disruption.readyRevision.disruptionId = raw.id
        disruption.readyRevision.status = DisruptionView.Ready
      }
      if (disruption.publishedRevision) {
        disruption.publishedRevision.disruptionId = raw.id
        disruption.publishedRevision.status = DisruptionView.Published
      }
      disruption.revisions = disruption.revisions.map(function (dr) {
        dr.disruptionId = raw.id
        return dr
      })
      return disruption
    }
    return "error"
  }
  Disruption.prototype.getUniqueRevisions = function () {
    var _a, _b, _c
    return {
      published: this.publishedRevision || null,
      ready:
        this.readyRevision &&
        this.readyRevision.id !==
          ((_a = this.publishedRevision) === null || _a === void 0
            ? void 0
            : _a.id)
          ? this.readyRevision
          : null,
      draft:
        this.draftRevision &&
        this.draftRevision.id !==
          ((_b = this.readyRevision) === null || _b === void 0
            ? void 0
            : _b.id) &&
        this.draftRevision.id !==
          ((_c = this.publishedRevision) === null || _c === void 0
            ? void 0
            : _c.id)
          ? this.draftRevision
          : null,
    }
  }
  Disruption.isOfType = function (obj) {
    return obj instanceof Disruption
  }
  Disruption.uniqueRevisionFromDisruptionForView = function (disruption, view) {
    var _a = disruption.getUniqueRevisions(),
      published = _a.published,
      ready = _a.ready,
      draft = _a.draft
    switch (view) {
      case DisruptionView.Draft:
        return draft
      case DisruptionView.Ready:
        return ready
      default:
        return published
    }
  }
  Disruption.revisionFromDisruptionForView = function (disruption, view) {
    switch (view) {
      case DisruptionView.Draft: {
        var sortedRevisions = disruption.revisions.sort(function (r1, r2) {
          return parseInt(r1.id || "", 10) - parseInt(r2.id || "", 10)
        })
        return sortedRevisions[sortedRevisions.length - 1]
      }
      case DisruptionView.Ready: {
        return disruption.readyRevision
      }
      case DisruptionView.Published: {
        return disruption.publishedRevision
      }
    }
  }
  return Disruption
})(jsonApiResourceObject_1.default)
exports.default = Disruption
