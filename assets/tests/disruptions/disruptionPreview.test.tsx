import { render, fireEvent, screen } from "@testing-library/react"
import * as React from "react"
import { DisruptionPreview } from "../../src/disruptions/disruptionPreview"

describe("DisruptionPreview", () => {
  test("includes formatted from and to dates", () => {
    render(
      <DisruptionPreview
        adjustments={[]}
        setIsPreview={() => null}
        fromDate={new Date(2020, 0, 1)}
        toDate={new Date(2020, 0, 15)}
        disruptionDaysOfWeek={[null, null, null, null, null, null, null]}
        exceptionDates={[]}
        tripShortNames=""
      />
    )

    expect(screen.queryByText("1/1/2020 – 1/15/2020")).not.toBeNull()
  })

  test("includes formatted exception dates", () => {
    render(
      <DisruptionPreview
        adjustments={[]}
        setIsPreview={() => null}
        fromDate={null}
        toDate={null}
        disruptionDaysOfWeek={[null, null, null, null, null, null, null]}
        exceptionDates={[new Date(2020, 0, 10)]}
        tripShortNames=""
      />
    )

    expect(screen.queryByText("1/10/2020")).not.toBeNull()
  })

  test("Days of week are included and translated", () => {
    render(
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
        tripShortNames=""
      />
    )

    expect(screen.queryByText("Wednesday")).not.toBeNull()
    expect(
      screen.queryByText("Start of service – End of service")
    ).not.toBeNull()

    render(
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
        tripShortNames=""
      />
    )

    expect(screen.queryByText("Thursday")).not.toBeNull()
    expect(screen.queryByText("12:30AM – 9:30PM")).not.toBeNull()
  })

  test("includes back to edit link when setIsPreview is provided", () => {
    const { container } = render(
      <DisruptionPreview
        adjustments={[]}
        setIsPreview={() => null}
        fromDate={null}
        toDate={null}
        disruptionDaysOfWeek={[null, null, null, null, null, null, null]}
        exceptionDates={[]}
        tripShortNames=""
      />
    )

    expect(container.querySelector("#back-to-edit-link")).not.toBeNull()
  })

  test("doesn't include back to edit link when setIsPreview is omitted", () => {
    const { container } = render(
      <DisruptionPreview
        adjustments={[]}
        fromDate={null}
        toDate={null}
        disruptionDaysOfWeek={[null, null, null, null, null, null, null]}
        exceptionDates={[]}
        tripShortNames=""
      />
    )

    expect(container.querySelector("#back-to-edit-link")).toBeNull()
  })

  test("shows trip short names", () => {
    render(
      <DisruptionPreview
        adjustments={[]}
        fromDate={null}
        toDate={null}
        disruptionDaysOfWeek={[null, null, null, null, null, null, null]}
        exceptionDates={[]}
        tripShortNames="123,456,789"
      />
    )

    expect(screen.queryByText("Trips: 123,456,789")).not.toBeNull()
  })

  test("create callback is invoked", () => {
    const requests = []
    const createFn = (args: any) => {
      requests.push(args)
    }
    const { container } = render(
      <DisruptionPreview
        adjustments={[]}
        fromDate={null}
        toDate={null}
        disruptionDaysOfWeek={[null, null, null, null, null, null, null]}
        exceptionDates={[]}
        createFn={createFn}
        tripShortNames=""
      />
    )
    const createButton = container.querySelector(
      "button#disruption-preview-create"
    )
    if (!createButton) {
      throw new Error("create button not found")
    }

    fireEvent.click(createButton)

    expect(requests.length).toEqual(1)
  })
})
