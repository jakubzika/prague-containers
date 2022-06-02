import { NextPage } from 'next'
import { useTranslation } from 'next-i18next'
import { serverSideTranslations } from 'next-i18next/serverSideTranslations'
import ContainersMap from '../../components/Map/ContainersMap'
import { StackHeading } from '../../components/MainStack'
import NavLink from '../../components/NavLink'
import { useAllLocations, useNearestLocations } from '../../services/apiQueries'
import { useEffect } from 'react'
import NoSSR from 'react-no-ssr'

const NoSSrSearchMap = () => {
  const { data: locations } = useAllLocations()

  return <ContainersMap locations={locations} showFilterWindow={true} />
}

const MapAll: NextPage = () => {
  const { t } = useTranslation()

  return (
    <div className="mt-2 space-y-4 md:mt-6">
      <StackHeading>
        <div className="flex flex-col md:flex-row">
          <div>
            <NavLink className="capitalize" href="/">
              {t('prague_containers')}
            </NavLink>
            /
          </div>
          <div className="capitalize">{t('container_map')}</div>
        </div>
      </StackHeading>
      <NoSSR>
        <NoSSrSearchMap />
      </NoSSR>
    </div>
  )
}

export async function getStaticProps({ locale }) {
  return {
    props: {
      ...(await serverSideTranslations(locale, ['common', 'container'])),
    },
  }
}

export default MapAll
