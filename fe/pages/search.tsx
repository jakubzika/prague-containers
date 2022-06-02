import { NextPage } from 'next'
import { useTranslation } from 'next-i18next'
import { serverSideTranslations } from 'next-i18next/serverSideTranslations'
import Image from 'next/image'
import Link from 'next/link'
import { useRouter } from 'next/router'
import { useMemo, useState } from 'react'
import Button from '../components/Button'
import ColorFillableContainers from '../components/ColorFillableContainers'
import H1 from '../components/H1'
import { FirstStackHeading } from '../components/MainStack'
import NavLink from '../components/NavLink'
import TrashTypeFilterForm from '../components/trashTypeFilterForm'
import { TrashTypes } from '../types/container'

const Search: NextPage = ({}) => {
  const { t } = useTranslation()

  const [selectedTrashTypes, setSelectedTrashTypes] = useState<TrashTypes[]>([])
  const [onlyPublic, setOnlyPublic] = useState(true)

  const searchUrl = useMemo(
    () => ({
      pathname: '/search/map',
      query: { trashTypes: selectedTrashTypes, onlyPublic },
    }),
    [selectedTrashTypes]
  )

  return (
    <div className="">
      <div className="m-auto mt-20 max-w-[55rem]">
        <div>
          <FirstStackHeading>
            <NavLink className="capitalize" href="/">
              {t('prague_containers')}
            </NavLink>
            /{t('search')}
          </FirstStackHeading>
        </div>
        <div className="m-2 mt-8 max-w-[50rem] p-4 px-8 rnd-container-paper md:mx-auto">
          <div>
            <h2 className="w-full text-center text-2xl font-medium capitalize">
              {t('filters')}
            </h2>
          </div>
          <div className="md:flex md:p-8">
            <div className="md:w-[50%]">
              <TrashTypeFilterForm
                onValuesChange={setSelectedTrashTypes}
                selectedTrashTypes={selectedTrashTypes}
                onOnlyPublicChange={setOnlyPublic}
                onlyPublic={onlyPublic}
              />
            </div>
            <div className="mt-8 mb-8 max-w-[16rem] align-middle md:flex md:w-[50%] md:max-w-none">
              <ColorFillableContainers
                className="m-auto w-full"
                selectedTrashTypes={selectedTrashTypes}
              />
            </div>
          </div>
          <div className="m-2 flex flex-col justify-center space-x-2 sm:flex-row md:m-2 md:space-y-0">
            <Link href="/" passHref>
              <Button as="a" color="electronics" className="hidden sm:block">
                {t('back')}
              </Button>
            </Link>
            <Link href={searchUrl} passHref>
              <Button as="a" color="paper">
                {t('do_search')}
              </Button>
            </Link>
          </div>
        </div>
      </div>
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

export default Search
