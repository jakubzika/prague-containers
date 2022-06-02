import axios, { AxiosPromise, AxiosRequestConfig } from "axios";
import { Point } from "geojson";
import config from "../config";
import { trashTypeToTrashNum } from "../mock-data/mock-container";
import { ContainersLocationFeatureCollection, TrashTypes } from "../types/container";

export const API = (() => {
  let options: AxiosRequestConfig = {}
  if (config.public.apiBaseV1) {
    options.baseURL = config.public.apiBaseV1
  }
  const axiosInstance = axios.create(options)

  return {
    getNearestLocation(trashTypes: TrashTypes[],position: [number, number], onlyPublic: boolean):AxiosPromise<ContainersLocationFeatureCollection> {

      const trashIds = trashTypes.map(val => trashTypeToTrashNum[val])
      return axiosInstance.get(`/nearest-locations`, {
        params: {
          trashTypes: trashIds.join(','),
          lat: position[0],
          lng: position[1],
          onlyPublic
      }})
    },
    getLocations(locationIds: string[]):AxiosPromise<ContainersLocationFeatureCollection> {
      return axiosInstance.get(`/locations`, {
        params: {
          locationIds: JSON.stringify(locationIds)
        }
      })
    },
    getAllLocations():AxiosPromise<ContainersLocationFeatureCollection> {
      return axiosInstance.get(`/all-locations`)
    }
  } 
})()