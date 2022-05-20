using DataFrames
import GeoDataFrames as GDF

using JSON3

include("nearestContainerForBuildings.jl")
include("data-conversion.jl")

res = DataConversion.getNearestContainerForBuildings(6)
containerLocations = DataConversion.getPublicContainerLocationsByTrashTypeGDAL(6)

groups = groupby(res,:containerId)
groups[keys(groups)[1]]

combined = combine(groups, nrow)
totalRes = innerjoin(containerLocations, combined, on = :id => :containerId)

DataConversion.convertDataFrameDictToJSONColumn!(totalRes,:containers)

totalRes.containers

GDF.write("downloaded-data/containers-geojson/container-location-building-density.geojson", totalRes)

buildingFloors = DataConversion.getBuildingsWithNumberOfFloorsGDAL()


names(buildingFloors)
sort(unique(buildingFloors.POČET_POD))