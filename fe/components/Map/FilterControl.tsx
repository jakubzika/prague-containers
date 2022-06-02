import { useTranslation } from 'next-i18next'
import { FC, useEffect, useState } from 'react'
import ReactModal from 'react-modal'
import { TrashTypes } from '../../types/container'
import Button from '../Button'
import TrashTypeFilterForm from '../trashTypeFilterForm'

type Props = {
  trashTypeFilters: TrashTypes[]
  setTrashTypeFilters: (newFilters: TrashTypes[]) => void
  onOnlyPublicChange: (val: boolean) => void
  onlyPublic: boolean
}

const FilterControl: FC<Props> = ({
  trashTypeFilters,
  setTrashTypeFilters,
  onOnlyPublicChange,
  onlyPublic,
}) => {
  const { t } = useTranslation()

  const [modalOpen, setModalOpen] = useState(false)

  const filtersEl = (
    <>
      <h2 className="mb-2 w-full text-xl font-medium capitalize">
        {t('filters')}
      </h2>
      <TrashTypeFilterForm
        onValuesChange={setTrashTypeFilters}
        selectedTrashTypes={trashTypeFilters}
        onOnlyPublicChange={onOnlyPublicChange}
        onlyPublic={onlyPublic}
      />
    </>
  )

  return (
    <>
      <div className="padding-4 absolute bottom-10 left-10 hidden bg-white p-4 rnd-container-paper sm:block">
        {filtersEl}
      </div>
      <div className="padding-4  absolute bottom-10 ml-2 sm:hidden">
        <Button
          $size="lg"
          color="paper"
          className="font-bold capitalize"
          onClick={() => setModalOpen(true)}
        >
          {t('filters')}
        </Button>
        <ReactModal
          onRequestClose={() => setModalOpen(false)}
          overlayClassName={`
            overlayClassName="z-[99] bg-[#00000022] absolute w-screen h-screen top-0 left-0 outline-none"
          `}
          className={`
            absolute
            top-[50%]
            left-[-20%]
            z-[100]
            m-2
            origin-center
            translate-y-[-50%]
            translate-x-[50%]
            bg-white
            p-4
            rnd-container-paper
         `}
          isOpen={modalOpen}
        >
          {filtersEl}
          <Button
            className="m-2"
            color="colored-glass"
            onClick={() => setModalOpen(false)}
          >
            {t('use_filters')}
          </Button>
        </ReactModal>
      </div>
    </>
  )
}

export default FilterControl
