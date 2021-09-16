import React from "react"
import DisruptionCalendar from "../../src/components/DisruptionCalendar"
import { render } from "@testing-library/react"

describe("DisruptionCalendar", () => {
  test("renders correctly", () => {
    const { container } = render(
      <DisruptionCalendar
        initialDate="2019-11-15"
        events={[
          {
            title: "AlewifeHarvard",
            className: "route-Red",
            start: "2019-11-02",
            end: "2019-11-04",
            url: "/disruptions/1",
          },
          {
            title: "AlewifeHarvard",
            className: "route-Red",
            start: "2019-11-08",
            end: "2019-11-11",
            url: "/disruptions/1",
          },
          {
            title: "AlewifeHarvard",
            className: "route-Red",
            start: "2019-11-15",
            end: "2019-11-15",
            url: "/disruptions/1",
          },
          {
            title: "Kenmore-Newton Highlands",
            className: "route-Green-D",
            start: "2019-11-15",
            end: "2019-11-18",
            url: "/disruptions/3",
          },
          {
            title: "Kenmore-Newton Highlands",
            className: "route-Green-D",
            start: "2019-11-22",
            end: "2019-11-25",
            url: "/disruptions/3",
          },
          {
            title: "Kenmore-Newton Highlands",
            className: "route-Green-D",
            start: "2019-11-29",
            end: "2019-12-01",
            url: "/disruptions/3",
          },
        ]}
      />
    )

    expect(container).toMatchSnapshot()
  })
})
