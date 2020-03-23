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

  test("fromJsonApi success", () => {
    expect(Adjustment.fromJsonApi({ data: { type: "adjustment" } })).toEqual(
      new Adjustment({})
    )
  })

  test("fromJsonApi error wrong format", () => {
    expect(Adjustment.fromJsonApi({})).toEqual("error")
  })

  test("fromJsonApi error not an object", () => {
    expect(Adjustment.fromJsonApi(5)).toEqual("error")
  })
})
