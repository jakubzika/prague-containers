import { colors } from "../../constants/theme"
import { trashIdToColorId } from "../../mock-data/mock-container"
import { TrashTypes } from "../../types/container"


const LocationMarkerHTML = (trashTypes: TrashTypes[], onClick: () => void)  => {
  const notSelectedColor = 'transparent'
  
  const check = (type) =>
  trashTypes.includes(type)
    ? colors[trashIdToColorId[type]]
    : notSelectedColor

  const visCheck = (type) => trashTypes.includes(type)
  const el = document.createElement('div')

  el.innerHTML = `
    <svg
        width="50"
        height="100"
        viewBox="0 0 44 29"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M43 22.75H1V23.65H43V22.75Z"
          fill="black"
          stroke="black"
          strokeWidth="2"
        />
        ${visCheck('textile') && 
          `<path
            d="M11.75 1.84995H2C1.11634 1.84995 0.4 2.5663 0.4 3.44995V22.8H13.35V3.44995C13.35 2.5663 12.6337 1.84995 11.75 1.84995Z"
            fill="${check('textile')}"
            stroke="black"
            strokeWidth="0.8"
          />`
        }
        ${visCheck('plastic') && 
          `<path
            d="M18.625 1.84995H7.5C6.61634 1.84995 5.9 2.5663 5.9 3.44995V22.8H20.225V3.44995C20.225 2.5663 19.5087 1.84995 18.625 1.84995Z"
            fill="${check('plastic')}"
            stroke="black"
            strokeWidth="0.8"
          />`
        }
        ${visCheck('beverage_carton') && 
          `<path
            d="M22.4871 4.39658H12.8053C12.0297 4.39658 11.7367 4.40152 11.5109 4.47489C11.0238 4.63316 10.6419 5.01505 10.4836 5.50215C10.4103 5.72798 10.4053 6.02094 10.4053 6.79658V22.2404H24.8871V6.79659C24.8871 6.02094 24.8822 5.72798 24.8088 5.50215C24.6505 5.01505 24.2686 4.63316 23.7815 4.47489C23.5557 4.40152 23.2628 4.39658 22.4871 4.39658Z"
            fill="${check('beverage_carton')}"
            stroke="black"
            strokeWidth="0.8"
          />
        `}
        ${visCheck('electronic') && 
          `<path
            d="M20.95 0.4H16.55C15.7744 0.4 15.4814 0.404935 15.2556 0.47831C14.7685 0.636578 14.3866 1.01847 14.2283 1.50557C14.1549 1.7314 14.15 2.02435 14.15 2.8V22.8H23.35V2.8C23.35 2.02435 23.3451 1.7314 23.2717 1.50557C23.1134 1.01847 22.7315 0.636578 22.2444 0.47831C22.0186 0.404935 21.7256 0.4 20.95 0.4Z"
            fill="${check('electronic')}"
            stroke="black"
            strokeWidth="0.8"
          />
        `}
        ${visCheck('colored_glass') && 
          `<path
            d="M29.7 3.2999H21.55C20.7744 3.2999 20.4814 3.30484 20.2556 3.37821C19.7685 3.53648 19.3866 3.91837 19.2283 4.40548C19.1549 4.6313 19.15 4.92426 19.15 5.6999V22.7999H32.1V5.6999C32.1 4.92426 32.0951 4.6313 32.0217 4.40548C31.8634 3.91837 31.4815 3.53648 30.9944 3.37821C30.7686 3.30484 30.4756 3.2999 29.7 3.2999Z"
            fill="${check('colored_glass')}"
            stroke="black"
            strokeWidth="0.8"
          />
        `}
        ${visCheck('clear_glass') && 
          `<path
            d="M33.45 3.2999H26.55C25.7744 3.2999 25.4814 3.30484 25.2556 3.37821C24.7685 3.53648 24.3866 3.91837 24.2283 4.40548C24.1549 4.6313 24.15 4.92426 24.15 5.6999V22.7999H35.85V5.6999C35.85 4.92426 35.8451 4.6313 35.7717 4.40548C35.6134 3.91837 35.2315 3.53648 34.7444 3.37821C34.5186 3.30484 34.2256 3.2999 33.45 3.2999Z"
            fill="${check('clear_glass')}"
            stroke="black"
            strokeWidth="0.8"
          />
        `}
        ${visCheck('paper') && 
          `<path
            d="M37.4129 1.60752H32.1765C31.4009 1.60752 31.1079 1.61245 30.8821 1.68583C30.395 1.8441 30.0131 2.22599 29.8548 2.71309C29.7815 2.93892 29.7765 3.23187 29.7765 4.00752V22.2379H39.8129V4.00752C39.8129 3.23187 39.808 2.93892 39.7346 2.71309C39.5763 2.22599 39.1944 1.8441 38.7073 1.68583C38.4815 1.61245 38.1885 1.60752 37.4129 1.60752Z"
            fill="${check('paper')}"
            stroke="black"
            strokeWidth="0.8"
          />
        `}
        ${visCheck('metal') && 
          `<path
            d="M40.95 8.5499H35.7136C34.938 8.5499 34.645 8.55484 34.4192 8.62821C33.9321 8.78648 33.5502 9.16837 33.3919 9.65548C33.3186 9.8813 33.3136 10.1743 33.3136 10.9499V22.2381H43.35V10.9499C43.35 10.1743 43.3451 9.8813 43.2717 9.65548C43.1134 9.16837 42.7315 8.78648 42.2444 8.62821C42.0186 8.55484 41.7256 8.5499 40.95 8.5499Z"
            fill="${check('metal')}"
            stroke="black"
            strokeWidth="0.8"
          />
        `}
        <path d="M22.6248 29L16.9998 23.2H27.6248L22.6248 29Z" fill="black" />
      </svg>
  `
  el.style.cursor = 'pointer'
  el.onclick = onClick

  return el
}
export default LocationMarkerHTML