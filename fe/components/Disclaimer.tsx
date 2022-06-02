import { useTranslation } from 'next-i18next'
import { FC } from 'react'

const Disclaimer: FC<{ className?: string }> = ({ className }) => {
  const { t } = useTranslation()

  return (
    <div className={`space-y-4 p-8 ${className}`}>
      <h2 className="font-bold">{t('disclaimer')}</h2>
      <p className="text-justify">{t('disclaimer_text')}</p>
    </div>
  )
}

export default Disclaimer
