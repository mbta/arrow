import { toModelObject, parseErrors } from "../src/jsonApi"
import Adjustment from "../src/models/adjustment"
import DayOfWeek from "../src/models/dayOfWeek"
import Disruption from "../src/models/disruption"
import DisruptionRevision from "../src/models/disruptionRevision"
import Exception from "../src/models/exception"
import TripShortName from "../src/models/tripShortName"

describe("toModelObject", () => {
  test("succeeds with valid adjustment input", () => {
    expect(
      toModelObject({
        data: {
          attributes: {
            route_id: "Green-D",
            source: "gtfs_creator",
            source_label: "KenmoreReservoir",
          },
          id: "1",
          relationships: {
            adjustments: {
              data: [],
            },
            days_of_week: { data: [] },
            exceptions: { data: [] },
            trip_short_names: { data: [] },
          },
          type: "adjustment",
        },
        included: [],
        jsonapi: { version: "1.0" },
      })
    ).toEqual(
      new Adjustment({
        id: "1",
        routeId: "Green-D",
        source: "gtfs_creator",
        sourceLabel: "KenmoreReservoir",
      })
    )
  })

  test("succeeds with valid day_of_week input", () => {
    expect(
      toModelObject({
        data: {
          attributes: {
            start_time: "20:45:00",
            end_time: null,
            day_name: "friday",
          },
          id: "1",
          relationships: {
            adjustments: {
              data: [],
            },
            days_of_week: { data: [] },
            exceptions: { data: [] },
            trip_short_names: { data: [] },
          },
          type: "day_of_week",
        },
        included: [],
        jsonapi: { version: "1.0" },
      })
    ).toEqual(
      new DayOfWeek({
        id: "1",
        startTime: "20:45:00",
        dayName: "friday",
      })
    )
  })

  test("succeeds with valid disruption input", () => {
    expect(
      toModelObject({
        data: {
          attributes: {},
          id: "1",
          relationships: {
            revisions: {
              data: [],
            },
            ready_revision: { data: null },
            published_revision: { data: null },
          },
          type: "disruption",
        },
        included: [],
        jsonapi: { version: "1.0" },
      })
    ).toEqual(
      new Disruption({
        id: "1",
        revisions: [],
      })
    )
  })

  test("succeeds with valid disruption_revision input", () => {
    expect(
      toModelObject({
        data: {
          attributes: {
            end_date: "2020-01-12",
            start_date: "2019-12-20",
            is_active: true,
          },
          id: "1",
          relationships: {
            adjustments: {
              data: [{ id: "12", type: "adjustment" }],
            },
            days_of_week: { data: [] },
            exceptions: { data: [] },
            trip_short_names: { data: [] },
          },
          type: "disruption_revision",
        },
        included: [
          {
            attributes: {
              route_id: "Green-D",
              source: "gtfs_creator",
              source_label: "KenmoreReservoir",
            },
            id: "12",
            type: "adjustment",
          },
        ],
        jsonapi: { version: "1.0" },
      })
    ).toEqual(
      new DisruptionRevision({
        id: "1",
        startDate: new Date("2019-12-20T00:00:00Z"),
        endDate: new Date("2020-01-12T00:00:00Z"),
        isActive: true,
        adjustments: [
          new Adjustment({
            id: "12",
            routeId: "Green-D",
            source: "gtfs_creator",
            sourceLabel: "KenmoreReservoir",
          }),
        ],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      })
    )
  })

  test("succeeds with valid exception input", () => {
    expect(
      toModelObject({
        data: {
          attributes: {
            excluded_date: "2019-12-20",
          },
          id: "1",
          relationships: {
            adjustments: { data: [] },
            days_of_week: { data: [] },
            exceptions: { data: [] },
            trip_short_names: { data: [] },
          },
          type: "exception",
        },
        included: [],
        jsonapi: { version: "1.0" },
      })
    ).toEqual(
      new Exception({
        id: "1",
        excludedDate: new Date("2019-12-20T00:00:00Z"),
      })
    )
  })

  test("succeeds with valid exception input", () => {
    expect(
      toModelObject({
        data: {
          attributes: {
            trip_short_name: "1234",
          },
          id: "1",
          relationships: {
            adjustments: { data: [] },
            days_of_week: { data: [] },
            exceptions: { data: [] },
            trip_short_names: { data: [] },
          },
          type: "trip_short_name",
        },
        included: [],
        jsonapi: { version: "1.0" },
      })
    ).toEqual(
      new TripShortName({
        id: "1",
        tripShortName: "1234",
      })
    )
  })

  test("succeeds with valid input containing multiple objects", () => {
    expect(
      toModelObject({
        data: [
          {
            attributes: {
              route_id: "Green-D",
              source: "gtfs_creator",
              source_label: "KenmoreReservoir",
            },
            id: "1",
            relationships: {
              adjustments: {
                data: [],
              },
              days_of_week: { data: [] },
              exceptions: { data: [] },
              trip_short_names: { data: [] },
            },
            type: "adjustment",
          },
          {
            attributes: {
              route_id: "Red",
              source: "gtfs_creator",
              source_label: "HarvardAlewife",
            },
            id: "2",
            relationships: {
              adjustments: {
                data: [],
              },
              days_of_week: { data: [] },
              exceptions: { data: [] },
              trip_short_names: { data: [] },
            },
            type: "adjustment",
          },
        ],
        included: [],
        jsonapi: { version: "1.0" },
      })
    ).toEqual([
      new Adjustment({
        id: "1",
        routeId: "Green-D",
        source: "gtfs_creator",
        sourceLabel: "KenmoreReservoir",
      }),
      new Adjustment({
        id: "2",
        routeId: "Red",
        source: "gtfs_creator",
        sourceLabel: "HarvardAlewife",
      }),
    ])
  })

  test("properly assigns multiple levels of included objects", () => {
    const expectedRevisions = [
      new DisruptionRevision({
        id: "1",
        disruptionId: "99",
        startDate: new Date("2019-12-20T00:00:00Z"),
        endDate: new Date("2020-01-12T00:00:00Z"),
        isActive: true,
        adjustments: [
          new Adjustment({
            id: "12",
            routeId: "Green-D",
            source: "gtfs_creator",
            sourceLabel: "KenmoreReservoir",
          }),
        ],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      }),
      new DisruptionRevision({
        id: "2",
        disruptionId: "99",
        startDate: new Date("2019-12-25T00:00:00Z"),
        endDate: new Date("2020-01-15T00:00:00Z"),
        isActive: true,
        adjustments: [
          new Adjustment({
            id: "13",
            routeId: "Green-D",
            source: "gtfs_creator",
            sourceLabel: "Kenmore-Newton",
          }),
        ],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      }),
    ]

    expect(
      toModelObject({
        data: [
          {
            attributes: { last_published_at: "2020-02-01T00:00:00Z" },
            id: "99",
            relationships: {
              revisions: {
                data: [
                  { id: "1", type: "disruption_revision" },
                  { id: "2", type: "disruption_revision" },
                ],
              },
            },
            type: "disruption",
          },
        ],
        included: [
          {
            attributes: {
              end_date: "2020-01-12",
              start_date: "2019-12-20",
              is_active: true,
            },
            id: "1",
            relationships: {
              adjustments: {
                data: [{ id: "12", type: "adjustment" }],
              },
              days_of_week: { data: [] },
              exceptions: { data: [] },
              trip_short_names: { data: [] },
            },
            type: "disruption_revision",
          },
          {
            attributes: {
              end_date: "2020-01-15",
              start_date: "2019-12-25",
              is_active: true,
            },
            id: "2",
            relationships: {
              adjustments: {
                data: [{ id: "13", type: "adjustment" }],
              },
              days_of_week: { data: [] },
              exceptions: { data: [] },
              trip_short_names: { data: [] },
            },
            type: "disruption_revision",
          },
          {
            attributes: {
              route_id: "Green-D",
              source: "gtfs_creator",
              source_label: "KenmoreReservoir",
            },
            id: "12",
            type: "adjustment",
          },
          {
            attributes: {
              route_id: "Green-D",
              source: "gtfs_creator",
              source_label: "Kenmore-Newton",
            },
            id: "13",
            type: "adjustment",
          },
        ],
        jsonapi: { version: "1.0" },
      })
    ).toEqual([
      new Disruption({
        id: "99",
        lastPublishedAt: new Date("2020-02-01T00:00:00Z"),
        revisions: expectedRevisions,
        draftRevision: expectedRevisions[1],
      }),
    ])
  })

  test("returns error when one of multiple objects fails to parse", () => {
    expect(
      toModelObject({
        data: [
          {
            attributes: {
              route_id: "Green-D",
              source: "gtfs_creator",
              source_label: "KenmoreReservoir",
            },
            id: "1",
            relationships: {
              adjustments: {
                data: [],
              },
              days_of_week: { data: [] },
              exceptions: { data: [] },
              trip_short_names: { data: [] },
            },
            type: "adjustment",
          },
          {
            attributes: {
              route_id: "Red",
              source: "gtfs_creator",
              source_label: "HarvardAlewife",
            },
            id: "2",
            relationships: {
              adjustments: {
                data: [],
              },
              days_of_week: { data: [] },
              exceptions: { data: [] },
              trip_short_names: { data: [] },
            },
            type: "not_a_valid_type",
          },
        ],
        included: [],
        jsonapi: { version: "1.0" },
      })
    ).toEqual("error")
  })

  test("return error when included isn't an array", () => {
    expect(
      toModelObject({
        data: {
          attributes: {
            route_id: "Green-D",
            source: "gtfs_creator",
            source_label: "KenmoreReservoir",
          },
          id: "1",
          relationships: {
            adjustments: {
              data: [],
            },
            days_of_week: { data: [] },
            exceptions: { data: [] },
            trip_short_names: { data: [] },
          },
          type: "adjustment",
        },
        included: "not_an_array",
        jsonapi: { version: "1.0" },
      })
    ).toEqual("error")
  })

  test("returns error when an included object fails to parse", () => {
    expect(
      toModelObject({
        data: {
          attributes: {
            end_date: "2020-01-12",
            start_date: "2019-12-20",
          },
          id: "1",
          relationships: {
            adjustments: {
              data: [{ id: "12", type: "adjustment" }],
            },
            days_of_week: { data: [] },
            exceptions: { data: [] },
            trip_short_names: { data: [] },
          },
          type: "disruption",
        },
        included: [
          {
            attributes: {
              route_id: "Green-D",
              source: "not_a_valid_source",
              source_label: "KenmoreReservoir",
            },
            id: "12",
            type: "adjustment",
          },
        ],
        jsonapi: { version: "1.0" },
      })
    ).toEqual("error")
  })

  test("returns error when an included object has unknown type", () => {
    expect(
      toModelObject({
        data: {
          attributes: {
            end_date: "2020-01-12",
            start_date: "2019-12-20",
          },
          id: "1",
          relationships: {
            adjustments: {
              data: [{ id: "12", type: "adjustment" }],
            },
            days_of_week: { data: [] },
            exceptions: { data: [] },
            trip_short_names: { data: [] },
          },
          type: "disruption",
        },
        included: [
          {
            attributes: {
              route_id: "Green-D",
              source: "gtfs_creator",
              source_label: "KenmoreReservoir",
            },
            id: "12",
            type: "not_a_valid_type",
          },
        ],
        jsonapi: { version: "1.0" },
      })
    ).toEqual("error")
  })

  test("returns error when an included value isn't an object", () => {
    expect(
      toModelObject({
        data: {
          attributes: {
            end_date: "2020-01-12",
            start_date: "2019-12-20",
          },
          id: "1",
          relationships: {
            adjustments: {
              data: [{ id: "12", type: "adjustment" }],
            },
            days_of_week: { data: [] },
            exceptions: { data: [] },
            trip_short_names: { data: [] },
          },
          type: "disruption",
        },
        included: ["not_an_object"],
        jsonapi: { version: "1.0" },
      })
    ).toEqual("error")
  })
})

describe("parseErrors", () => {
  test("Parses JSON:API formatted errors into list of errors", () => {
    const data = { errors: [{ detail: "error1" }, { detail: "error2" }] }
    expect(parseErrors(data)).toEqual(["error1", "error2"])
  })

  test("handles oddly shaped data without crashing", () => {
    expect(parseErrors("foo")).toEqual([])
    expect(parseErrors({})).toEqual([])
    expect(parseErrors({ errors: "foo" })).toEqual([])
    expect(parseErrors({ errors: [{ foo: "bar" }] })).toEqual([])
  })
})
