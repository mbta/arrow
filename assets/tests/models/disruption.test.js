"use strict"
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
var disruption_1 = __importStar(require("../../src/models/disruption"))
var disruptionRevision_1 = __importDefault(
  require("../../src/models/disruptionRevision")
)
var adjustment_1 = __importDefault(require("../../src/models/adjustment"))
var dayOfWeek_1 = __importDefault(require("../../src/models/dayOfWeek"))
var exception_1 = __importDefault(require("../../src/models/exception"))
var tripShortName_1 = __importDefault(require("../../src/models/tripShortName"))
describe("Disruption", function () {
  test("toJsonApi", function () {
    var disruption = new disruption_1.default({
      id: "5",
      revisions: [
        new disruptionRevision_1.default({
          id: "5",
          startDate: new Date(2020, 0, 1),
          endDate: new Date(2020, 2, 1),
          isActive: true,
          adjustments: [
            new adjustment_1.default({
              id: "1",
              routeId: "Red",
              sourceLabel: "HarvardAlewife",
            }),
          ],
          daysOfWeek: [new dayOfWeek_1.default({ id: "2", dayName: "friday" })],
          exceptions: [
            new exception_1.default({
              id: "3",
              excludedDate: new Date(2020, 0, 2),
            }),
          ],
          tripShortNames: [new tripShortName_1.default({ id: "4" })],
        }),
      ],
    })
    expect(disruption.toJsonApi()).toEqual({
      data: {
        type: "disruption",
        attributes: {},
      },
    })
  })
  test("fromJsonObject success", function () {
    expect(
      disruption_1.default.fromJsonObject(
        {
          attributes: {
            last_published_at: "2020-09-30:12:00:00Z",
          },
          id: "1",
          type: "disruption",
          relationships: {
            published_revision: {
              data: { id: "1", type: "disruption_revision" },
            },
            ready_revision: {
              data: { id: "1", type: "disruption_revision" },
            },
            revisions: {
              data: [
                { id: "2", type: "disruption_revision" },
                { id: "1", type: "disruption_revision" },
              ],
            },
          },
        },
        {
          "adjustment-15": new adjustment_1.default({
            id: "15",
            routeId: "Green-D",
            sourceLabel: "KenmoreReservoir",
          }),
          "day_of_week-1": new dayOfWeek_1.default({
            id: "1",
            startTime: "20:45:00",
            dayName: "friday",
          }),
          "day_of_week-2": new dayOfWeek_1.default({
            id: "2",
            dayName: "saturday",
          }),
          "day_of_week-3": new dayOfWeek_1.default({
            id: "3",
            dayName: "sunday",
          }),
          "disruption_revision-1": new disruptionRevision_1.default({
            id: "1",
            startDate: new Date(2019, 11, 20),
            endDate: new Date(2020, 0, 12),
            isActive: true,
            adjustments: [
              new adjustment_1.default({
                id: "15",
                routeId: "Green-D",
                sourceLabel: "KenmoreReservoir",
              }),
            ],
            daysOfWeek: [
              new dayOfWeek_1.default({
                id: "1",
                startTime: "20:45:00",
                dayName: "friday",
              }),
              new dayOfWeek_1.default({
                id: "2",
                dayName: "saturday",
              }),
              new dayOfWeek_1.default({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [
              new exception_1.default({
                id: "1",
                excludedDate: new Date(2019, 11, 29),
              }),
            ],
            tripShortNames: [],
          }),
          "disruption_revision-2": new disruptionRevision_1.default({
            id: "2",
            startDate: new Date(2019, 11, 20),
            endDate: new Date(2020, 0, 12),
            isActive: true,
            adjustments: [
              new adjustment_1.default({
                id: "15",
                routeId: "Green-D",
                sourceLabel: "KenmoreReservoir",
              }),
            ],
            daysOfWeek: [
              new dayOfWeek_1.default({
                id: "1",
                startTime: "19:45:00",
                dayName: "friday",
              }),
              new dayOfWeek_1.default({
                id: "2",
                dayName: "saturday",
              }),
              new dayOfWeek_1.default({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [
              new exception_1.default({
                id: "1",
                excludedDate: new Date(2019, 11, 29),
              }),
            ],
            tripShortNames: [],
          }),
          "exception-1": new exception_1.default({
            id: "1",
            excludedDate: new Date(2019, 11, 29),
          }),
        }
      )
    ).toEqual(
      new disruption_1.default({
        id: "1",
        lastPublishedAt: new Date("2020-09-30T12:00:00Z"),
        draftRevision: new disruptionRevision_1.default({
          id: "2",
          disruptionId: "1",
          startDate: new Date(2019, 11, 20),
          endDate: new Date(2020, 0, 12),
          isActive: true,
          adjustments: [
            new adjustment_1.default({
              id: "15",
              routeId: "Green-D",
              sourceLabel: "KenmoreReservoir",
            }),
          ],
          daysOfWeek: [
            new dayOfWeek_1.default({
              id: "1",
              startTime: "19:45:00",
              dayName: "friday",
            }),
            new dayOfWeek_1.default({
              id: "2",
              dayName: "saturday",
            }),
            new dayOfWeek_1.default({
              id: "3",
              dayName: "sunday",
            }),
          ],
          exceptions: [
            new exception_1.default({
              id: "1",
              excludedDate: new Date(2019, 11, 29),
            }),
          ],
          tripShortNames: [],
          status: 0,
        }),
        readyRevision: new disruptionRevision_1.default({
          id: "1",
          disruptionId: "1",
          startDate: new Date(2019, 11, 20),
          endDate: new Date(2020, 0, 12),
          isActive: true,
          adjustments: [
            new adjustment_1.default({
              id: "15",
              routeId: "Green-D",
              sourceLabel: "KenmoreReservoir",
            }),
          ],
          daysOfWeek: [
            new dayOfWeek_1.default({
              id: "1",
              startTime: "20:45:00",
              dayName: "friday",
            }),
            new dayOfWeek_1.default({
              id: "2",
              dayName: "saturday",
            }),
            new dayOfWeek_1.default({
              id: "3",
              dayName: "sunday",
            }),
          ],
          exceptions: [
            new exception_1.default({
              id: "1",
              excludedDate: new Date(2019, 11, 29),
            }),
          ],
          tripShortNames: [],
          status: 2,
        }),
        publishedRevision: new disruptionRevision_1.default({
          id: "1",
          disruptionId: "1",
          startDate: new Date(2019, 11, 20),
          endDate: new Date(2020, 0, 12),
          isActive: true,
          adjustments: [
            new adjustment_1.default({
              id: "15",
              routeId: "Green-D",
              sourceLabel: "KenmoreReservoir",
            }),
          ],
          daysOfWeek: [
            new dayOfWeek_1.default({
              id: "1",
              startTime: "20:45:00",
              dayName: "friday",
            }),
            new dayOfWeek_1.default({
              id: "2",
              dayName: "saturday",
            }),
            new dayOfWeek_1.default({
              id: "3",
              dayName: "sunday",
            }),
          ],
          exceptions: [
            new exception_1.default({
              id: "1",
              excludedDate: new Date(2019, 11, 29),
            }),
          ],
          tripShortNames: [],
          status: 2,
        }),
        revisions: [
          new disruptionRevision_1.default({
            id: "1",
            disruptionId: "1",
            startDate: new Date(2019, 11, 20),
            endDate: new Date(2020, 0, 12),
            isActive: true,
            adjustments: [
              new adjustment_1.default({
                id: "15",
                routeId: "Green-D",
                sourceLabel: "KenmoreReservoir",
              }),
            ],
            daysOfWeek: [
              new dayOfWeek_1.default({
                id: "1",
                startTime: "20:45:00",
                dayName: "friday",
              }),
              new dayOfWeek_1.default({
                id: "2",
                dayName: "saturday",
              }),
              new dayOfWeek_1.default({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [
              new exception_1.default({
                id: "1",
                excludedDate: new Date(2019, 11, 29),
              }),
            ],
            tripShortNames: [],
            status: 2,
          }),
          new disruptionRevision_1.default({
            id: "2",
            disruptionId: "1",
            startDate: new Date(2019, 11, 20),
            endDate: new Date(2020, 0, 12),
            isActive: true,
            adjustments: [
              new adjustment_1.default({
                id: "15",
                routeId: "Green-D",
                sourceLabel: "KenmoreReservoir",
              }),
            ],
            daysOfWeek: [
              new dayOfWeek_1.default({
                id: "1",
                startTime: "19:45:00",
                dayName: "friday",
              }),
              new dayOfWeek_1.default({
                id: "2",
                dayName: "saturday",
              }),
              new dayOfWeek_1.default({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [
              new exception_1.default({
                id: "1",
                excludedDate: new Date(2019, 11, 29),
              }),
            ],
            tripShortNames: [],
            status: 0,
          }),
        ],
      })
    )
  })
  test("fromJsonObject error wrong format", function () {
    expect(disruption_1.default.fromJsonObject({}, {})).toEqual("error")
  })
  test("fromJsonObject error not an object", function () {
    expect(disruption_1.default.fromJsonObject(5, {})).toEqual("error")
  })
  test("isOfType", function () {
    expect(
      disruption_1.default.isOfType(
        new disruption_1.default({
          revisions: [],
        })
      )
    ).toBe(true)
    expect(
      disruption_1.default.isOfType(
        new exception_1.default({ excludedDate: new Date() })
      )
    ).toBe(false)
  })
})
describe("revisionFromDisruptionForView", function () {
  var testDisruption = new disruption_1.default({
    id: "1",
    publishedRevision: new disruptionRevision_1.default({
      id: "1",
      startDate: new Date(2020, 0, 1),
      endDate: new Date(2020, 1, 2),
      isActive: true,
      adjustments: [],
      daysOfWeek: [],
      exceptions: [],
      tripShortNames: [],
    }),
    readyRevision: new disruptionRevision_1.default({
      id: "2",
      startDate: new Date(2020, 0, 1),
      endDate: new Date(2020, 1, 1),
      isActive: true,
      adjustments: [],
      daysOfWeek: [],
      exceptions: [],
      tripShortNames: [],
    }),
    revisions: [
      new disruptionRevision_1.default({
        id: "3",
        startDate: new Date(2020, 1, 1),
        endDate: new Date(2020, 2, 1),
        isActive: true,
        adjustments: [],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      }),
      new disruptionRevision_1.default({
        id: "2",
        startDate: new Date(2020, 0, 1),
        endDate: new Date(2020, 1, 1),
        isActive: true,
        adjustments: [],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      }),
    ],
  })
  test("gets draft revision", function () {
    expect(
      disruption_1.default.revisionFromDisruptionForView(
        testDisruption,
        disruption_1.DisruptionView.Draft
      )
    ).toEqual(
      new disruptionRevision_1.default({
        id: "3",
        startDate: new Date(2020, 1, 1),
        endDate: new Date(2020, 2, 1),
        isActive: true,
        adjustments: [],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      })
    )
  })
  test("returnes undefined for latest draft when no revisions present", function () {
    expect(
      disruption_1.default.revisionFromDisruptionForView(
        new disruption_1.default({ id: "1", revisions: [] }),
        disruption_1.DisruptionView.Draft
      )
    ).toBeUndefined()
  })
  test("gets ready revision", function () {
    expect(
      disruption_1.default.revisionFromDisruptionForView(
        testDisruption,
        disruption_1.DisruptionView.Ready
      )
    ).toEqual(
      new disruptionRevision_1.default({
        id: "2",
        startDate: new Date(2020, 0, 1),
        endDate: new Date(2020, 1, 1),
        isActive: true,
        adjustments: [],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      })
    )
  })
  test("gets published revision", function () {
    expect(
      disruption_1.default.revisionFromDisruptionForView(
        testDisruption,
        disruption_1.DisruptionView.Published
      )
    ).toEqual(
      new disruptionRevision_1.default({
        id: "1",
        startDate: new Date(2020, 0, 1),
        endDate: new Date(2020, 1, 2),
        isActive: true,
        adjustments: [],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      })
    )
  })
})
describe("getUniqueRevisions", function () {
  var revision = new disruptionRevision_1.default({
    id: "1",
    isActive: true,
    adjustments: [],
    exceptions: [],
    daysOfWeek: [],
    tripShortNames: [],
  })
  var disruption = new disruption_1.default({
    draftRevision: revision,
    readyRevision: revision,
    publishedRevision: revision,
    revisions: [revision],
  })
  test.each([
    [disruption, "published", "1"],
    [disruption, "ready", null],
    [disruption, "draft", null],
    [
      new disruption_1.default(
        __assign(__assign({}, disruption), {
          publishedRevision: new disruptionRevision_1.default(
            __assign(__assign({}, revision), { id: "2" })
          ),
        })
      ),
      "ready",
      "1",
    ],
    [
      new disruption_1.default(
        __assign(__assign({}, disruption), {
          readyRevision: new disruptionRevision_1.default(
            __assign(__assign({}, revision), { id: "2" })
          ),
        })
      ),
      "draft",
      null,
    ],
    [
      new disruption_1.default(
        __assign(__assign({}, disruption), {
          publishedRevision: new disruptionRevision_1.default(
            __assign(__assign({}, revision), { id: "2" })
          ),
        })
      ),
      "draft",
      null,
    ],
    [
      new disruption_1.default(
        __assign(__assign({}, disruption), {
          publishedRevision: new disruptionRevision_1.default(
            __assign(__assign({}, revision), { id: "2" })
          ),
          readyRevision: new disruptionRevision_1.default(
            __assign(__assign({}, revision), { id: "2" })
          ),
        })
      ),
      "draft",
      "1",
    ],
  ])("returns unique revisions", function (dis, view, expectedId) {
    var rev = dis.getUniqueRevisions()[view]
    expect(rev && rev.id).toEqual(expectedId)
  })
})
