import { TFunction, useTranslation } from 'next-i18next'
import { FC, ReactNode } from 'react'
import styled from 'styled-components'
import tw from 'twin.macro'
import { trashIdNumToTrashType } from '../mock-data/mock-container'
import {
  LocationData,
  ContainerData,
  LocationServer,
  ContainerLocationFeature,
} from '../types/container'

const TableValue: FC<{ children: ReactNode }> = ({ children }) => (
  <div className="inline-block">{children}</div>
)

const columnAccessors = {
  predictedDemand: (
    location: ContainerLocationFeature,
    trashTypeId: number
  ) => (
    <TableValue>
      {location.properties.trash_type_info[trashTypeId].demand}
    </TableValue>
  ),
  numberOfPeople: (location: ContainerLocationFeature, trashTypeId: number) => (
    <TableValue>
      {Math.round(
        location.properties.trash_type_info[trashTypeId].population_sum
      )}
    </TableValue>
  ),
  trashThroughput: (
    location: ContainerLocationFeature,
    trashTypeId: number,
    t: any
  ) => (
    <TableValue>
      {t('trash_throughput', {
        throughput: Math.round(
          location.properties.trash_type_info[trashTypeId].location_throughput
        ),
      })}
    </TableValue>
  ),
}

const defaultColumns: (keyof typeof columnAccessors)[] = [
  'predictedDemand',
  'numberOfPeople',
]

type Props = {
  columns?: string[]
  data: ContainerLocationFeature
}

const DataRow = styled.tr.attrs({
  className: 'border-b-[1.5px] border-gray-100 leading-[3rem]',
})``

const Table: FC<Props> = ({ data, columns = defaultColumns }) => {
  const { t } = useTranslation([''])

  const { properties } = data

  if (data.properties.accessibility_id == 2) {
    columns = []
  }

  return (
    <div>
      <h2 className="mb-6 block w-full border-b-[1.5px] border-gray-200 pb-2 text-center font-bold sm:hidden">
        {properties.name}
      </h2>
      <div className="xs:overflow-x-auto overflow-y-visible overflow-x-scroll">
        <table className="sm:p xs:min-w-0 mt-8 table w-full min-w-[35rem] sm:min-w-0">
          <tr className="relative top-[-12px]">
            <th className="text-light align-text-top-top table-cell w-10 md:visible">
              <span className="hidden pb-8 sm:block">{properties.name}</span>
            </th>
            {columns.map((column) => (
              <th
                className="table-cell pb-6 text-center font-light"
                key={column}
              >
                <div className="relative inline-block w-16 rotate-[30deg]">
                  {t(`container_keys.${column}`)}
                </div>
              </th>
            ))}
          </tr>
          {Object.keys(data.properties.trash_type_info).map((trashTypeId) => (
            <tr key={trashTypeId} className="border-b-[1px] leading-8">
              <td className="text-left font-normal">
                {t(`trash_type.${trashIdNumToTrashType[trashTypeId]}`)}
              </td>
              {columns.map((colName) => (
                <td key={colName} className="text-center">
                  {columnAccessors[colName](data, trashTypeId, t)}
                </td>
              ))}
            </tr>
          ))}
        </table>
      </div>
    </div>
  )
}

export default Table
