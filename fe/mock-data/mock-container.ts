import { Feature, Point } from "geojson";
import { mergeDeepLeft, mergeDeepRight } from "ramda";
import { ContainerData, ContainersLocationFeatureCollection, LocationData, ContainerLocationFeature, TrashTypes } from "../types/container";

export const mockPlasticContainer: ContainerData = {
  emptyingFrequency: 2,
  containerTypes: [{
    volume: 2000,
    name: 'pepa'
  }],
  numberOfPeople: 242,
  predictedDemand: 0.5,
  trashType: 'plastic'
}

export const mockPaperContainer: ContainerData = {
  emptyingFrequency: 2,
  containerTypes: [{
    volume: 2000,
    name: 'pepa'
  }],
  numberOfPeople: 242,
  predictedDemand: 0.5,
  trashType: 'paper'
}

export const mockLocation: LocationData = {
  containers: [mockPlasticContainer, mockPaperContainer,mockPaperContainer,mockPaperContainer,mockPaperContainer],
  address: 'U Modrozelených Alejí 43',
  isPrivate: false,
  id: "sh37s-hn3u23-sivms2640"
}


export const trashTypes: TrashTypes[] = [
  'paper',
  'plastic',
  'colored_glass',
  'clear_glass',
  'beverage_carton',
  'metal',
  'textile',
  'electronic',
]

export const trashIdToColorId = {
  'colored_glass': 'colored-glass',
  'clear_glass': 'clear-glass',
  'plastic': 'plastic',
  'paper': 'paper',
  'metal': 'metal',
  'textile': 'textiles',
  'electronic': 'electronics',
  'beverage_carton': 'beverage-carton'
}

export const trashIdNumToTrashType: {[key: number]: TrashTypes} = {
	1: "colored_glass",
	2: "electronic",
	3: "metal",
	4: "beverage_carton",
	5: "paper",
	6: "plastic",
	7: "clear_glass",
	8: "textile", 
}
export const trashTypeToTrashNum: {[key in TrashTypes]: number} = {
	"colored_glass": 1,
	"electronic": 2,
	"metal": 3,
	"beverage_carton": 4,
	"paper": 5,
	"plastic": 6,
	"clear_glass": 7,
	"textile": 8 
}