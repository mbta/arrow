import Disruption, { DisruptionView } from "../../src/models/disruption"
import DisruptionRevision from "../../src/models/disruptionRevision"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"
import Exception from "../../src/models/exception"
import TripShortName from "../../src/models/tripShortName"

describe("Disruption", () => {
  test("toJsonApi", () => {
    const disruption = new Disruption({
      id: "5",
      revisions: [
        new DisruptionRevision({
          id: "5",
          startDate: new Date(2020, 0, 1),
          endDate: new Date(2020, 2, 1),
          isActive: true,
          adjustments: [
            new Adjustment({
              id: "1",
              routeId: "Red",
              sourceLabel: "HarvardAlewife",
            }),
          ],
          daysOfWeek: [new DayOfWeek({ id: "2", dayName: "friday" })],
          exceptions: [
            new Exception({ id: "3", excludedDate: new Date(2020, 0, 2) }),
          ],
          tripShortNames: [new TripShortName({ id: "4" })],
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

  test("fromJsonObject success", () => {
    expect(
      Disruption.fromJsonObject(
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
          "adjustment-15": new Adjustment({
            id: "15",
            routeId: "Green-D",
            sourceLabel: "KenmoreReservoir",
          }),
          "day_of_week-1": new DayOfWeek({
            id: "1",
            startTime: "20:45:00",
            dayName: "friday",
          }),
          "day_of_week-2": new DayOfWeek({
            id: "2",
            dayName: "saturday",
          }),
          "day_of_week-3": new DayOfWeek({
            id: "3",
            dayName: "sunday",
          }),
          "disruption_revision-1": new DisruptionRevision({
            id: "1",
            startDate: new Date(2019, 11, 20),
            endDate: new Date(2020, 0, 12),
            isActive: true,
            adjustments: [
              new Adjustment({
                id: "15",
                routeId: "Green-D",
                sourceLabel: "KenmoreReservoir",
              }),
            ],
            daysOfWeek: [
              new DayOfWeek({
                id: "1",
                startTime: "20:45:00",
                dayName: "friday",
              }),
              new DayOfWeek({
                id: "2",
                dayName: "saturday",
              }),
              new DayOfWeek({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [
              new Exception({
                id: "1",
                excludedDate: new Date(2019, 11, 29),
              }),
            ],
            tripShortNames: [],
          }),
          "disruption_revision-2": new DisruptionRevision({
            id: "2",
            startDate: new Date(2019, 11, 20),
            endDate: new Date(2020, 0, 12),
            isActive: true,
            adjustments: [
              new Adjustment({
                id: "15",
                routeId: "Green-D",
                sourceLabel: "KenmoreReservoir",
              }),
            ],
            daysOfWeek: [
              new DayOfWeek({
                id: "1",
                startTime: "19:45:00",
                dayName: "friday",
              }),
              new DayOfWeek({
                id: "2",
                dayName: "saturday",
              }),
              new DayOfWeek({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [
              new Exception({
                id: "1",
                excludedDate: new Date(2019, 11, 29),
              }),
            ],
            tripShortNames: [],
          }),
          "exception-1": new Exception({
            id: "1",
            excludedDate: new Date(2019, 11, 29),
          }),
        }
      )
    ).toEqual(
      new Disruption({
        id: "1",
        lastPublishedAt: new Date("2020-09-30T12:00:00Z"),
        draftRevision: new DisruptionRevision({
          id: "2",
          disruptionId: "1",
          startDate: new Date(2019, 11, 20),
          endDate: new Date(2020, 0, 12),
          isActive: true,
          adjustments: [
            new Adjustment({
              id: "15",
              routeId: "Green-D",
              sourceLabel: "KenmoreReservoir",
            }),
          ],
          daysOfWeek: [
            new DayOfWeek({
              id: "1",
              startTime: "19:45:00",
              dayName: "friday",
            }),
            new DayOfWeek({
              id: "2",
              dayName: "saturday",
            }),
            new DayOfWeek({
              id: "3",
              dayName: "sunday",
            }),
          ],
          exceptions: [
            new Exception({
              id: "1",
              excludedDate: new Date(2019, 11, 29),
            }),
          ],
          tripShortNames: [],
          status: 0,
        }),
        readyRevision: new DisruptionRevision({
          id: "1",
          disruptionId: "1",
          startDate: new Date(2019, 11, 20),
          endDate: new Date(2020, 0, 12),
          isActive: true,
          adjustments: [
            new Adjustment({
              id: "15",
              routeId: "Green-D",
              sourceLabel: "KenmoreReservoir",
            }),
          ],
          daysOfWeek: [
            new DayOfWeek({
              id: "1",
              startTime: "20:45:00",
              dayName: "friday",
            }),
            new DayOfWeek({
              id: "2",
              dayName: "saturday",
            }),
            new DayOfWeek({
              id: "3",
              dayName: "sunday",
            }),
          ],
          exceptions: [
            new Exception({
              id: "1",
              excludedDate: new Date(2019, 11, 29),
            }),
          ],
          tripShortNames: [],
          status: 2,
        }),
        publishedRevision: new DisruptionRevision({
          id: "1",
          disruptionId: "1",
          startDate: new Date(2019, 11, 20),
          endDate: new Date(2020, 0, 12),
          isActive: true,
          adjustments: [
            new Adjustment({
              id: "15",
              routeId: "Green-D",
              sourceLabel: "KenmoreReservoir",
            }),
          ],
          daysOfWeek: [
            new DayOfWeek({
              id: "1",
              startTime: "20:45:00",
              dayName: "friday",
            }),
            new DayOfWeek({
              id: "2",
              dayName: "saturday",
            }),
            new DayOfWeek({
              id: "3",
              dayName: "sunday",
            }),
          ],
          exceptions: [
            new Exception({
              id: "1",
              excludedDate: new Date(2019, 11, 29),
            }),
          ],
          tripShortNames: [],
          status: 2,
        }),
        revisions: [
          new DisruptionRevision({
            id: "1",
            disruptionId: "1",
            startDate: new Date(2019, 11, 20),
            endDate: new Date(2020, 0, 12),
            isActive: true,
            adjustments: [
              new Adjustment({
                id: "15",
                routeId: "Green-D",
                sourceLabel: "KenmoreReservoir",
              }),
            ],
            daysOfWeek: [
              new DayOfWeek({
                id: "1",
                startTime: "20:45:00",
                dayName: "friday",
              }),
              new DayOfWeek({
                id: "2",
                dayName: "saturday",
              }),
              new DayOfWeek({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [
              new Exception({
                id: "1",
                excludedDate: new Date(2019, 11, 29),
              }),
            ],
            tripShortNames: [],
            status: 2,
          }),
          new DisruptionRevision({
            id: "2",
            disruptionId: "1",
            startDate: new Date(2019, 11, 20),
            endDate: new Date(2020, 0, 12),
            isActive: true,
            adjustments: [
              new Adjustment({
                id: "15",
                routeId: "Green-D",
                sourceLabel: "KenmoreReservoir",
              }),
            ],
            daysOfWeek: [
              new DayOfWeek({
                id: "1",
                startTime: "19:45:00",
                dayName: "friday",
              }),
              new DayOfWeek({
                id: "2",
                dayName: "saturday",
              }),
              new DayOfWeek({
                id: "3",
                dayName: "sunday",
              }),
            ],
            exceptions: [
              new Exception({
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

  test("fromJsonObject error wrong format", () => {
    expect(Disruption.fromJsonObject({}, {})).toEqual("error")
  })

  test("fromJsonObject error not an object", () => {
    expect(Disruption.fromJsonObject(5, {})).toEqual("error")
  })

  test("isOfType", () => {
    expect(
      Disruption.isOfType(
        new Disruption({
          revisions: [],
        })
      )
    ).toBe(true)

    expect(
      Disruption.isOfType(new Exception({ excludedDate: new Date() }))
    ).toBe(false)
  })
})

describe("revisionFromDisruptionForView", () => {
  const testDisruption = new Disruption({
    id: "1",
    publishedRevision: new DisruptionRevision({
      id: "1",
      startDate: new Date(2020, 0, 1),
      endDate: new Date(2020, 1, 2),
      isActive: true,
      adjustments: [],
      daysOfWeek: [],
      exceptions: [],
      tripShortNames: [],
    }),
    readyRevision: new DisruptionRevision({
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
      new DisruptionRevision({
        id: "3",
        startDate: new Date(2020, 1, 1),
        endDate: new Date(2020, 2, 1),
        isActive: true,
        adjustments: [],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      }),
      new DisruptionRevision({
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
  test("gets draft revision", () => {
    expect(
      Disruption.revisionFromDisruptionForView(
        testDisruption,
        DisruptionView.Draft
      )
    ).toEqual(
      new DisruptionRevision({
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

  test("returnes undefined for latest draft when no revisions present", () => {
    expect(
      Disruption.revisionFromDisruptionForView(
        new Disruption({ id: "1", revisions: [] }),
        DisruptionView.Draft
      )
    ).toBeUndefined()
  })

  test("gets ready revision", () => {
    expect(
      Disruption.revisionFromDisruptionForView(
        testDisruption,
        DisruptionView.Ready
      )
    ).toEqual(
      new DisruptionRevision({
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

  test("gets published revision", () => {
    expect(
      Disruption.revisionFromDisruptionForView(
        testDisruption,
        DisruptionView.Published
      )
    ).toEqual(
      new DisruptionRevision({
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

describe("getUniqueRevisions", () => {
  const revision = new DisruptionRevision({
    id: "1",
    isActive: true,
    adjustments: [],
    exceptions: [],
    daysOfWeek: [],
    tripShortNames: [],
  })
  const disruption = new Disruption({
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
      new Disruption({
        ...disruption,
        publishedRevision: new DisruptionRevision({ ...revision, id: "2" }),
      }),
      "ready",
      "1",
    ],
    [
      new Disruption({
        ...disruption,
        readyRevision: new DisruptionRevision({ ...revision, id: "2" }),
      }),
      "draft",
      null,
    ],
    [
      new Disruption({
        ...disruption,
        publishedRevision: new DisruptionRevision({ ...revision, id: "2" }),
      }),
      "draft",
      null,
    ],
    [
      new Disruption({
        ...disruption,
        publishedRevision: new DisruptionRevision({ ...revision, id: "2" }),
        readyRevision: new DisruptionRevision({ ...revision, id: "2" }),
      }),
      "draft",
      "1",
    ],
  ])(
    "returns unique revisions",
    (dis: Disruption, view: string, expectedId: string | null) => {
      const rev = dis.getUniqueRevisions()[
        view as "published" | "ready" | "draft"
      ]
      expect(rev && rev.id).toEqual(expectedId)
    }
  )
})
