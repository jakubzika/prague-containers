import type { NextPage } from 'next'
import Head from 'next/head'
import Image from 'next/image'
import Link from 'next/link'
import React, { useEffect } from 'react'
import styled from 'styled-components'
import Button from '../components/Button'
import Container from '../components/Container/Container'
import { serverSideTranslations } from 'next-i18next/serverSideTranslations'
import H1 from '../components/H1'
import {
  FirstStackHeading,
  StackContent,
  StackHeading,
  StackItem,
  StackWrapper,
} from '../components/MainStack'
import NoSSR from 'react-no-ssr'

import styles from '../styles/Home.module.css'
import { useTranslation } from 'next-i18next'
import About from '../components/About'
import { API } from '../services/api'
import PinnedLocations from '../components/PinnedLocations'

const Home: NextPage = () => {
  const { t } = useTranslation('common')

  return (
    <StackWrapper>
      <StackItem>
        <FirstStackHeading>{t('search')}</FirstStackHeading>
        <StackContent>
          <div className="flex flex-col space-y-4 p-4 sm:flex-row sm:space-y-0 sm:bg-transparent">
            <Link href="/search" passHref>
              <Button as="a" className="md:w-full" $size={'lg'} color="paper">
                ⌕ {t('search_for_containers')}
              </Button>
            </Link>
            <Link href="/all/map" passHref>
              <Button
                as="a"
                className="md:w-full"
                $size={'lg'}
                color="colored-glass"
              >
                ⌕ {t('show_all_containers')}
              </Button>
            </Link>
          </div>
        </StackContent>
      </StackItem>
      <StackItem className="pb-12">
        <NoSSR>
          <PinnedLocations />
        </NoSSR>
      </StackItem>
      <StackItem>
        {/* <StackHeading>{t('about')}</StackHeading> */}
        <StackContent>
          <About />
        </StackContent>
      </StackItem>
    </StackWrapper>
  )
}

export async function getStaticProps({ locale }) {
  return {
    props: {
      ...(await serverSideTranslations(locale, ['common', 'container'])),
    },
  }
}

export default Home
