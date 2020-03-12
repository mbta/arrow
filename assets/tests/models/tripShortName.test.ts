import TripShortName from "../../src/models/tripShortName"

describe("TripShortName", () => {
  test("serialize", () => {
    const tsn = new TripShortName({
      id: 5,
      tripShortName: "1753",
    })

    expect(tsn.toJsonApi()).toEqual({
      data: {
        id: "5",
        type: "trip_short_name",
        attributes: {
          trip_short_name: "1753",
        },
      },
    })
  })

  test("fromJsonApi success", () => {
    expect(
      TripShortName.fromJsonApi({ data: { type: "trip_short_name" } })
    ).toEqual(new TripShortName({}))
  })

  test("fromJsonApi error wrong format", () => {
    expect(TripShortName.fromJsonApi({})).toEqual("error")
  })

  test("fromJsonApi error not an object", () => {
    expect(TripShortName.fromJsonApi(5)).toEqual("error")
  })
})
