import { mount } from "enzyme"
import * as React from "react"
import { DisruptionPreview } from "../../src/disruptions/disruptionPreview"

describe("DisruptionPreview", () => {
  test("includes formatted from and to dates", () => {
    const text = mount(
      <DisruptionPreview
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
      <DisruptionPreview
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
    let text = mount(
      <DisruptionPreview
        adjustments={[]}
        setIsPreview={() => null}
        fromDate={null}
        toDate={null}
        disruptionDaysOfWeek={[
          null,
          null,
          [null, null],
          null,
          null,
          null,
          null,
        ]}
        exceptionDates={[new Date(2020, 0, 10)]}
      />
    ).text()

    expect(text).toMatch("Wednesday")
    expect(text).toMatch("Start of service – End of service")

    text = mount(
      <DisruptionPreview
        adjustments={[]}
        setIsPreview={() => null}
        fromDate={null}
        toDate={null}
        disruptionDaysOfWeek={[
          null,
          null,
          null,
          [
            { hour: "12", minute: "30", period: "AM" },
            { hour: "9", minute: "30", period: "PM" },
          ],
          null,
          null,
          null,
        ]}
        exceptionDates={[new Date(2020, 0, 10)]}
      />
    ).text()

    expect(text).toMatch("Thursday")
    expect(text).toMatch("12:30AM – 9:30PM")
  })
})
