import Adjustment from "../../src/models/adjustment"

describe("Adjustment", () => {
  test("serialize", () => {
    const adj = new Adjustment({
      id: 5,
      routeId: "Red",
      source: "gtfs_creator",
      sourceLabel: "AlewifeHarvard",
    })

    expect(adj.serialize()).toEqual({
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
})
