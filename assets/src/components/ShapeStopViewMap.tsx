import React, { useEffect } from "react"
import {
  divIcon,
  type LatLngBoundsExpression,
  type LatLngExpression,
} from "leaflet"
import {
  CircleMarker,
  LayersControl,
  LayerGroup,
  MapContainer,
  Polyline,
  Marker,
  Popup,
  useMap,
} from "react-leaflet"
import BaseMapLayerControl from "./BaseMapLayerControl"

type Coordinate = [number, number]
interface Shape {
  name: string
  coordinates: Coordinate[]
}

interface Stop {
  stop_id: string
  stop_name: string
  stop_desc: string
  stop_lat: number
  stop_lon: number
  stop_sequence: number
}

interface Layer {
  name: string
  direction_id: string
  color: string
  shape: Shape | null
  stops: Stop[]
}

interface ShapeStopViewMapProps {
  layers: Layer[]
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

const genIcon = (color: string, text: string) => {
  const markerHtmlStyles = `
  background-color: #${color};
  display: block;
  width: 30px;
  height: 30px;
  border-radius: 50% 50% 50% 0;
  position: relative;
  transform: rotate(-45deg);
  box-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);`

  const innerCircleStyles = `
  width: 18px;
  height: 18px;
  background-color: white;
  border-radius: 50%;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);`

  const innerContentStyles = `
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%) rotate(45deg);
  z-index: 1;`

  return divIcon({
    className: "",
    iconSize: [30, 42.4264],
    iconAnchor: [15, 42.4264],
    html: `<div>
            <span style="${markerHtmlStyles}">
              <span style="${innerCircleStyles}"></span>
              <span style="${innerContentStyles}">${text}</span>
            </span>
          </div>`,
  })
}

const defaultCenter: LatLngExpression = [42.360718, -71.05891]

const generateNameField = (name: string, color: string) =>
  `<div class="legend-square color-${color}"></div> ${name}`

const MapLayers = ({ layers }: { layers: Layer[] }) => {
  return layers.map((layer: Layer, index: number) => {
    return (
      <MapLayer
        layer={layer}
        index={index}
        key={layer.direction_id}
        keyPrefix={index.toString()}
      />
    )
  })
}

const MapLayer = ({
  layer,
  index,
  keyPrefix,
}: {
  layer: Layer
  index: number
  keyPrefix: string
}) => {
  const colorValue = COLORS[index]
  const color = `#${colorValue}`
  return (
    <LayersControl.Overlay
      checked
      name={generateNameField(`Direction ${layer.direction_id}`, colorValue)}
      key={`${keyPrefix}-control-overlay`}
    >
      <LayerGroup key={`${keyPrefix}-control-group`}>
        {layer.shape && (
          <PolyLine shape={layer.shape} color={color} keyPrefix={keyPrefix} />
        )}
        {layer.stops.map(
          (stop) =>
            stop.stop_lat &&
            stop.stop_lon && (
              <Marker
                key={stop.stop_id}
                position={[stop.stop_lat, stop.stop_lon]}
                icon={genIcon(colorValue, stop.stop_sequence.toString())}
              >
                <Popup>{stop.stop_name}</Popup>
              </Marker>
            )
        )}
      </LayerGroup>
    </LayersControl.Overlay>
  )
}

const PolyLine = ({
  shape,
  color,
  keyPrefix,
}: {
  shape: Shape
  color: string
  keyPrefix: string
}) => {
  const start = shape.coordinates[0]
  const end = shape.coordinates.slice(-1)[0]

  return (
    <>
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
    </>
  )
}

const getMapBounds = (layers: Layer[]): LatLngBoundsExpression | null => {
  const lats: number[] = []
  const longs: number[] = []
  layers.forEach((layer: Layer) => {
    if (layer.shape) {
      layer.shape.coordinates.forEach((coordinate) => {
        lats.push(coordinate[0])
        longs.push(coordinate[1])
      })
    }
    layer.stops.forEach((stop: Stop) => {
      lats.push(stop.stop_lat)
      longs.push(stop.stop_lon)
    })
  })

  if (lats.length === 0 || longs.length === 0) {
    return null
  }
  return [
    [Math.max(...lats), Math.max(...longs)],
    [Math.min(...lats), Math.min(...longs)],
  ] as LatLngBoundsExpression
}

const MapUpdater = ({ layers }: ShapeStopViewMapProps) => {
  const map = useMap()

  useEffect(() => {
    if (layers && layers.length > 0) {
      const bounds = getMapBounds(layers)
      if (bounds) {
        map.fitBounds(bounds)
      } else {
        map.setView(defaultCenter, 13)
      }
    } else {
      map.setView(defaultCenter, 13)
    }
  }, [layers, map])

  return null
}

const ShapeStopViewMap = ({ layers }: ShapeStopViewMapProps) => {
  return (
    <MapContainer
      center={defaultCenter}
      data-testid="shape-view-map-container"
      style={{ height: "800px" }}
      zoom={13}
      scrollWheelZoom={true}
    >
      <MapUpdater layers={layers} />
      <BaseMapLayerControl />
      <LayersControl
        position="bottomright"
        key="layer-control"
        collapsed={false}
      >
        <MapLayers layers={layers} key="layer-map" />
      </LayersControl>
    </MapContainer>
  )
}

export default ShapeStopViewMap
