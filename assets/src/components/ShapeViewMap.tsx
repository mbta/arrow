import React, { useMemo } from "react"
import { LatLngBoundsExpression, LatLngExpression } from "leaflet"
import {
  CircleMarker,
  LayersControl,
  LayerGroup,
  MapContainer,
  Polyline,
  TileLayer,
} from "react-leaflet"

type Shape = {
  name: string
  coordinates: number[][]
}

interface ShapeViewMapProps {
  shapes: Shape[]
}

const COLORS = [
  "da291c",
  "003da5",
  "ffc72c",
  "00843d",
  "ed8b00",
  "7c878e",
  "494f5c",
  "003383",
  "80276c",
  "008eaa",
  "52bbc5",
]

const defaultCenter: LatLngExpression = [42.360718, -71.05891]

const generateNameField = (name: string, color: string) =>
  `<div class="legend-square color-${color}"></div> ${name}`

const generatePolyline = (shape: Shape, index: number) => {
  const colorValue = COLORS[index]
  const color = `#${colorValue}`
  const start = shape.coordinates[0]
  const end = shape.coordinates.slice(-1)[0]
  const key = crypto.randomUUID()

  return [
    <LayersControl.Overlay
      checked
      name={generateNameField(shape.name, colorValue)}
      key={`${key}-control-overlay`}
    >
      ,
      <LayerGroup key={`${key}-control-group`}>
        ,
        <Polyline
          positions={shape.coordinates as LatLngExpression[]}
          color={color}
          key={`${key}-line`}
        />
        ,
        <CircleMarker
          center={start as LatLngExpression}
          pathOptions={{ color }}
          radius={10}
          key={`${key}-line-start`}
        />
        ,
        <CircleMarker
          center={end as LatLngExpression}
          pathOptions={{ color, fillColor: color, fillOpacity: 1.0 }}
          radius={10}
          key={`${key}-line-end`}
        />
        ,
      </LayerGroup>
      ,
    </LayersControl.Overlay>,
  ]
}

const getMapBounds = (shapes: Shape[]) => {
  const shapeLats: number[] = []
  const shapeLongs: number[] = []
  shapes.map((shape: Shape) =>
    shape.coordinates.map((coordinate) => {
      shapeLats.push(coordinate[0])
      shapeLongs.push(coordinate[1])
    })
  )

  return [
    [Math.max(...shapeLats), Math.max(...shapeLongs)],
    [Math.min(...shapeLats), Math.min(...shapeLongs)],
  ] as LatLngBoundsExpression
}

const ShapeViewMap = ({ shapes }: ShapeViewMapProps) => {
  const polyLines = useMemo(() => {
    if (shapes && shapes.length > 0) {
      const lines = shapes.map((shape, index) => generatePolyline(shape, index))
      return [
        <LayersControl
          position="topright"
          key="layer-control"
          collapsed={false}
        >
          ,{lines},
        </LayersControl>,
      ]
    } else {
      return []
    }
  }, [shapes])

  const mapProps = useMemo(() => {
    if (shapes && shapes.length > 0) {
      return { bounds: getMapBounds(shapes) }
    } else {
      return { center: defaultCenter }
    }
  }, [shapes])

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
