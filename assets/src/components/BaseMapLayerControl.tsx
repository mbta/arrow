import React from "react"
import { LayersControl, TileLayer } from "react-leaflet"

const BaseMapLayerControl = () => {
  return (
    <LayersControl
      position="topright"
      key="layer-control-tileset"
      collapsed={false}
    >
      <LayersControl.BaseLayer name="Map" checked={true}>
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://cdn.mbta.com/osm_tiles/{z}/{x}/{y}.png"
        />
      </LayersControl.BaseLayer>
      <LayersControl.BaseLayer name="Satellite">
        <TileLayer
          attribution='&copy; <a href="https://www.mass.gov/info-details/massgis-data-2023-aerial-imagery">MassGIS 2023</a>'
          url="https://tiles.arcgis.com/tiles/hGdibHYSPO59RG1h/arcgis/rest/services/orthos2023/MapServer/tile/{z}/{y}/{x}"
        />
      </LayersControl.BaseLayer>
    </LayersControl>
  )
}

export default BaseMapLayerControl
