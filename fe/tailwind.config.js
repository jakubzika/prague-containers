const plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        'colored-glass': '#009D19',
        'clear-glass': '#FCFFE8',
        plastic: '#FDCD21',
        paper: '#0031DF',
        metal: '#C4C4C4',
        textiles: '#D02500',
        electronics: '#F71E52',
        'beverage-carton': '#FB993E',
      },
    },
  },
  plugins: [
    plugin(function ({ matchUtilities, theme }) {
      matchUtilities(
        {
          'rnd-container': (value) => {
            return {
              borderRadius: '24px 24px 24px 0',
              border: '2px solid black',
              // padding: '2rem',
              boxShadow: '5px 5px 0 ' + value,
            }
          },
        },
        { values: theme('colors') }
      )
    }),
  ],
}
