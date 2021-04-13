"use strict"
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
Object.defineProperty(exports, "__esModule", { value: true })
exports.apiSend = exports.apiGet = void 0
var redirectIfUnauthorized = function (status) {
  if (Math.floor(status / 100) === 3 || status === 403) {
    // If the API sends us a redirect or forbidden, the user needs to
    // re-authenticate. Reload to go through the auth flow again.
    window.location.reload(true)
  }
}
var checkResponseStatus = function (response) {
  if (response.status === 200) {
    return response
  }
  redirectIfUnauthorized(response.status)
  throw new Error("Response error: " + response.status)
}
var apiSend = function (_a) {
  var url = _a.url,
    method = _a.method,
    json = _a.json,
    _b = _a.successParser,
    successParser =
      _b === void 0
        ? function (x) {
            return x
          }
        : _b,
    _c = _a.errorParser,
    errorParser =
      _c === void 0
        ? function (x) {
            return x
          }
        : _c
  return __awaiter(void 0, void 0, void 0, function () {
    var response, responseData
    return __generator(this, function (_d) {
      switch (_d.label) {
        case 0:
          return [
            4 /*yield*/,
            fetch(url, {
              method: method,
              credentials: "include",
              headers: { "Content-Type": "application/vnd.api+json" },
              body: json,
            }),
          ]
        case 1:
          response = _d.sent()
          redirectIfUnauthorized(response.status)
          if (response.status === 204) {
            return [2 /*return*/, { ok: successParser(null) }]
          }
          return [4 /*yield*/, response.json()]
        case 2:
          responseData = _d.sent()
          if (response.status === 200 || response.status === 201) {
            return [2 /*return*/, { ok: successParser(responseData) }]
          } else if (Math.floor(response.status / 100) === 4) {
            return [2 /*return*/, { error: errorParser(responseData) }]
          }
          return [2 /*return*/, Promise.reject("fetch/parse error")]
      }
    })
  })
}
exports.apiSend = apiSend
var apiGet = function (_a) {
  var url = _a.url,
    parser = _a.parser,
    defaultResult = _a.defaultResult
  return window
    .fetch(url)
    .then(checkResponseStatus)
    .then(function (response) {
      return response.json()
    })
    .then(function (json) {
      return parser(json)
    })
    .catch(function (error) {
      if (typeof defaultResult === "undefined") {
        throw error
      } else {
        return defaultResult
      }
    })
}
exports.apiGet = apiGet
