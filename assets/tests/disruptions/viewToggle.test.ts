import {
  DisruptionView,
  revisionFromDisruptionForView,
} from "../../src/disruptions/viewToggle"

import Disruption from "../../src/models/disruption"
import DisruptionRevision from "../../src/models/disruptionRevision"

const testDisruption = new Disruption({
  id: "1",
  readyRevision: new DisruptionRevision({
    id: "2",
    startDate: new Date(2020, 0, 1),
    endDate: new Date(2020, 1, 1),
    isActive: true,
    adjustments: [],
    daysOfWeek: [],
    exceptions: [],
    tripShortNames: [],
  }),
  revisions: [
    new DisruptionRevision({
      id: "3",
      startDate: new Date(2020, 1, 1),
      endDate: new Date(2020, 2, 1),
      isActive: true,
      adjustments: [],
      daysOfWeek: [],
      exceptions: [],
      tripShortNames: [],
    }),
    new DisruptionRevision({
      id: "2",
      startDate: new Date(2020, 0, 1),
      endDate: new Date(2020, 1, 1),
      isActive: true,
      adjustments: [],
      daysOfWeek: [],
      exceptions: [],
      tripShortNames: [],
    }),
  ],
})

describe("revisionFromDisruptionForView", () => {
  test("gets draft revision", () => {
    expect(
      revisionFromDisruptionForView(testDisruption, DisruptionView.Draft)
    ).toEqual(
      new DisruptionRevision({
        id: "3",
        startDate: new Date(2020, 1, 1),
        endDate: new Date(2020, 2, 1),
        isActive: true,
        adjustments: [],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      })
    )
  })

  test("returnes undefined for latest draft when no revisions present", () => {
    expect(
      revisionFromDisruptionForView(
        new Disruption({ id: "1", revisions: [] }),
        DisruptionView.Draft
      )
    ).toBeUndefined()
  })

  test("gets ready revision", () => {
    expect(
      revisionFromDisruptionForView(testDisruption, DisruptionView.Ready)
    ).toEqual(
      new DisruptionRevision({
        id: "2",
        startDate: new Date(2020, 0, 1),
        endDate: new Date(2020, 1, 1),
        isActive: true,
        adjustments: [],
        daysOfWeek: [],
        exceptions: [],
        tripShortNames: [],
      })
    )
  })
})
