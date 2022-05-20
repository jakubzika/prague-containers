module NearestContainerForBuildings

using DataFrames
using CSV
using OpenStreetMapX
using KissThreading
using Pipe
using NearestNeighbors

import ArchGDAL as AGDAL
import GeoDataFrames as GDF
import GeoInterface

export computeNearestContainerForBuildings
export computeNearestContainerForTrashType

include("data-conversion.jl")
include("nearestContainer.jl")


createNearestContainerForBuildingsDataFrame() =
    DataFrame(
        buildingId2=String[],
        containerId=String[],
        nearestIdx=Integer[],
        trashTypeId=Integer[],
        haversineDistance=AbstractFloat[],
        mapDistance=AbstractFloat[],
    )

function filterBuildingsByCadastralTeritory(
    buildings::DataFrame,
    cadastralTeritories::DataFrame,
    cadastralTeritoryId::Integer,
)
    teritory = filter(t -> t.KATUZE_KOD == cadastralTeritoryId,cadastralTeritories)[1,:]
    predicate = DataConversion.isInZonePredicate(teritory.geom)
    return filter(c -> predicate(c.geom),buildings)
end

resultToDataFrameRow(
    result::NearestContainer.NearestContainerResult,
    nearestIdx::Integer,
    building::DataFrameRow,
    trashTypeId::Integer
    ) = 
    [
        building.ID_2,
        result.containerLocation.id,
        nearestIdx,
        trashTypeId,
        result.euclideanDistance, # is haversine, just lazy
        result.mapDistance
    ]


function computeNearestContainerForBuildings(
    buildings::DataFrame,
    containerLocations::DataFrame,
    searchTree::BallTree,
    osmMap::MapData,
    trashTypeId::Integer;
    n::Integer = 10,
)
    function parallelFn(building::DataFrameRow, idx::Integer)
        println("$(idx) - $(Threads.threadid()) - $(building.ID_2)")
        NearestContainer.getNearestContainerForBuildingByMapRoute(
            searchTree,
            containerLocations,
            building,
            osmMap,
            n=n
        )
    end

    compResult::Vector{Vector} = tmap(
        v -> parallelFn(v[2], v[1]),
        buildings |> eachrow |> enumerate |> collect
    )
    buildingsDataFrame = createNearestContainerForBuildingsDataFrame()
    
    for (buildingIdx, buildingResults) in enumerate(compResult)
        rows = map(enumerate(buildingResults)) do val
            (nearestIndex, result::NearestContainer.NearestContainerResult) = val
            resultToDataFrameRow(
                result,
                nearestIndex,
                buildings[buildingIdx, :],
                trashTypeId
            )
        end
        for row in rows
            push!(buildingsDataFrame, row)
        end

    end
    buildingsDataFrame
end

getMapData() = get_map_data("./map.osm")

function computeNearestContainerForCadastralZone(
    cadastralZoneId::Integer,
    trashTypeId::Integer;
    osmMap::MapData = getMapData(),
)
    buildings = DataConversion.getFilteredBuildingsInCadastralTeritoryGDAL(trashTypeId, cadastralZoneId)
    containerLocations = DataConversion.getContainerLocationsGDAL()
    filteredContainerLocations = 
        @pipe containerLocations |>
        filter(DataConversion.isContainerLocationIncludesTrashType(trashTypeId),_) |>
        filter(DataConversion.isContainerLocationPublic, _)

    searchTree = NearestContainer.getContainersBallTree(filteredContainerLocations)

    
    df = computeNearestContainerForBuildings(buildings, filteredContainerLocations, searchTree, osmMap, trashTypeId, n=6)
    return df
end

function computeNearestContainerForTrashType(trashTypeId::Integer)
    osmMap = getMapData()
    cadastralZoneIds = DataConversion.getCadastralZoneIds()
    for cadastralZoneId in cadastralZoneIds
        filePath = DataConversion.getPathForNearestContainerForBuilding(trashTypeId, cadastralZoneId)
        println("\nCadastral zone: $(cadastralZoneId)")
        if (isfile(filePath))
            println("$(filePath) already exists, skipping")
            continue
        end
        data = computeNearestContainerForCadastralZone(cadastralZoneId, trashTypeId, osmMap=osmMap)
        CSV.write(filePath, data)
    end
end

end 
