import Exception from "../../src/models/exception"

describe("Exception", () => {
  test("serialize", () => {
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
})
