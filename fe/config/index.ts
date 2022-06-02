import { baseConfig } from "./base"
import { devConfig } from "./dev"
import { prodConfig } from "./prod"

baseConfig
devConfig
prodConfig

const config = process.env['NODE_ENV'] === 'development' ? devConfig : prodConfig

export default config
export const publicConfig = config.public