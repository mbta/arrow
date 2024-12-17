import { GtfsStop, Stop } from "./types"

import React from "react"
import { LayerGroup, LayersControl, Marker, Popup } from "react-leaflet"
import { generateLegend, genIcon } from "../util/maps"

const newStopColor = "f24727"
const existingShuttleStopColor = "414bb2"
const existingBusStopColor = "fac711"

const shuttleLayerName = generateLegend(
  existingShuttleStopColor,
  "Existing Shuttle Stops"
)
const busLayerName = generateLegend(existingBusStopColor, "Existing Bus Stops")
const selectedStopLayerName = generateLegend(newStopColor, "Selected Stop")

const haversineDistance = (
  pos: [number, number],
  otherPos: [number, number]
) => {
  // radius in miles
  const earthRadius = 3963.1

  const deltaLatitude = ((otherPos[0] - pos[0]) * Math.PI) / 180
  const deltaLongitude = ((otherPos[1] - pos[1]) * Math.PI) / 180

  // https://en.wikipedia.org/wiki/Haversine_formula
  const arc =
    Math.cos((pos[0] * Math.PI) / 180) *
      Math.cos((otherPos[0] * Math.PI) / 180) *
      Math.sin(deltaLongitude / 2) *
      Math.sin(deltaLongitude / 2) +
    Math.sin(deltaLatitude / 2) * Math.sin(deltaLatitude / 2)
  const line = 2 * Math.atan2(Math.sqrt(arc), Math.sqrt(1 - arc))

  return earthRadius * line
}

const MAX_RADIUS_FOR_STOPS_MILES = 1

const StopLayerControl = ({
  selectedStop,
  existingShuttleStops,
  existingBusStops,
}: {
  selectedStop: Stop
  existingShuttleStops: Stop[] | undefined
  existingBusStops: GtfsStop[] | undefined
}) => {
  return (
    <LayersControl
      position="bottomright"
      key="layer-control-stops"
      collapsed={false}
    >
      {existingShuttleStops && (
        <LayersControl.Overlay name={shuttleLayerName}>
          <LayerGroup>
            {existingShuttleStops
              .filter(
                (shuttleStop) =>
                  haversineDistance(
                    [shuttleStop.stop_lat, shuttleStop.stop_lon],
                    [selectedStop.stop_lat, selectedStop.stop_lon]
                  ) <= MAX_RADIUS_FOR_STOPS_MILES
              )
              .map(
                (s, idx) =>
                  s.stop_lat &&
                  s.stop_lon && (
                    <Marker
                      key={`${idx}-${s.stop_name}-shuttle-marker`}
                      position={[s.stop_lat, s.stop_lon]}
                      icon={genIcon(existingShuttleStopColor)}
                    >
                      <Popup>{s.stop_name}</Popup>
                    </Marker>
                  )
              )}
          </LayerGroup>
        </LayersControl.Overlay>
      )}
      {existingBusStops && (
        <LayersControl.Overlay name={busLayerName}>
          <LayerGroup>
            {existingBusStops
              .filter(
                (gtfsStop) =>
                  haversineDistance(
                    [gtfsStop.lat, gtfsStop.lon],
                    [selectedStop.stop_lat, selectedStop.stop_lon]
                  ) <= MAX_RADIUS_FOR_STOPS_MILES
              )
              .map(
                (s, idx) =>
                  s.lat &&
                  s.lon && (
                    <Marker
                      key={`${idx}-${s.name}-bus-stop-marker`}
                      position={[s.lat, s.lon]}
                      icon={genIcon(existingBusStopColor)}
                    >
                      <Popup>{s.name}</Popup>
                    </Marker>
                  )
              )}
          </LayerGroup>
        </LayersControl.Overlay>
      )}
      <LayersControl.Overlay name={selectedStopLayerName} checked={true}>
        <Marker
          position={[selectedStop.stop_lat, selectedStop.stop_lon]}
          icon={genIcon(newStopColor)}
        >
          <Popup>{selectedStop.stop_name}</Popup>
        </Marker>
      </LayersControl.Overlay>
      )
    </LayersControl>
  )
}

export default StopLayerControl
