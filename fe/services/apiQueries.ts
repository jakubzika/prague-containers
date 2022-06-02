import { useQuery } from "react-query";
import { API } from "./api";
import useGeolocation from 'react-hook-geolocation'
import { useDebounce } from "../lib/useDebounce";
import { useQueryTrashTypes } from "../lib/useQueryTrashTypes";
import { usePosition } from "../lib/usePosition";

export const useLocations = (locationIds: string[] | undefined) => 
  useQuery(['locations', locationIds], async () => {
    if(locationIds === undefined) return
    const { data } = await API.getLocations(locationIds)
    return data
  })

export const useNearestLocations = () => {
  const {latitude, longitude, error} = usePosition()
  const [lat, lng] = useDebounce([latitude, longitude], 3000)
  const { onlyPublic, trashTypes } = useQueryTrashTypes()

  return useQuery(['nearest-locations', trashTypes, lat,lng], async () => {
      if(lat === undefined || lng === undefined) return undefined
      const { data } = await API.getNearestLocation(trashTypes, [lat, lng], onlyPublic)
      return data
  }, {
    refetchInterval: 30000,
  })
}

export const useAllLocations = () =>  
  useQuery(['all-locations'], async () => {
    const { data } = await API.getAllLocations()
    return data
  }, {
    refetchInterval: false,
    refetchOnWindowFocus: false
  })