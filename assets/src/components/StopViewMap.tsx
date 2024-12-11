import React from "react"
import { LatLngExpression, icon } from "leaflet"
import { MapContainer, Marker, Popup } from "react-leaflet"
import BaseMapLayerControl from "./BaseMapLayerControl"

type Stop = {
  stop_name: string
  stop_desc: string
  stop_lat: number
  stop_lon: number
}

const defaultCenter: LatLngExpression = [42.360718, -71.05891]

const markerIcon = icon({
  iconUrl: "/images/marker-icon.png",
  iconRetinaUrl: "/images/marker-icon-2x.png",
  shadowUrl: "/images/marker-shadow.png",
  iconSize: [25, 41],
  iconAnchor: [12, 41],
})

const StopViewMap = ({ stop }: { stop?: Stop }) => {
  return (
    <MapContainer
      data-testid="stop-view-map-container"
      style={{ height: "800px" }}
      center={defaultCenter}
      zoom={13}
      scrollWheelZoom={true}
    >
      <BaseMapLayerControl />
      {stop && stop.stop_lat && stop.stop_lon && (
        <Marker position={[stop.stop_lat, stop.stop_lon]} icon={markerIcon}>
          <Popup>{stop.stop_name}</Popup>
        </Marker>
      )}
    </MapContainer>
  )
}

export default StopViewMap
