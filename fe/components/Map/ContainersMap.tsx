import mapboxgl from 'mapbox-gl'
import React, { FC, useEffect, useMemo, useRef, useState } from 'react'
import { publicConfig } from '../../config'
import 'mapbox-gl/dist/mapbox-gl.css'
import {
  ContainersLocationFeatureCollection,
  LocationData,
  TrashTypes,
} from '../../types/container'
import Map, {
  GeolocateControl,
  Layer,
  MapRef,
  NavigationControl,
  Source,
} from 'react-map-gl'
import { mockLocation } from '../../mock-data/mock-container'
import { containerData } from '../../mock-data/container-locations'
import { initMarkers, updateMarkers } from './markerManager'
import FilterControl from './FilterControl'
import { getTrashTypeFromContainers } from '../../lib/dataUtil'
import { append, flatten, intersection } from 'ramda'
import LocationDetailModal from './LocationDetailModal'
import { useRouter } from 'next/router'
import { useDebounce } from '../../lib/useDebounce'

type Props = {
  locations?: ContainersLocationFeatureCollection
  trashTypeFilters?: TrashTypes[]
  showFilterWindow?: boolean
  geolocateUserOnLoad?: boolean
}

mapboxgl.accessToken = publicConfig.mapbox.token || ''

// const tmpData = JSON.parse(containerData)
//
const SOURCE_NAME = 'container-locations'

const ContainersMap: FC<Props> = ({
  locations,
  showFilterWindow = false,
  geolocateUserOnLoad = false,
}) => {
  const mapRef = useRef<MapRef>(null)

  const [selectedContainer, setSelectedContainer] = useState<
    undefined | string
  >()

  const { query, replace } = useRouter()

  const [trashTypeFilters, setTrashTypeFilters] = useState<TrashTypes[]>([])
  const [onlyPublic, setOnlyPublic] = useState(true)

  {
    const debouncedQuery = useDebounce({ trashTypeFilters, onlyPublic }, 5000)
    useEffect(() => {
      if (showFilterWindow == false) return
      replace({
        query: debouncedQuery,
      })
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [debouncedQuery, showFilterWindow])
  }

  useEffect(() => {
    if (query.trashTypes !== undefined) {
      setTrashTypeFilters(flatten(append(query.trashTypes as TrashTypes[], [])))
    }

    if (query.onlyPublic !== undefined)
      setOnlyPublic(query.onlyPublic === 'true')
  }, [query])

  const filteredData = useMemo(() => {
    if (trashTypeFilters === undefined || locations === undefined) return
    const filtered = {
      type: 'FeatureCollection',
      features: locations.features.filter(
        (location) =>
          (onlyPublic ? location.properties.accessibility_id === 1 : true) &&
          intersection(
            getTrashTypeFromContainers(location.properties.containers),
            trashTypeFilters
          ).length === trashTypeFilters.length
      ),
    }
    return filtered
  }, [trashTypeFilters, onlyPublic, locations]) as unknown as LocationData

  const markersStateRef = useRef(initMarkers())

  const onContainerLocationClick = (locationId: string) =>
    setSelectedContainer(locationId)

  useEffect(() => {
    if (mapRef.current === null) return
    const map = mapRef.current.getMap()

    const onRender = () => {
      if (!map.isSourceLoaded(SOURCE_NAME)) return
      markersStateRef.current = updateMarkers(
        markersStateRef.current,
        map,
        SOURCE_NAME,
        onContainerLocationClick
      )
    }
    map.on('render', onRender)

    return () => {
      map.off('render', onRender)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mapRef.current])

  // the culprit of random map loads
  useEffect(() => {
    if (mapRef.current == null) return
    mapRef.current.on('load', () => {
      if (geolocateUserOnLoad)
        (
          document.querySelector('.mapboxgl-ctrl-geolocate') as HTMLElement
        ).click()
      if (mapRef.current == null) return
    })
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mapRef.current])

  return (
    <div className="bg-plastic">
      <div className="h-[85vh] w-full" style={{}}>
        <Map
          mapStyle="mapbox://styles/zola52/ckp1p3yc94wci17o53qtrhzpf"
          initialViewState={{
            longitude: 14.459534,
            latitude: 50.083121,
            zoom: 11,
          }}
          mapboxAccessToken={publicConfig.mapbox.token}
          ref={mapRef}
        >
          <Source
            id={SOURCE_NAME}
            type="geojson"
            data={filteredData as any}
            cluster={true}
            clusterRadius={40}
          >
            <Layer
              id="container-location"
              type="circle"
              source={SOURCE_NAME}
              paint={{
                'circle-color': '#ff00ff',
                'circle-radius': 0,
              }}
              filter={['!=', 'cluster', true]}
            />
          </Source>
          <NavigationControl position="bottom-right" />
          <GeolocateControl
            showUserHeading={true}
            trackUserLocation={true}
            showUserLocation={true}
            position="bottom-right"
          />
          {selectedContainer === undefined && showFilterWindow && (
            <FilterControl
              trashTypeFilters={trashTypeFilters}
              setTrashTypeFilters={setTrashTypeFilters}
              onOnlyPublicChange={setOnlyPublic}
              onlyPublic={onlyPublic}
            />
          )}
        </Map>
      </div>

      {selectedContainer && (
        <LocationDetailModal
          locationId={selectedContainer}
          onClose={() => setSelectedContainer(undefined)}
        />
      )}
    </div>
  )
}

export default ContainersMap
