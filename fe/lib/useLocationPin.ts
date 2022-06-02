import { append, difference, uniq } from "ramda"
import useLocalStorageState from "use-local-storage-state"

const useLocationPin = (locationId: string): [boolean, () => void] => {

  const [pinnedLocationIds, setPinnedLocationIds] = useLocalStorageState<
    string[] | undefined
  >('pinnedLocationIds')

  const isPinned = pinnedLocationIds?.includes(locationId) || false
  
  const onPinClick = () => {
    if (!isPinned)
      setPinnedLocationIds(uniq(append(locationId, pinnedLocationIds || [])))
    else setPinnedLocationIds(difference(pinnedLocationIds || [], [locationId]))
  }

  return [isPinned, onPinClick]
}

export default useLocationPin