import { mount } from "enzyme"
import * as React from "react"
import { NewDisruptionPreview } from "../../src/disruptions/newDisruptionPreview"

describe("NewDisruptionPreview", () => {
  test("includes formatted from and to dates", () => {
    const text = mount(
      <NewDisruptionPreview
        adjustments={[]}
        setIsPreview={() => null}
        fromDate={new Date(2020, 0, 1)}
        toDate={new Date(2020, 0, 15)}
        disruptionDaysOfWeek={[null, null, null, null, null, null, null]}
        exceptionDates={[]}
      />
    ).text()

    expect(text).toMatch("1/1/2020")
    expect(text).toMatch("1/15/2020")
  })

  test("includes formatted exception dates", () => {
    const text = mount(
      <NewDisruptionPreview
        adjustments={[]}
        setIsPreview={() => null}
        fromDate={null}
        toDate={null}
        disruptionDaysOfWeek={[null, null, null, null, null, null, null]}
        exceptionDates={[new Date(2020, 0, 10)]}
      />
    ).text()

    expect(text).toMatch("1/10/2020")
  })

  test("Days of week are included and translated", () => {
    const text = mount(
      <NewDisruptionPreview
        adjustments={[]}
        setIsPreview={() => null}
        fromDate={null}
        toDate={null}
        disruptionDaysOfWeek={[
          null,
          null,
          ["Beginning of Service", "End of Service"],
          null,
          null,
          null,
          null,
        ]}
        exceptionDates={[new Date(2020, 0, 10)]}
      />
    ).text()

    expect(text).toMatch("Wednesday")
    expect(text).toMatch("Beginning of Service – End of Service")
  })
})
