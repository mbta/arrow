import { divIcon, LatLngBoundsExpression, LatLngTuple } from "leaflet"

// Generates minimum and maximum coordinate pairs given a list of coordinate pairs
const getMapBounds = (
  coords: LatLngTuple[]
): LatLngBoundsExpression | undefined => {
  if (coords.length === 0) {
    return undefined
  }

  coords = coords.filter((c) => c[0] && c[1])

  const lats = coords.map((c) => c[0])
  const longs = coords.map((c) => c[1])

  return [
    [Math.max(...lats), Math.max(...longs)],
    [Math.min(...lats), Math.min(...longs)],
  ] as LatLngBoundsExpression
}

// Generates a google map style maps pin for marking a location on a map
// Give the stop an ID corresponding to the GTFS / arrow stop ID
const generateMapPin = (color: string, stopId: string) => {
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
  content: '';
  width: 14px;
  height: 14px;
  background-color: white;
  border-radius: 50%;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);`

  return divIcon({
    className: "",
    iconSize: [30, 42.4264],
    iconAnchor: [15, 42.4264],
    html: `<div id="${stopId}"><span style="${markerHtmlStyles}"><span style="${innerCircleStyles}"></span></div>`,
  })
}

// Generates a label used for the legend of a map
const generateLegend = (color: string, name: string) =>
  `<div class="legend-square" style="background-color: #${color}"></div> ${name}`

// Calculates the distance in miles between two latitude / longitude pairs
const haversineDistanceMiles = (
  pos: [number, number],
  otherPos: [number, number]
) => {
  // radius in miles
  const earthRadius = 3963.1

  const deltaLatitude = ((otherPos[0] - pos[0]) * Math.PI) / 180
  const deltaLongitude = ((otherPos[1] - pos[1]) * Math.PI) / 180

  // https://en.wikipedia.org/wiki/Haversine_formula
  const arc =
    Math.cos((pos[0] * Math.PI) / 180) *
      Math.cos((otherPos[0] * Math.PI) / 180) *
      Math.sin(deltaLongitude / 2) *
      Math.sin(deltaLongitude / 2) +
    Math.sin(deltaLatitude / 2) * Math.sin(deltaLatitude / 2)
  const line = 2 * Math.atan2(Math.sqrt(arc), Math.sqrt(1 - arc))

  return earthRadius * line
}

export {
  generateMapPin as genIcon,
  getMapBounds,
  generateLegend,
  haversineDistanceMiles,
}
