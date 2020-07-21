import React from "react"
import DisruptionCalendar from "../../src/disruptions/disruptionCalendar"
import { render } from "@testing-library/react"
import Disruption from "../../src/models/disruption"
import Adjustment from "../../src/models/adjustment"
import DayOfWeek from "../../src/models/dayOfWeek"

it("renders correctly", () => {
  const tree = render(
    <DisruptionCalendar
      disruptions={[
        new Disruption({
          id: "1",
          startDate: new Date("2019-10-31"),
          endDate: new Date("2019-11-15"),
          adjustments: [
            new Adjustment({
              routeId: "Red",
              sourceLabel: "AlewifeHarvard",
            }),
          ],
          daysOfWeek: [
            new DayOfWeek({
              id: "1",
              startTime: "20:45:00",
              dayName: "friday",
            }),
            new DayOfWeek({
              id: "2",
              dayName: "saturday",
            }),
            new DayOfWeek({
              id: "3",
              dayName: "sunday",
            }),
          ],
          exceptions: [],
          tripShortNames: [],
        }),
        new Disruption({
          id: "3",
          startDate: new Date("2019-09-22"),
          endDate: new Date("2019-10-22"),
          adjustments: [
            new Adjustment({
              routeId: "Green-D",
              sourceLabel: "Kenmore-Newton Highlands",
            }),
          ],
          daysOfWeek: [
            new DayOfWeek({
              id: "1",
              startTime: "20:45:00",
              dayName: "friday",
            }),
            new DayOfWeek({
              id: "2",
              dayName: "saturday",
            }),
            new DayOfWeek({
              id: "3",
              dayName: "sunday",
            }),
          ],
          exceptions: [],
          tripShortNames: [],
        }),
      ]}
    />
  )
  expect(tree).toMatchSnapshot()
})
