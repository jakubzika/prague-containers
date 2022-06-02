import { mergeDeepRight } from "ramda"
import { baseConfig, Config } from "./base"


export const prodConfig: Config = mergeDeepRight(baseConfig, {
  someServerSecret: 'prod',
}) as Config
