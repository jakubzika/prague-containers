using Pipe
using GeoInterface
using OpenStreetMapX
using KissThreading
using StatsBase
using DataFrames
using Plots

include("./nearestContainer.jl")
include("./data-conversion.jl")

selectedTrashTypeId = 6

containers = DataConversion.getContainersGDAL();
buildings = DataConversion.getFilteredBuildingsGDAL(1);
osmMap = get_map_data("map.osm")


filteredContainers =
    @pipe containers |>
    filter(DataConversion.isContainerPublicPredicate, _) |>
    filter(DataConversion.isContainerOfTrashType(selectedTrashTypeId), _)


searchTree = NearestContainer.getContainersBallTree(filteredContainers)

# selectedBuilding = buildings[1,:]
# result = NearestContainer.getNearestContainerForBuildingByMapRoute(
#     searchTree,
#     filteredContainers,
#     selectedBuilding,
#     osmMap,
#     n=5
# );

function parallelFn(buildingId::Integer, n::Integer)
    # println("START Building: $(buildingId) Thread: $(Threads.threadid()) - $(time()%100)")
    if(buildingId % 10 === 0) 
    end
    res =  NearestContainer.getNearestContainerForBuildingByMapRoute(
        searchTree,
        filteredContainers,
        buildings[buildingId,:],
        osmMap,
        n=n
    )
    # println("END   Building: $(buildingId) Thread: $(Threads.threadid()) - $(time()%100)")
    return res
end


buildingsSample = sample(1:nrow(buildings), 400);

reference = tmap(id -> parallelFn(id, 100), buildingsSample, batch_size=5);

function getNumOfDifferencesInResults(res1, res2)
    containerIds1 = [i[1].containerLocation.container_id for i in res1]
    containerIds2 = [i[1].containerLocation.container_id for i in res2]
    mapreduce( x-> x[1]==x[2] ? 1 : 0, +, zip(containerIds1, containerIds2)) / length(res1)
end

nearest = map(reference) do r
    sorted = sort(r, by= x -> x.euclideanDistance)
    findfirst(x -> x.containerLocation.container_id == r[1].containerLocation.container_id ,sorted)
end


buildingsSample[2]

for i in nearest
    print("$(i), ")
end
# [abs(x.mapDistance - x.euclideanDistance) for x in biggestDifference[1]]
Integer(floor(time()%1000))


currentSecond() = Integer(floor(time()%1000))


startSecond = currentSecond()
lastCheck = currentSecond()
count = 0
for (i,c) in enumerate(eachrow(containers))
    if(lastCheck !== currentSecond())
        println("$(currentSecond() - startSecond) - $(i) - ",i/nrow(containers))
        lastCheck = currentSecond()
    end
    for i in eachrow(containers)
        count = count + 1
    end
end
