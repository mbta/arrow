import TripShortName from "../../src/models/tripShortName"

describe("TripShortName", () => {
  test("serialize", () => {
    const tsn = new TripShortName({
      id: 5,
      tripShortName: "1753",
    })

    expect(tsn.serialize()).toEqual({
      data: {
        id: "5",
        type: "trip_short_name",
        attributes: {
          trip_short_name: "1753",
        },
      },
    })
  })
})
