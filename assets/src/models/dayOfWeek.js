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
var DayOfWeek = /** @class */ (function (_super) {
  __extends(DayOfWeek, _super)
  function DayOfWeek(_a) {
    var id = _a.id,
      startTime = _a.startTime,
      endTime = _a.endTime,
      dayName = _a.dayName
    var _this = _super.call(this) || this
    _this.id = id
    _this.startTime = startTime
    _this.endTime = endTime
    _this.dayName = dayName
    return _this
  }
  DayOfWeek.prototype.toJsonApi = function () {
    return {
      data: this.toJsonApiData(),
    }
  }
  DayOfWeek.prototype.toJsonApiData = function () {
    return __assign(
      __assign({ type: "day_of_week" }, this.id && { id: this.id.toString() }),
      {
        attributes: __assign(
          __assign(
            __assign({}, this.startTime && { start_time: this.startTime }),
            this.endTime && { end_time: this.endTime }
          ),
          this.dayName && { day_name: this.dayName }
        ),
      }
    )
  }
  DayOfWeek.fromJsonObject = function (raw) {
    if (
      typeof raw.attributes === "object" &&
      [
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday",
        "sunday",
      ].includes(raw.attributes.day_name)
    ) {
      return new DayOfWeek(
        __assign(
          __assign(
            __assign(
              { id: raw.id },
              raw.attributes.start_time && {
                startTime: raw.attributes.start_time,
              }
            ),
            raw.attributes.end_time && { endTime: raw.attributes.end_time }
          ),
          { dayName: raw.attributes.day_name }
        )
      )
    } else {
      return "error"
    }
  }
  DayOfWeek.isOfType = function (obj) {
    return obj instanceof DayOfWeek
  }
  return DayOfWeek
})(jsonApiResourceObject_1.default)
exports.default = DayOfWeek
