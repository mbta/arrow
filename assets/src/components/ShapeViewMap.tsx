import React, { useEffect, useMemo } from "react"
import { LatLngBoundsExpression, LatLngExpression } from "leaflet"
import { CircleMarker, MapContainer, Polyline, TileLayer } from "react-leaflet"

type Shape = {
  name: string;
  coordinates: number[][];
}

interface ShapeViewMapProps {
  shapes: Shape[]
}

const COLORS = [
  "#da291c",
  "#003da5",
  "#ffc72c",
  "#00843d",
  "#ed8b00",
  "#7c878e",
  "#494f5c",
  "#003383",
  "#80276c",
  "#008eaa",
  "#52bbc5"
]

const defaultCenter: LatLngExpression = [42.360718, -71.05891]

const generatePolyline = (coordinates: LatLngExpression[] | LatLngExpression[][], index: number) => {
  const color = COLORS[index]
  const start = coordinates[0]
  const end = coordinates.slice(-1)[0]
  const key = crypto.randomUUID()
  
  return [
    <Polyline positions={coordinates} color={COLORS[index]} key={key} />,
    <CircleMarker center={start as LatLngExpression} pathOptions={{ color }} radius={10} key={`${key}-start`}/>,
    <CircleMarker center={end as LatLngExpression} pathOptions={{ color, fillColor: color, fillOpacity: 1.0 }} radius={10} key={`${key}-end`} />,
  ];
};

const getMapBounds = (shapes: Shape[]) => {
  let shapeLats: number[] = []
  let shapeLongs: number[] = []
  shapes.map((shape: Shape) => shape.coordinates.map((coordinate) => {
    shapeLats.push(coordinate[0])
    shapeLongs.push(coordinate[1])
  }))

  return [
    [Math.max(...shapeLats), Math.max(...shapeLongs)],
    [Math.min(...shapeLats), Math.min(...shapeLongs)]
  ] as LatLngBoundsExpression
}

const ShapeViewMap = ({ shapes }: ShapeViewMapProps) => {
  const polyLines = useMemo(() => {
    if (shapes && shapes.length > 0) {
      return shapes.map((shape, index) => generatePolyline(shape.coordinates as LatLngExpression[], index))
    } else {
      return []
    }
  }, shapes);

  const mapProps = useMemo(() => {
    if (shapes && shapes.length > 0) {
      return { bounds: getMapBounds(shapes) }
    } else {
      return { center: defaultCenter }
    }
  }, shapes);  

  return (
    <MapContainer
      {...mapProps}
      data-testid="shape-view-map-container"
      style={{ height: "800px" }}
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
