const { i18n } = require('./next-i18next.config')

const rewrites = async () => {
  return [
    {
      source: '/api/v1/:path*',
      destination: 'http://localhost:8080/api/v1/:path*',
    },
  ]
}

const nextConfig = {
  reactStrictMode: true,
  compiler: {
    styledComponents: true,
  },
  experimental: {
    outputStandalone: true,
  },
  i18n,
  rewrites,
}

module.exports = nextConfig
