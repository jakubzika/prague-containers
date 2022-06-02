import { FC, forwardRef, HTMLProps } from 'react'
import styled from 'styled-components'
import { Colors, colors } from '../constants/theme'

const sizeClasses = {
  md: 'p-[0.2rem] pl-2 pr-2 min-w-[10rem]',
  lg: 'p-4 pl-10 pr-10 pt-4 pb-4',
}

type Props = {
  $size?: keyof typeof sizeClasses
  color?: Colors
  as?: any
} & HTMLProps<HTMLButtonElement>

const Button = forwardRef<HTMLLinkElement, Props>(
  (
    {
      children,
      onClick,
      $size = 'md' as keyof typeof sizeClasses,
      as,
      color = 'plastic',
      className,
      ...rest
    },
    ref
  ) => (
    <StyledButton
      onClick={onClick}
      as={as}
      color={color}
      ref={ref}
      className={`
        rnd-container-${color} mr-1 ml-1 bg-white text-center duration-150
        ${sizeClasses[$size]} ${className} 
      `}
      {...rest}
    >
      {children}
    </StyledButton>
  )
)

Button.displayName = 'Button'

const StyledButton = styled.button<{
  color: Colors
}>`
  /* box-shadow: 5px 5px 0 ${({ color }) => colors[color]}; */

  &:hover {
    box-shadow: 7px 7px 0 ${({ color }) => colors[color]};
  }
`

export default Button
