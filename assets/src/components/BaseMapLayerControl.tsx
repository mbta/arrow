import React from "react"
import {
  LayersControl,
  TileLayer,
} from "react-leaflet"

const BaseMapLayerControl = () => {
  return (
    <LayersControl
      position="topright"
      key="layer-control-tileset"
      collapsed={false}
    >
      <LayersControl.BaseLayer name="Map" checked={true}>
        <TileLayer
          attribution='&copy; <a href="https://www.mass.gov/info-details/massgis-data-2021-aerial-imagery">MassGIS 2021</a>'
          url="https://mbta-map-tiles.s3.amazonaws.com/skate_osm_tiles/{z}/{x}/{y}.png"
        />
      </LayersControl.BaseLayer>
      <LayersControl.BaseLayer name="Satellite">
        <TileLayer
          attribution='&copy; <a href="https://www.mass.gov/info-details/massgis-data-2021-aerial-imagery">MassGIS 2021</a>'
          url="https://tiles.arcgis.com/tiles/hGdibHYSPO59RG1h/arcgis/rest/services/orthos2021/MapServer/tile/{z}/{y}/{x}"

        />
      </LayersControl.BaseLayer>
    </LayersControl>
  )
}

export default BaseMapLayerControl
