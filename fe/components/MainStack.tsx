import { FC, ReactNode } from 'react'
import styled from 'styled-components'
import H1 from './H1'

export const StackWrapper = styled.div.attrs({
  className: 'm-auto sm:mt-16 max-w-[70rem] space-y-4 sm:p-2',
})``

export const StackContent: FC<{
  children: ReactNode
  className?: string
}> = ({ children, className }) => (
  <div className={`ml-0 sm:ml-4 ${className}`}>{children}</div>
)

export const StackItem = styled.div``

export const StackHeading: FC<{ children: ReactNode; className?: string }> = ({
  children,
  className,
}) => <H1 className={`text-[1.2rem] ${className}`}>{children}</H1>

export const FirstStackHeading = ({ children }: { children: ReactNode }) => (
  <div className="flex h-[7rem] w-[45%] sm:h-max md:w-full">
    <StackHeading className="mt-auto mb-auto inline-block">
      {children}
    </StackHeading>
  </div>
)
