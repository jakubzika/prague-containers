import { Location } from "../types/container"


export type Config = {
  someServerSecret: string,
  public: {
    mapbox: {
      token: string | undefined
    },
    mockLocation?: Location
    apiBaseV1: string,
  }
}

export const baseConfig: Config = {
  someServerSecret: 'yes',
  public: {
    mapbox: {
      token: 'pk.eyJ1Ijoiem9sYTUyIiwiYSI6ImNrcDFoejlsMzB5OGMyb256MmUwdGtsYjMifQ.7Hzrth2cebL7jQ1HksHE7w'
    },
    apiBaseV1: '/api/v1'
  }
}
