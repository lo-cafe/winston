import { useState, useEffect, useRef, useCallback } from "react"

function useQueryWatcher(query, transformer, transformerSetState, initialState = []) {
  const [currentValues, setCurrentValues] = useState(initialState)
  const [lastAddedValues, setLastAddedValues] = useState([])
  const [lastRemovedValues, setLastRemovedValues] = useState([])
  const [isWatching, setIsWatching] = useState(false)
  const intervalRef = useRef(null)

  const checkQuery = () => {
    const queryResult = document.querySelectorAll(query)
    const values = Array.from(queryResult)
    const newValues = transformer ? values.map(transformer) : values
    const addedValues = transformerSetState || !newValues?.filter
      ? null
      : newValues.filter((val) => (!currentValues?.find ? true : !currentValues.find(x => JSON.stringify(x) == JSON.stringify(val))))
    const removedValues = transformerSetState || !currentValues?.filter
      ? null
      : currentValues.filter((val) => (!newValues?.find ? true : !newValues.find(x => JSON.stringify(x) == JSON.stringify(val))))

    const transformedState = transformerSetState ? transformerSetState(newValues) : newValues

    
    if (JSON.stringify(currentValues) != JSON.stringify(transformedState)) {
      setCurrentValues(transformedState)
      setLastAddedValues(addedValues)
      setLastRemovedValues(removedValues)
    }
  }

  const startWatching = () => {
    stopWatching()
    intervalRef.current = setInterval(checkQuery, 200)
    checkQuery()
  }

  const stopWatching = () => {
    if (intervalRef.current) {
      clearInterval(intervalRef.current)
    }
  }

  useEffect(() => {
  }, [lastAddedValues])

  useEffect(() => {
    if (isWatching) {
    startWatching()
    } else {
      stopWatching()
    }
  }, [currentValues, isWatching])

  useEffect(() => stopWatching, [])

  return [currentValues, lastAddedValues, lastRemovedValues, setIsWatching]
}

export default useQueryWatcher
