import { GtfsStop, Stop } from "./types"

import React from "react"
import { LayerGroup, LayersControl, Marker, Popup } from "react-leaflet"
import { generateLegend, genIcon, haversineDistanceMiles } from "../util/maps"

const newStopColor = "f24727"
const existingShuttleStopColor = "414bb2"
const existingBusStopColor = "fac711"

const shuttleLayerName = generateLegend(
  existingShuttleStopColor,
  "Existing Shuttle Stops"
)
const busLayerName = generateLegend(existingBusStopColor, "Existing Bus Stops")
const selectedStopLayerName = generateLegend(newStopColor, "Selected Stop")

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
                  haversineDistanceMiles(
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
                      icon={genIcon(
                        existingShuttleStopColor,
                        `arrow-stop-${s.stop_id}`
                      )}
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
                  haversineDistanceMiles(
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
                      icon={genIcon(existingBusStopColor, `gtfs-stop-${s.id}`)}
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
          icon={genIcon(newStopColor, "selected-stop")}
        >
          <Popup>{selectedStop.stop_name}</Popup>
        </Marker>
      </LayersControl.Overlay>
      )
    </LayersControl>
  )
}

export default StopLayerControl
