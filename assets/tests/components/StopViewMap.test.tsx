import React from "react"
import { render } from "@testing-library/react"
import StopViewMap from "../../src/components/stops/StopViewMap"
import { Stop, GtfsStop } from "../../src/components/stops/types"

describe("StopViewMap", () => {
  test("renders", () => {
    const stop = {
      stop_lat: 42.352035,
      stop_lon: 71.0551,
      stop_name: "pink pony club",
      stop_desc: "dancin",
    }
    const existingShuttle: Stop[] = [
      {
        stop_lat: 42.452035,
        stop_lon: 71.1522,
        stop_name: "house of the rising sun",
        stop_desc: "test",
      },
    ]
    const existingGtfs: GtfsStop[] = [
      {
        desc: "what up",
        name: "Grandma got run over by a reindeer",
        lat: 42.452035,
        lon: 71.1522,
      },
    ]
    const { container } = render(
      <StopViewMap
        stop={stop}
        existingBusStops={existingGtfs}
        existingShuttleStops={existingShuttle}
      />
    )
    expect(container.getElementsByClassName("leaflet-map-pane").length).toBe(1)
    expect(
      container.getElementsByClassName("leaflet-control-container").length
    ).toBe(1)
  })
})
