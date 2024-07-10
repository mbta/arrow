import React from "react"
import { LatLngExpression } from "leaflet"
import { MapContainer, TileLayer } from "react-leaflet"

const defaultCenter: LatLngExpression = [42.360718, -71.05891]

const ShapeViewMap = () => {
  return (
    <MapContainer
      data-testid="shape-view-map-container"
      style={{ height: "800px" }}
      center={defaultCenter}
      zoom={13}
      scrollWheelZoom={true}
    >
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
    </MapContainer>
  )
}

export default ShapeViewMap
