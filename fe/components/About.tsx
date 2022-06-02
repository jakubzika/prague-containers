import { useTranslation } from 'next-i18next'
import Image from 'next/image'
import { FC } from 'react'
import { StackHeading } from './MainStack'

type Props = {}

const About: FC<Props> = () => {
  const { t } = useTranslation('common')

  return (
    <div className="flex">
      <div
        className={`
          space-y-8
          px-4
          sm:p-12

          lg:w-[50%]
          lg:pr-0
      `}
      >
        <StackHeading>{t('about')}</StackHeading>
        <p className="text-justify">{t('about_text')}</p>
      </div>
      <div
        className={`
          m-8
          hidden
          overflow-hidden
          rounded-tl-3xl
          rounded-br-3xl
          rounded-tr-3xl
          lg:block
          lg:w-[50%]
        `}
      >
        <Image
          src="/img/all-containers.png"
          alt="all containers"
          layout="intrinsic"
          width={600}
          height={500}
          className="overflow-hidden rounded-tl-3xl rounded-br-3xl rounded-tr-3xl"
        />
      </div>
    </div>
  )
}

export default About
