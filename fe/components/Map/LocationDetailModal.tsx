import { useTranslation } from 'next-i18next'
import Link from 'next/link'
import React, { FC } from 'react'
import ReactModal from 'react-modal'
import useLocationPin from '../../lib/useLocationPin'
import { useLocations } from '../../services/apiQueries'
import Button from '../Button'
import Table from '../Table'

type Props = {
  locationId: string
  onClose: () => void
}

const LocationDetailModal: FC<Props> = ({ locationId, onClose }) => {
  const { t } = useTranslation()

  const { data } = useLocations(
    locationId === undefined ? undefined : [locationId]
  )
  const location = data?.features[0]

  const [isPinned, togglePinned] = useLocationPin(locationId)

  return (
    <ReactModal
      overlayClassName="z-[99] bg-[#00000022] absolute w-screen h-screen top-0 left-0 outline-none"
      className={`
        absolute
        top-[60%]
        z-[100]
        max-w-[100vw]
        origin-center
        translate-y-[-60%]
        bg-white
        p-8
        rnd-container-plastic
        sm:top-[50%]
        sm:m-2
        sm:max-w-none
        md:right-[50%]
        md:w-auto
        md:translate-x-[50%]`}
      isOpen={true}
      onRequestClose={onClose}
    >
      {location && <Table data={location} />}
      <div
        className={`
        sd:space-y-0
        sd:mt-8
        m-2
        mt-4
        flex
        flex-col
        space-y-4
        text-right
        sm:flex-row
        sm:space-y-0
      `}
      >
        <Button color="electronics" onClick={() => togglePinned()}>
          {isPinned ? t('unpin') : t('pin')}
        </Button>
        <Link href={`/location/${location?.properties.id}`} passHref>
          <Button as="a" color="colored-glass">
            {t('show_details')}
          </Button>
        </Link>
        <Button color="textiles" onClick={onClose}>
          {t('close')}
        </Button>
      </div>
    </ReactModal>
  )
}

export default LocationDetailModal
