import Image from 'next/image'
import { FC } from 'react'

type Props = {}

const Footer: FC<Props> = ({}) => {
  return (
    <div className="bottom-0 mt-20 min-h-[6rem]  bg-gray-100 px-20">
      <div className="my-2 flex">
        <div className="w-[10rem]">
          <Image
            src="/img/logo/Logo-hollow.svg"
            width="100%"
            height="100%"
            layout="responsive"
            alt="Hollow logo"
          />
        </div>
      </div>
    </div>
  )
}

export default Footer
