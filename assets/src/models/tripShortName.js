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
var TripShortName = /** @class */ (function (_super) {
  __extends(TripShortName, _super)
  function TripShortName(_a) {
    var id = _a.id,
      tripShortName = _a.tripShortName
    var _this = _super.call(this) || this
    _this.id = id
    _this.tripShortName = tripShortName
    return _this
  }
  TripShortName.prototype.toJsonApi = function () {
    return {
      data: this.toJsonApiData(),
    }
  }
  TripShortName.prototype.toJsonApiData = function () {
    return __assign(
      __assign(
        { type: "trip_short_name" },
        this.id && { id: this.id.toString() }
      ),
      {
        attributes: __assign(
          {},
          this.tripShortName && { trip_short_name: this.tripShortName }
        ),
      }
    )
  }
  TripShortName.fromJsonObject = function (raw) {
    if (typeof raw.attributes === "object") {
      return new TripShortName({
        id: raw.id,
        tripShortName: raw.attributes.trip_short_name,
      })
    }
    return "error"
  }
  TripShortName.isOfType = function (obj) {
    return obj instanceof TripShortName
  }
  return TripShortName
})(jsonApiResourceObject_1.default)
exports.default = TripShortName
