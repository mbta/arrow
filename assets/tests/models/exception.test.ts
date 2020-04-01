import Exception from "../../src/models/exception"

describe("Exception", () => {
  test("toJsonApi", () => {
    const ex = new Exception({
      id: "5",
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

  test("fromJsonObject success", () => {
    expect(
      Exception.fromJsonObject({
        id: "1",
        type: "exception",
        attributes: { excluded_date: "2020-03-30" },
      })
    ).toEqual(new Exception({ id: "1", excludedDate: new Date("2020-03-30") }))
  })

  test("fromJsonObject error wrong format", () => {
    expect(Exception.fromJsonObject({})).toEqual("error")
  })

  test("fromJsonObject error not an object", () => {
    expect(Exception.fromJsonObject(5)).toEqual("error")
  })
})
