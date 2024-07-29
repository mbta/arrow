import React from "react"
import { LatLngExpression, icon } from "leaflet"
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet"

type Stop = {
  name: string
  description: string
  latitude: number
  longitude: number
}

const defaultCenter: LatLngExpression = [42.360718, -71.05891]

const markerIcon = icon({
  iconUrl: "/images/marker-icon.png",
  iconRetinaUrl: "/images/marker-icon-2x.png",
  shadowUrl: "/images/marker-shadow.png",
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
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
      {stop && (
        <Marker position={[stop.latitude, stop.longitude]} icon={markerIcon}>
          <Popup>{stop.name}</Popup>
        </Marker>
      )}
    </MapContainer>
  )
}

export default StopViewMap
