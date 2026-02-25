/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "#09090B",
        cyan: {
          400: "#22D3EE",
        },
        green: {
          400: "#4ADE80",
        },
        foreground: "#FFFFFF",
        muted: "#A1A1AA"
      },
      fontFamily: {
        sans: ['Geist', 'Inter', 'sans-serif'],
        mono: ['JetBrains Mono', 'Fira Code', 'monospace']
      },
      animation: {
        'typing': 'typing 2s steps(40, end)',
        'blink': 'blink-caret 1s step-end infinite',
      },
      keyframes: {
        typing: {
          from: { width: '0' },
          to: { width: '100%' },
        },
        'blink-caret': {
          'from, to': { borderColor: 'transparent' },
          '50%': { borderColor: '#4ADE80' },
        }
      }
    },
  },
  plugins: [],
}
