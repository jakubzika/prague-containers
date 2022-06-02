import config from '../tailwind.config'

export const colors: {
  'colored-glass': string
  'clear-glass': string
  plastic: string
  paper: string
  metal: string
  textiles: string
  electronics: string
  'beverage-carton': string
} = config.theme.extend.colors

export type Colors = keyof typeof colors
