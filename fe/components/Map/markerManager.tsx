import mapboxgl from 'mapbox-gl'
import { getTrashTypeFromContainers } from '../../lib/dataUtil'
import ClusterLocationMarkerHTML from './ClusterLocationMarkerHTML'
import LocationMarkerHTML from './LocationMarkerHTML'

export type MarkersState = {
  clusterMarkers: { [key: string]: mapboxgl.Marker }
  clusterMarkersOnScreen: { [key: string]: mapboxgl.Marker }
  markers: { [key: string]: mapboxgl.Marker }
  markersOnScreen: { [key: string]: mapboxgl.Marker }
}

export const initMarkers = (): MarkersState => ({
  clusterMarkers: {},
  clusterMarkersOnScreen: {},
  markers: {},
  markersOnScreen: {},
})

export const updateMarkers = (
  state: MarkersState,
  map: mapboxgl.Map,
  sourceName: string,
  onContainerLocationClick: (locationId: string) => void
): MarkersState => {
  const { clusterMarkers, clusterMarkersOnScreen, markers, markersOnScreen } =
    state

  let newMarkers = {}
  let newClusterMarkers = {}

  const features = map.querySourceFeatures(sourceName)
  for (const feature of features) {
    if (feature.geometry.type !== 'Point') continue
    const coords = feature.geometry.coordinates as [number, number]
    const props: any = feature.properties

    if (!props.cluster) {
      // if (props.accessibility_id !== 1) continue
      const id = props.id

      const trashTypes = getTrashTypeFromContainers(
        JSON.parse(props.containers)
      )

      let marker = markers[id]

      const onClick = () => onContainerLocationClick(id)

      if (!marker) {
        marker = markers[id] = new mapboxgl.Marker({
          element: LocationMarkerHTML(trashTypes, onClick),
        }).setLngLat(coords)
      }

      newMarkers[id] = marker

      if (!markersOnScreen[id]) marker.addTo(map)
    } else {
      const id = props.cluster_id

      const count = props.point_count
      const countAbbr = props.point_count_abbreviated

      let marker = clusterMarkers[id]
      if (!marker) {
        marker = clusterMarkers[id] = new mapboxgl.Marker({
          element: ClusterLocationMarkerHTML(count, countAbbr),
        }).setLngLat(coords)
      }
      newClusterMarkers[id] = marker

      if (!clusterMarkersOnScreen[id]) marker.addTo(map)
    }
  }

  for (const id in markersOnScreen) {
    if (!newMarkers[id]) markersOnScreen[id].remove()
  }

  for (const id in clusterMarkersOnScreen) {
    if (!newClusterMarkers[id]) clusterMarkersOnScreen[id].remove()
  }

  return {
    ...state,
    markersOnScreen: newMarkers,
    clusterMarkersOnScreen: newClusterMarkers,
  }
}

export const removeAllMarkers = (state: MarkersState) => {
  for (const marker of Object.values(state.markersOnScreen)) {
    marker.remove()
  }

  for (const clusterMarker of Object.values(state.clusterMarkersOnScreen)) {
    clusterMarker.remove()
  }

  return initMarkers()
}
