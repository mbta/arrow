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

const PolyLines = ({ shapes }: { shapes: Shape[] }) =>
  shapes.map((shape: Shape, index: number) => {
    const key = crypto.randomUUID()
    return <PolyLine shape={shape} index={index} key={key} keyPrefix={key} />
  })

const PolyLine = ({
  shape,
  index,
  keyPrefix,
}: {
  shape: Shape
  index: number
  keyPrefix: string
}) => {
  const colorValue = COLORS[index]
  const color = `#${colorValue}`
  const start = shape.coordinates[0]
  const end = shape.coordinates.slice(-1)[0]

  return (
    <LayersControl.Overlay
      checked
      name={generateNameField(shape.name, colorValue)}
      key={`${keyPrefix}-control-overlay`}
    >
      <LayerGroup key={`${keyPrefix}-control-group`}>
        <Polyline
          positions={shape.coordinates as LatLngExpression[]}
          color={color}
          key={`${keyPrefix}-line`}
        />
        <CircleMarker
          center={start as LatLngExpression}
          pathOptions={{ color }}
          radius={10}
          key={`${keyPrefix}-line-start`}
        />
        <CircleMarker
          center={end as LatLngExpression}
          pathOptions={{ color, fillColor: color, fillOpacity: 1.0 }}
          radius={10}
          key={`${keyPrefix}-line-end`}
        />
      </LayerGroup>
    </LayersControl.Overlay>
  )
}

const getMapBounds = (shapes: Shape[]) => {
  const shapeLats: number[] = []
  const shapeLongs: number[] = []
  shapes.forEach((shape: Shape) =>
    shape.coordinates.forEach((coordinate) => {
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
      return (
        <LayersControl
          position="bottomright"
          key="layer-control"
          collapsed={false}
        >
          <PolyLines shapes={shapes} />
        </LayersControl>
      )
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
