import Adjustment from "../../src/models/adjustment"

describe("Adjustment", () => {
  test("toJsonApi", () => {
    const adj = new Adjustment({
      id: "5",
      routeId: "Red",
      source: "gtfs_creator",
      sourceLabel: "AlewifeHarvard",
    })

    expect(adj.toJsonApi()).toEqual({
      data: {
        id: "5",
        type: "adjustment",
        attributes: {
          route_id: "Red",
          source_label: "AlewifeHarvard",
          source: "gtfs_creator",
        },
      },
    })
  })

  test("fromJsonObject success", () => {
    expect(
      Adjustment.fromJsonObject({
        type: "adjustment",
        id: "1",
        attributes: {
          source: "gtfs_creator",
          route_id: "Red",
          source_label: "AlewifeHarvard",
        },
      })
    ).toEqual(
      new Adjustment({
        id: "1",
        routeId: "Red",
        source: "gtfs_creator",
        sourceLabel: "AlewifeHarvard",
      })
    )

    expect(
      Adjustment.fromJsonObject({
        type: "adjustment",
        id: "1",
        attributes: {
          source: "arrow",
          route_id: "Red",
          source_label: "AlewifeHarvard",
        },
      })
    ).toEqual(
      new Adjustment({
        id: "1",
        routeId: "Red",
        source: "arrow",
        sourceLabel: "AlewifeHarvard",
      })
    )
  })

  test("fromJsonObject error wrong format", () => {
    expect(Adjustment.fromJsonObject({})).toEqual("error")
  })

  test("fromJsonObject error not an object", () => {
    expect(Adjustment.fromJsonObject(5)).toEqual("error")
  })
})
