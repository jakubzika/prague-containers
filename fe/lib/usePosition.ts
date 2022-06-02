import {useState, useEffect} from 'react'

export const usePosition = () => {
  const [position, setPosition] = 
    useState<{latitude: number | undefined, longitude: number | undefined}>({
      latitude: undefined,
      longitude: undefined
    })
  const [error, setError] = useState<string | undefined>()
  
  const onChange = ({coords}) => {
    setPosition({
      latitude: coords.latitude,
      longitude: coords.longitude,
    })
  }  

  const onError = (error) => {
    setError(error.message)
  }

  useEffect(() => {
    const geo = navigator.geolocation
    if (!geo) {
      setError('Geolocation is not supported')
      return
    } 
    const watcher = geo.watchPosition(onChange, onError)
    return () => geo.clearWatch(watcher)
  }, [])

  return {...position, error}
}