// will be generated

import { Feature, FeatureCollection, Point } from 'geojson'

export type TrashTypes =
  | 'paper'
  | 'plastic'
  | 'colored_glass'
  | 'clear_glass'
  | 'beverage_carton'
  | 'metal'
  | 'textile'
  | 'electronic'

export type ContainerType = {
  volume: number
  name: string
}

type ContainerStaticData = {
  emptyingFrequency: number
  containerTypes: ContainerType[]
  trashType: TrashTypes
}

type ContainerComputedData = {
  fullness?: number
  numberOfPeople: number
  predictedDemand: number
}

// lat, l
export type Location = [
  number, // lat
  number // lng
]

export type ContainerData = ContainerStaticData & ContainerComputedData

export type LocationData = {
  containers: ContainerData[]
  isPrivate: boolean
  address: string
  id: string
}

export type ContainerServer = {
  cleaning_frequency: {
    frequency: number
    id: number
    duration: string
  }
  container_type: string
  trash_type: {
    id: number
    description: string
  }
  knsko_id: number
  container_id: number
}

export type TrashTypeInfoServer = {
  population_sum: number
  location_throughput: number
  demand: number
}

export type LocationServer = {
  district: string
  name: string
  is_monitored: boolean
  accessibility_id: number
  id: string
  accessibility_description: string
  knsko_id: number
  containers: ContainerServer[]
  updated_at: Date
  station_number: string
  trash_type_info: { [key: number]: TrashTypeInfoServer }
}

export type ContainerLocationFeature = Feature<Point, LocationServer>

export type ContainersLocationFeatureCollection = FeatureCollection<
  Point,
  LocationServer
>

// const a: FeatureCollection<Point, LocationData> = {
//   features: [
//     {
//       type: 'Feature',
//       geometry: { coordinates: [1, 1], type: 'Point' },
//       properties: {

//       },
//     },
//   ],
//   type: 'FeatureCollection',
// }
