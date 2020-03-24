import TripShortName from "../../src/models/tripShortName"

describe("TripShortName", () => {
  test("serialize", () => {
    const tsn = new TripShortName({
      id: "5",
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

  test("fromJsonObject success", () => {
    expect(
      TripShortName.fromJsonObject(
        { type: "trip_short_name", attributes: {} },
        []
      )
    ).toEqual(new TripShortName({}))
  })

  test("fromJsonObject error wrong format", () => {
    expect(TripShortName.fromJsonObject({}, [])).toEqual("error")
  })

  test("fromJsonObject error not an object", () => {
    expect(TripShortName.fromJsonObject(5, [])).toEqual("error")
  })
})
