import React from "react"
import { fireEvent, render } from "@testing-library/react"
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
        stop_id: "1234",
        stop_lat: 42.352036,
        stop_lon: 71.0552,
        stop_name: "house of the rising sun",
        stop_desc: "test",
      },
    ]
    const existingGtfs: GtfsStop[] = [
      {
        id: "5678",
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

    // turn on existing stops and shuttle stops
    container
      .querySelectorAll("input.leaflet-control-layers-selector")
      .forEach((e) => fireEvent.click(e))

    // show stop that is less than 1 mile away from the selected stop
    expect(container.querySelectorAll("#arrow-stop-1234").length > 1)

    // don't show stop that is more than 1 mile away from the selected stop
    expect(container.querySelectorAll("#gtfs-stop-5678").length === 0).toBe(
      true
    )
  })
})
