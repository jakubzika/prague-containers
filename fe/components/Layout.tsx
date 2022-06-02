import { useTranslation } from 'next-i18next'
import Head from 'next/head'
import Image from 'next/image'
import Link from 'next/link'
import { FC, ReactElement } from 'react'
import Footer from './Footer'

type Props = {
  children: ReactElement
}

const Layout: FC<Props> = ({ children }) => {
  const { t } = useTranslation()

  return (
    <div className="">
      <Head>
        <title>{t('title')}</title>
      </Head>
      <div>
        <div>
          {/* ugly hack to precompute all variants of rnd-container */}
          <div className="hidden rnd-container-colored-glass" />
          <div className="hidden rnd-container-clear-glass" />
          <div className="hidden rnd-container-plastic" />
          <div className="hidden rnd-container-paper" />
          <div className="hidden rnd-container-metal" />
          <div className="hidden rnd-container-textiles" />
          <div className="hidden rnd-container-electronics" />
          <div className="hidden rnd-container-beverage-carton" />
        </div>
        <div className="absolute right-0 top-0 z-[50] mt-6 mr-6 w-36 md:w-40">
          <Link href="/" passHref>
            <a>
              <Image
                width="100%"
                height="50%"
                layout="responsive"
                objectFit="contain"
                src="/img/logo/Logo.svg"
                alt="logo"
              />
            </a>
          </Link>
        </div>
      </div>
      <div className="min-h-[80vh]">{children}</div>
      <Footer />
    </div>
  )
}

export default Layout
