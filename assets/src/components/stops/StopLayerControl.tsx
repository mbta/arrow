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

const StopLayerControl = ({
  selectedStop,
  existingShuttleStops,
  existingBusStops,
}: {
  selectedStop: Stop
  existingShuttleStops: Stop[]
  existingBusStops: GtfsStop[]
}) => {
  return (
    <LayersControl
      position="bottomright"
      key="layer-control-stops"
      collapsed={false}
    >
      {existingShuttleStops.length > 0 && (
        <LayersControl.Overlay name={shuttleLayerName}>
          <LayerGroup>
            {existingShuttleStops.map(
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
                    <Popup>
                      {s.stop_name} ({s.stop_id})
                    </Popup>
                  </Marker>
                )
            )}
          </LayerGroup>
        </LayersControl.Overlay>
      )}
      {existingBusStops.length > 0 && (
        <LayersControl.Overlay name={busLayerName}>
          <LayerGroup>
            {existingBusStops.map(
              (s, idx) =>
                s.lat &&
                s.lon && (
                  <Marker
                    key={`${idx}-${s.name}-bus-stop-marker`}
                    position={[s.lat, s.lon]}
                    icon={genIcon(existingBusStopColor, `gtfs-stop-${s.id}`)}
                  >
                    <Popup>
                      {s.name} ({s.id})
                    </Popup>
                  </Marker>
                )
            )}
          </LayerGroup>
        </LayersControl.Overlay>
      )}
      {selectedStop.stop_lat && selectedStop.stop_lon && (
        <LayersControl.Overlay name={selectedStopLayerName} checked={true}>
          <Marker
            position={[selectedStop.stop_lat, selectedStop.stop_lon]}
            icon={genIcon(newStopColor, "selected-stop")}
          >
            <Popup>
              {selectedStop.stop_name} ({selectedStop.stop_id})
            </Popup>
          </Marker>
        </LayersControl.Overlay>
      )}
      )
    </LayersControl>
  )
}

export default StopLayerControl
