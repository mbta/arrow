import React, { useMemo } from "react"
import { LatLngExpression } from "leaflet"
import { MapContainer, Polyline, TileLayer } from "react-leaflet"
import { useMap } from 'react-leaflet/hooks'


const defaultCenter: LatLngExpression = [42.360718, -71.05891]

const generatePolyline = (coordinates) => <Polyline positions={coordinates} />;

const getMapBounds = (shapes) => {
  let shapeCoords = []
  return shapes.forEach(shape => shapeCoords + shape.coordinates)
}

const ShapeViewMap = ({ shapes }) => {
  const polyLines = useMemo(() => shapes.map(shape => generatePolyline(shape.coordinates)), shapes);
  return (
    <MapContainer
      data-testid="shape-view-map-container"
      style={{ height: "800px" }}
      bounds={getMapBounds(shapes)}
      zoom={13}
      scrollWheelZoom={true}
    >
      {polyLines}
      <TileLayer
        attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
      />
    </MapContainer>
  )
}

export default ShapeViewMap
