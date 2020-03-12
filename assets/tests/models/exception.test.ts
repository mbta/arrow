import Exception from "../../src/models/exception"

describe("Exception", () => {
  test("toJsonApi", () => {
    const ex = new Exception({
      id: 5,
      excludedDate: new Date(2020, 1, 1),
    })

    expect(ex.toJsonApi()).toEqual({
      data: {
        id: "5",
        type: "exception",
        attributes: {
          excluded_date: "2020-02-01",
        },
      },
    })
  })

  test("fromJsonApi success", () => {
    expect(Exception.fromJsonApi({ data: { type: "exception" } })).toEqual(
      new Exception({})
    )
  })

  test("fromJsonApi error wrong format", () => {
    expect(Exception.fromJsonApi({})).toEqual("error")
  })

  test("fromJsonApi error not an object", () => {
    expect(Exception.fromJsonApi(5)).toEqual("error")
  })
})
