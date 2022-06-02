const path = require('path')

module.exports = {
  i18n: {
    defaultLocale: 'cz',
    locales: ['cz', 'en'],
    localePath: path.resolve('./locales'),
    reloadOnPrerender: true,
    // defaultNS: ' common',
    serializeConfig: false,
  },
}
