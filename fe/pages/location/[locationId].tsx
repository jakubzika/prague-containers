import { NextPage } from 'next'
import { useTranslation } from 'next-i18next'
import { serverSideTranslations } from 'next-i18next/serverSideTranslations'
import Image from 'next/image'
import Link from 'next/link'
import { useRouter } from 'next/router'
import {
  FirstStackHeading,
  StackItem,
  StackWrapper,
} from '../../components/MainStack'
import Table from '../../components/Table'
import NavLink from '../../components/NavLink'
import { useLocations } from '../../services/apiQueries'
import Disclaimer from '../../components/Disclaimer'

import i18Config from '../../next-i18next.config'

const Search: NextPage = ({}) => {
  const { t } = useTranslation()

  const router = useRouter()
  const { locationId } = router.query

  const { data } = useLocations([locationId as string])

  return (
    <StackWrapper>
      <FirstStackHeading>
        <NavLink href={`/`} className="capitalize">
          {t('prague_containers')}
        </NavLink>
        / {t('location_details')}
      </FirstStackHeading>
      <StackItem>
        {data && (
          <div className="m-4 p-8 pt-10 rnd-container-plastic">
            <Table
              data={data.features[0]}
              columns={['predictedDemand', 'numberOfPeople', 'trashThroughput']}
            />
          </div>
        )}
      </StackItem>
      <StackItem>
        <Disclaimer className=" m-auto lg:w-1/2" />
      </StackItem>
    </StackWrapper>
  )
}

export async function getServerSideProps({ locale }) {
  return {
    props: {
      ...(await serverSideTranslations(
        locale,
        ['common', 'container'],
        i18Config
      )),
    },
  }
}

export default Search
