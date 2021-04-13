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
var Adjustment = /** @class */ (function (_super) {
  __extends(Adjustment, _super)
  function Adjustment(_a) {
    var id = _a.id,
      routeId = _a.routeId,
      source = _a.source,
      sourceLabel = _a.sourceLabel
    var _this = _super.call(this) || this
    _this.id = id
    _this.routeId = routeId
    _this.source = source
    _this.sourceLabel = sourceLabel
    return _this
  }
  Adjustment.prototype.toJsonApi = function () {
    return {
      data: this.toJsonApiData(),
    }
  }
  Adjustment.prototype.toJsonApiData = function () {
    return __assign(
      __assign({ type: "adjustment" }, this.id && { id: this.id.toString() }),
      {
        attributes: __assign(
          __assign(
            __assign({}, this.routeId && { route_id: this.routeId }),
            this.source && { source: this.source }
          ),
          this.sourceLabel && { source_label: this.sourceLabel }
        ),
      }
    )
  }
  Adjustment.fromJsonObject = function (raw) {
    if (typeof raw.attributes === "object") {
      var source = void 0
      switch (raw.attributes.source) {
        case "arrow":
          source = "arrow"
          break
        case "gtfs_creator":
          source = "gtfs_creator"
          break
        default:
          return "error"
      }
      return new Adjustment({
        id: raw.id,
        routeId: raw.attributes.route_id,
        source: source,
        sourceLabel: raw.attributes.source_label,
      })
    }
    return "error"
  }
  Adjustment.isOfType = function (obj) {
    return obj instanceof Adjustment
  }
  return Adjustment
})(jsonApiResourceObject_1.default)
exports.default = Adjustment
