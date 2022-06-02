import Link from 'next/link'
import { FC, ReactNode } from 'react'

type Props = {
  children: ReactNode
  href: any
  className?: string
}

const NavLink: FC<Props> = ({ children, className, href, ...rest }) => (
  <Link href={href} {...rest}>
    <a
      className={`m-1 text-paper underline duration-75 hover:text-paper/75 sm:m-2 ${className}`}
    >
      {children}
    </a>
  </Link>
)

export default NavLink
