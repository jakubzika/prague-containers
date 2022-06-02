import { useTranslation } from 'next-i18next'
import { FC, useEffect, useState } from 'react'
import { mockLocation } from '../../mock-data/mock-container'
import { ContainerLocationFeature } from '../../types/container'
import Button from '../Button'
import NavLink from '../NavLink'
import Table from '../Table'

type Props = {
  locationData: ContainerLocationFeature
  className?: string
}

const Container: FC<Props> = ({ locationData, className }) => {
  const [isSSR, setIsSSR] = useState(true)

  const { t } = useTranslation()

  useEffect(() => {
    setIsSSR(false)
  }, [])

  return (
    <div
      className={`m-2 bg-white p-6 pt-6 pb-2 shadow-[4px_4px_4px_paper] rnd-container-plastic sm:pt-12 ${className}`}
    >
      {!isSSR && <Table data={locationData} />}
      <div className="overflow-hidden pt-4 pb-4 text-right md:p-8">
        <NavLink href={`/location/${locationData.properties.id}`}>
          {t('more_information')}
        </NavLink>
        {/* <NavLink href="/more-info">{t('show_on_map')}</NavLink> */}
      </div>
    </div>
  )
}

export default Container
