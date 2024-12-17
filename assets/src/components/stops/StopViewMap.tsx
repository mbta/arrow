import React, { useEffect } from "react"
import { canvas, LatLngExpression } from "leaflet"
import { MapContainer, useMap } from "react-leaflet"
import BaseMapLayerControl from "../BaseMapLayerControl"
import { Stop, GtfsStop } from "./types"
import { getMapBounds } from "../util/maps"
import StopLayerControl from "./StopLayerControl"

const defaultCenter: LatLngExpression = [42.360718, -71.05891]

interface StopViewMapProps {
  stop?: Stop
  existingShuttleStops?: Stop[]
  existingBusStops?: GtfsStop[]
}

const MapUpdater = ({ stop }: { stop?: Stop }) => {
  const map = useMap()
  useEffect(() => {
    const bounds = getMapBounds(
      stop?.stop_lat && stop?.stop_lon ? [[stop?.stop_lat, stop?.stop_lon]] : []
    )
    if (bounds) {
      map.setMaxBounds(bounds)
    } else {
      map.setView(defaultCenter, 13)
    }
  }, [map, stop])

  return null
}

const StopViewMap = ({
  stop,
  existingShuttleStops,
  existingBusStops,
}: StopViewMapProps) => {
  return (
    <MapContainer
      data-testid="stop-view-map-container"
      style={{ height: "800px" }}
      center={defaultCenter}
      zoom={13}
      scrollWheelZoom={true}
      renderer={canvas()}
    >
      <MapUpdater stop={stop} />
      <BaseMapLayerControl />
      <StopLayerControl
        stop={stop}
        existingShuttleStops={existingShuttleStops}
        existingBusStops={existingBusStops}
      />
    </MapContainer>
  )
}

export default StopViewMap
