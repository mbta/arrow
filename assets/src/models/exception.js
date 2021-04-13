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
var Exception = /** @class */ (function (_super) {
  __extends(Exception, _super)
  function Exception(_a) {
    var id = _a.id,
      excludedDate = _a.excludedDate
    var _this = _super.call(this) || this
    _this.id = id
    _this.excludedDate = excludedDate
    return _this
  }
  Exception.prototype.toJsonApi = function () {
    return {
      data: this.toJsonApiData(),
    }
  }
  Exception.prototype.toJsonApiData = function () {
    return __assign(
      __assign({ type: "exception" }, this.id && { id: this.id.toString() }),
      {
        attributes: __assign(
          {},
          this.excludedDate && {
            excluded_date: this.excludedDate.toISOString().slice(0, 10),
          }
        ),
      }
    )
  }
  Exception.fromJsonObject = function (raw) {
    if (typeof raw.attributes === "object") {
      return new Exception(
        __assign(
          { id: raw.id },
          raw.attributes.excluded_date && {
            excludedDate: jsonApi_1.toUTCDate(raw.attributes.excluded_date),
          }
        )
      )
    }
    return "error"
  }
  Exception.fromDates = function (exceptions) {
    return exceptions.map(function (exceptionDate) {
      return new Exception({ excludedDate: exceptionDate })
    })
  }
  Exception.isOfType = function (obj) {
    return obj instanceof Exception
  }
  return Exception
})(jsonApiResourceObject_1.default)
exports.default = Exception
