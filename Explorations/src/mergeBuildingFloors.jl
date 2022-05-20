using GeoDataFrames
using NearestNeighbors
using DataFrames
using GeoInterface
using Printf
using Distances
import ArchGDAL as AGDAL
using PyPlot

PyPlot()

include("data-conversion.jl")

begin
    println("Loading data")
    buildingFloors = DataConversion.getBuildingsWithNumberOfFloorsGDAL()
    allBuildings = DataConversion.getCadastralRegistryDataGDAL("BUDOVY_DEF")
    allBuildingShapes = DataConversion.getCadastralRegistryDataGDAL("BUDOVY_P", log=true)
    println("Loading finished")
end
buildingsBallTree = DataConversion.getGDALSearchTree(allBuildings)


createMappingDataFrame() = DataFrame(
    buildingId = String[],
    numberOfFloors = Integer[],
    area = AbstractFloat[],
    heightAdjustedArea = AbstractFloat[],
    numberOfPeople = Integer[],
    wasEmpty = Bool[]
)

emptyMappingRow(building::DataFrameRow) = [
    # building.ID_2,
    # 1,
]

mappingRow(building::DataFrameRow, buildingFloor::DataFrameRow) = buildingFloor

function getBuildingFloorMapping()
    resMapping = Dict()

    # for building in eachrow(allBuildings)
    #     resMapping[building.ID_2] = emptyMappingRow(building)
    # end
    distFn = Haversine()


    for bf in eachrow(buildingFloors[1000:2000,:])
        bfCentroid = AGDAL.centroid(bf.geom)
        point = DataConversion.archGDALPointToStaticArrayPoint(bfCentroid)
        
        nearestBuildingIdxs, distances = knn(buildingsBallTree, point, 10)
        for nearestBuildingIdx in nearestBuildingIdxs
            # nearestBuilding = allBuildings[nearestBuildingIdx,:]
            # AGDAL.ge
            nearestBuildingShape = allBuildings[nearestBuildingIdx, :]
            if (
                # AGDAL.within(nearestBuildingShape.geom, bf.geom)
                # abs(AGDAL.geomarea(nearestBuildingShape.geom) - AGDAL.geomarea(bf.geom)) < 1e-15
                distFn(
                    nearestBuildingShape.geom |> AGDAL.centroid |> coordinates,
                    bf.geom |> AGDAL.centroid |> coordinates
                    ) < 0.1
                )
                resMapping[nearestBuildingShape.ID_2] = mappingRow(nearestBuildingShape, bf)
                break
            end
        end
    end

    return resMapping
end

res = getBuildingFloorMapping()



begin
    distFn = Haversine()
    p₁ = AGDAL.centroid(allBuildingShapes.geom[1]) |> coordinates
    p₂ = AGDAL.centroid(allBuildingShapes.geom[100]) |> coordinates

    distFn(p₁, p₂)
end
# ----

begin
    j = 3:11
    c = plot()
    for i in j
        plot!(allBuildingShapes.geom[i] |> coordinates |> Polygon)
        plot!(allBuildingShapes.geom[i] |> AGDAL.centroid |> coordinates |> Point)
    end 
    c
end

for i in 1:30
    
    α = filter(c -> c[2]!=[],zip(keys(res),values(res)) |> collect);
    fB = α[i][2]
    oB = filter(:ID_2 => ==(α[i][1]),allBuildingShapes)[1,:]    

    @printf("%.10f\n",abs(AGDAL.geomarea(oB.geom) - AGDAL.geomarea(fB.geom)))
    # @printf("%.10f\n",)
end

oB
fB



# ------------------------
