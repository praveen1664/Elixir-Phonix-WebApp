const colors = require('tailwindcss/colors')

module.exports = {
  mode: 'jit',
  purge: [
    './js/**/*.js',
    '../lib/*_web/**/*.*ex'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        sky: colors.sky,
        teal: colors.teal
      },
      fontFamily: {
        'lora': ['"Lora"', '"Source Sans Pro"', 'Helvetica', 'Verdana', 'sans-serif'],
        'montserrat': ['"Montserrat"', 'Merriweather', 'Georgia', '"Times New Roman"', 'serif']
      }
    }
  },
  variants: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/forms')
  ],
};
