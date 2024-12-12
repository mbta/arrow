import { GtfsStop, Stop } from "./types"

import React from "react"
import { LayersControl, Marker, Popup, LayerGroup } from "react-leaflet"
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

const StopLayerControl = ({
  stop,
  existingShuttleStops,
  existingBusStops,
}: {
  stop: Stop | undefined
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
            {existingShuttleStops.map(
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
            {existingBusStops.map(
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

      {stop?.stop_lat && stop?.stop_lon && (
        <LayersControl.Overlay name={selectedStopLayerName} checked={true}>
          <Marker
            position={[stop.stop_lat, stop.stop_lon]}
            icon={genIcon(newStopColor)}
          >
            <Popup>{stop.stop_name}</Popup>
          </Marker>
        </LayersControl.Overlay>
      )}
    </LayersControl>
  )
}

export default StopLayerControl
