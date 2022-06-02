import { useRouter } from "next/router"
import { append, flatten } from "ramda"
import { TrashTypes } from "../types/container"

export const useQueryTrashTypes = () => {
  const { query: {trashTypes ,onlyPublic} } = useRouter()


  return {
    trashTypes: trashTypes === undefined ? [] : flatten(append(trashTypes as TrashTypes[], [])),
    onlyPublic: onlyPublic === 'true'
  }

}