import { FC, ReactNode } from 'react'

type Props = {
  children: ReactNode
  className?: string
}

const arrowCharacter = '→'

const H1: FC<Props> = ({ children, className }) => (
  <h1 className={`text-lg ${className}`}>
    {arrowCharacter}
    <span className="ml-0 inline-block pl-0 text-left">{children}</span>
  </h1>
)

export default H1
