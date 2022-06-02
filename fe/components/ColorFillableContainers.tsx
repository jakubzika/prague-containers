import { FC } from 'react'
import { colors } from '../constants/theme'
import { trashIdToColorId } from '../mock-data/mock-container'
import { TrashTypes } from '../types/container'

type Props = {
  selectedTrashTypes: TrashTypes[]
  className?: string
}

const ColorFillableContainers: FC<Props> = ({
  selectedTrashTypes,
  ...rest
}) => {
  const notSelectedColor = '#00000000'
  const check = (type) =>
    selectedTrashTypes.includes(type)
      ? colors[trashIdToColorId[type]]
      : notSelectedColor

  return (
    <div {...rest}>
      <svg
        // width="509"
        // height="245"
        viewBox="0 0 509 245"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M508 226H1V244H508V226Z"
          fill="black"
          stroke="black"
          strokeWidth="2"
        />

        <path
          d="M166 47H24C11.2975 47 1 57.2974 1 70V224H189V70C189 57.2974 178.703 47 166 47Z"
          fill={check('paper')}
          stroke="black"
          strokeWidth="2"
        />
        <path
          d="M212.341 4H70.3415C57.6389 4 47.3415 14.2974 47.3415 27V223.887H235.341V27C235.341 14.2975 225.044 4 212.341 4Z"
          fill={check('plastic')}
          stroke="black"
          strokeWidth="2"
        />
        <path
          d="M263.276 40.7214H127.403C118.391 40.7214 114.122 40.7338 110.696 41.8471C103.693 44.1222 98.2037 49.612 95.9286 56.614C94.8153 60.0406 94.8029 64.3095 94.8029 73.3214V224.025H295.876V73.3214C295.876 64.3095 295.864 60.0406 294.751 56.614C292.475 49.612 286.986 44.1222 279.984 41.8471C276.557 40.7338 272.288 40.7214 263.276 40.7214Z"
          fill={check('beverage_carton')}
          stroke="black"
          strokeWidth="2"
        />
        <path
          d="M263.4 13H186.6C177.588 13 173.319 13.0123 169.893 14.1257C162.891 16.4008 157.401 21.8905 155.126 28.8926C154.012 32.3192 154 36.588 154 45.6V224H296V45.6C296 36.588 295.988 32.3192 294.874 28.8926C292.599 21.8905 287.109 16.4008 280.107 14.1257C276.681 13.0123 272.412 13 263.4 13Z"
          fill={check('electronic')}
          stroke="black"
          strokeWidth="2"
        />
        <path
          d="M346.4 50.2263H237.502C228.49 50.2263 224.222 50.2387 220.795 51.352C213.793 53.6271 208.303 59.1169 206.028 66.1189C204.915 69.5455 204.902 73.8143 204.902 82.8263V223.887H379V82.8264C379 73.8143 378.987 69.5455 377.874 66.1189C375.599 59.1169 370.109 53.6271 363.107 51.352C359.681 50.2387 355.412 50.2263 346.4 50.2263Z"
          fill={check('colored_glass')}
          stroke="black"
          strokeWidth="2"
        />
        <path
          d="M369.4 50H289.6C280.588 50 276.319 50.0123 272.893 51.1257C265.891 53.4008 260.401 58.8905 258.126 65.8926C257.012 69.3192 257 73.588 257 82.6V224H402V82.6C402 73.588 401.988 69.3192 400.874 65.8926C398.599 58.8905 393.109 53.4008 386.107 51.1257C382.681 50.0123 378.412 50 369.4 50Z"
          fill={check('clear_glass')}
          stroke="black"
          strokeWidth="2"
        />
        <path
          d="M428.4 13H351.6C342.588 13 338.319 13.0123 334.893 14.1257C327.891 16.4008 322.401 21.8905 320.126 28.8926C319.012 32.3192 319 36.588 319 45.6V224H461V45.6C461 36.588 460.988 32.3192 459.874 28.8926C457.599 21.8905 452.109 16.4008 445.107 14.1257C441.681 13.0123 437.412 13 428.4 13Z"
          fill={check('textile')}
          stroke="black"
          strokeWidth="2"
        />
        <path
          d="M475.4 82H398.6C389.588 82 385.319 82.0123 381.893 83.1257C374.891 85.4008 369.401 90.8905 367.126 97.8926C366.012 101.319 366 105.588 366 114.6V224H508V114.6C508 105.588 507.988 101.319 506.874 97.8926C504.599 90.8905 499.109 85.4008 492.107 83.1257C488.681 82.0123 484.412 82 475.4 82Z"
          fill={check('metal')}
          stroke="black"
          strokeWidth="2"
        />
      </svg>
    </div>
  )
}

export default ColorFillableContainers
