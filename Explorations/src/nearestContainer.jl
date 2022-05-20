module NearestContainer

using OpenStreetMapX
using DataFrames
using GeoInterface
using Pipe
using GeoInterface
using Graphs
using NearestNeighbors
using Distances
import ArchGDAL as AGDAL
import GeoDataFrames as GDF
using StaticArrays

export getContainersBallTree
export getNearestContainerForBuildingByMapRoute
export NearestContainerResult

archGDALPointToStaticArrayPoint(point)::SVector{2, Float32} =
    @pipe point |> 
    coordinates |>
    reverse |>
    SVector(_[1], _[2])

archGDALPointToOSMMapNode(osmMap::MapData, point) = 
    @pipe point |> 
    coordinates |>
    reverse |>
    point_to_nodes(LLA(_[1], _[2]), osmMap)


function getNearestNContainers(searchTree::BallTree, containers::DataFrame, agdalPoint, n::Integer)::Tuple{DataFrame, Vector{Number}}
    spoint = archGDALPointToStaticArrayPoint(agdalPoint)
    prefilteredContainersIdx, distances = knn(searchTree, spoint, n)
    prefilteredContainers = containers[prefilteredContainersIdx, :]
    return (prefilteredContainers, distances)
end

struct NearestContainerResult
    mapDistance::Number
    euclideanDistance::Number
    mapNodes::Vector{Number}
    containerLocation::DataFrameRow
end

function getNearestContainerForBuildingByMapRoute(
    containersTree::BallTree,
    containerLocations::DataFrame,
    building::DataFrameRow,
    osmMap::MapData;
    n::Integer = 10
)::Vector{NearestContainerResult}
    # buildingStaticArrayPoint = archGDALPointToStaticArrayPoint(building.geom)
    
    prefilteredContainers, euclideanDistances = getNearestNContainers(
        containersTree,
        containerLocations,
        building.geom,
        n
    )
    
    buildingMapNode = archGDALPointToOSMMapNode(osmMap, building.geom)

    buildingContainerRouteResults = map(eachrow(prefilteredContainers)) do container
        containerMapNode = archGDALPointToOSMMapNode(osmMap, container.geom)
        shortest_route(osmMap, buildingMapNode, containerMapNode) # (nodes, distance, speed)
    end

    result = map(enumerate(eachrow(prefilteredContainers))) do (index, container)
        NearestContainerResult(
            buildingContainerRouteResults[index][2],
            euclideanDistances[index],
            buildingContainerRouteResults[index][1],
            container
        )
    end

    resultSorted = sort(result, by = r -> r.mapDistance)

    return resultSorted
end

function getContainersBallTree(containerLocations::DataFrame)
    containersPoints = 
        @pipe containerLocations |>
        _.geom |>
       map(archGDALPointToStaticArrayPoint, _)
    return BallTree(containersPoints, Haversine())
end


end

