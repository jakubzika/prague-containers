import { useTranslation } from 'next-i18next'
import { FC, forwardRef, HTMLProps, useEffect, useState } from 'react'
import { useForm } from 'react-hook-form'
import { trashTypes } from '../mock-data/mock-container'
import { TrashTypes } from '../types/container'

type CheckboxLineProps = {
  trashType?: string
} & HTMLProps<HTMLInputElement>

const CheckboxLine = ({
  children,
  trashType = 'all',
  id,
  ...rest
}: CheckboxLineProps) => {
  return (
    <div className="m-0 ml-2">
      <input className={'p-2 md:p-4'} type="checkbox" id={id} {...rest} />
      <label className="p-1 pl-2" htmlFor={id}>
        {children}
      </label>
    </div>
  )
}

type Props = {
  onValuesChange: (vals: TrashTypes[]) => void
  selectedTrashTypes: TrashTypes[]
  onOnlyPublicChange: (val: boolean) => void
  onlyPublic: boolean
}

const TrashTypeFilterForm: FC<Props> = ({
  onValuesChange,
  selectedTrashTypes,
  onOnlyPublicChange,
  onlyPublic,
}) => {
  const { t } = useTranslation()

  const onChange = (evt) => {
    const trashType = evt.target.dataset.trashtype
    const checked = evt.target.checked

    if (trashType === 'all') {
      if (checked) onValuesChange([])
      // else onValuesChange([])
    } else {
      if (checked) onValuesChange([...selectedTrashTypes, trashType])
      else onValuesChange(selectedTrashTypes.filter((t) => t != trashType))
    }
  }

  const onAccessibilityChange = (evt) => onOnlyPublicChange(evt.target.checked)

  return (
    <div>
      <form>
        <div className="space-y-2 md:space-y-1">
          <CheckboxLine
            checked={selectedTrashTypes.length === 0}
            data-trashtype={'all'}
            id={'trash-type-all'}
            onChange={onChange}
          >
            {t('all_locations')}
          </CheckboxLine>
          <h2 className="font-medium">{t('must_include')}</h2>
          {trashTypes.map((trashType) => (
            <CheckboxLine
              onChange={onChange}
              key={trashType}
              checked={selectedTrashTypes.includes(trashType)}
              id={`trash-type-${trashType}`}
              data-trashtype={trashType}
            >
              {t(`trash_type.${trashType}`)}
            </CheckboxLine>
          ))}
        </div>
        <hr className="m-2" />
        <h2 className="font-medium">{t('accessibility')}</h2>
        <CheckboxLine
          id="accessibility"
          className=""
          checked={onlyPublic}
          onChange={onAccessibilityChange}
        >
          {t('only_public_locations')}
        </CheckboxLine>
      </form>
    </div>
  )
}

export default TrashTypeFilterForm
