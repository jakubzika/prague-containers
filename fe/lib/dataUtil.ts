import { uniq } from "ramda"
import { trashIdNumToTrashType } from "../mock-data/mock-container"
import { TrashTypes } from "../types/container"

export const getTrashTypeFromContainers = (containers: any[] | undefined): TrashTypes[] => {
  if(!Array.isArray(containers)) return[]
  const res = containers.map(c => 
    trashIdNumToTrashType[c.trash_type.id]
  )
  return uniq(res)
}
