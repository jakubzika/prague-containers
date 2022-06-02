import { useTranslation } from 'next-i18next'
import { insert } from 'ramda'
import { FC, useEffect } from 'react'
import useLocalStorageState from 'use-local-storage-state'
import { useLocations } from '../services/apiQueries'
import Container from './Container/Container'
import Disclaimer from './Disclaimer'
import { StackContent, StackHeading } from './MainStack'

type Props = {}

const PinnedLocations: FC<Props> = () => {
  const { t } = useTranslation('common')

  const [pinnedLocationIds, setPinnedLocationIds] = useLocalStorageState<
    string[] | undefined
  >('pinnedLocationIds')

  const { data } = useLocations(pinnedLocationIds)

  const containers = data?.features.map((val) => (
    <Container key={val.properties.id} locationData={val} />
  ))

  const disclaimer = <Disclaimer />

  const elements = insert(1, disclaimer, containers || [])

  const leftColContainers = elements.filter((val, idx) => idx % 2 == 0)
  const rightColContainers = elements.filter((val, idx) => idx % 2 == 1)

  return (
    <>
      {data && (
        <>
          <StackHeading>{t('pinned_locations')}</StackHeading>
          <StackContent className="flex-row space-y-8 md:flex lg:space-y-0">
            <div className="mx-2 space-y-8 sm:m-1 md:m-auto md:w-[70%] lg:w-[48%]">
              {leftColContainers}
            </div>
            <div className="m-1 mx-2 space-y-8 md:m-auto md:w-[70%] lg:w-[48%]">
              {rightColContainers}
            </div>
          </StackContent>
        </>
      )}
    </>
  )
}

export default PinnedLocations
