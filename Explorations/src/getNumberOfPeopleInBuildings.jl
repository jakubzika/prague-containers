import GeoDataFrames as GDF

include("data-conversion.jl")

# buildingFloors = DataConversion.getBuildingsWithNumberOfFloorsGDAL()
getDetailedBuildings() = DataFrame()

populationCountsPerCadastralZone = DataConversion.getPopulationCountPerCadastralZone()
cadastralZones = DataConversion.getCadastralZonesGDAL()

tmp = DataConversion.getFilteredBuildingsGDAL(6)
DataConversion.trashTypeIdToDescription[6]


buildingDefinitions = DataConversion.getCadastralRegistryDataGDAL("BUDOVY_DEF")

GDF.write("./tmp/reduced-building-floors.geojson", buildingFloors[1:10_000,:])
