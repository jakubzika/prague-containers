import { mergeDeepLeft, mergeDeepRight } from "ramda"
import { baseConfig, Config } from "./base"


export const devConfig: Config = mergeDeepLeft(baseConfig, {
  someServerSecret: 'dev',
  public: {
    mockLocation: [1,1]
  }
}) as Config
