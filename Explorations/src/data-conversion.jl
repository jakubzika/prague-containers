module DataConversion

export containerMeasurementsJSONToDataFrame
export getMeasurementDataForRow
export getContainerMeasurementsLocation
export parseContainerMeasurement!
export containersJSONToDataFrame
export loadContainers
export loadMeasuredContainers
export getContainerMeasurements
export loadLandRegistryGeoJSONData
export getContainersGDAL, getFilteredBuildingsGDAL
export getContainerLocationsGDAL, isContainerLocationIncludesTrashType, isContainerLocationPublic
export getCadastralTeritories
export isInZonePredicate
export getFilteredBuildingsInCadastralTeritoryGDAL
export getCadastralZoneIds
export getCadastralZoneGDAL
export getNearestContainerForBuildings
export getPublicContainerLocationsByTrashTypeGDAL
export convertDataFrameDictToJSONColumn!
export getContainerLocationsRawGDAL
export getCadastralRegistryDataGDAL
export trashTypeIdToDescription
export getGDALSearchTree
export archGDALPointToStaticArrayPoint
export trashTypeIdToColor
export getLocationTrashTypes
export getServerEnhancedContainerLocationsGDAL, getServerEnhancedContainerLocationsString

using DataFrames, TimeZones, CSV, Dates, GeoJSON, Pipe
using GeoInterface, LibGEOS
using StaticArrays
using Distances
using NearestNeighbors
import ArchGDAL as AGDAL
import GeoDataFrames as GDF
import JSON3

const CONTAINER_MEASUREMENT_DATA_VERSION = "01"

Maybe{T} = Union{T,Nothing} where {T}

trashTypeIdToDescription = Dict(
    0 => "neznámý",
    1 => "Barevné sklo",
    2 => "Elektrozařízení",
    3 => "Kovy",
    4 => "Nápojové kartóny",
    5 => "Papír",
    6 => "Plast",
    7 => "Čiré sklo",
    8 => "Textil",
)




trashTypeIdToColor = Dict(
    0 => "#000000",
    1 => "#009D19",
    2 => "#F71E52",
    3 => "#C4C4C4",
    4 => "#FB993E",
    5 => "#0031DF",
    6 => "#FDCD21",
    7 => "#FCFFE8",
    8 => "#D02500",
)

createContainerMeasurementDataFrame() =
    DataFrame(
        id=Union{String,Missing}[],
        firealarm=Union{Int64,Missing}[],
        prediction_utc=Union{String,Missing}[],
        percent_calculated=Union{Int64,Missing}[],
        sensor_code=Union{String,Missing}[],
        measured_at_utc=Union{String,Missing}[],
        updated_at=Union{Int64,Missing}[],
        upturned=Union{Int64,Missing}[],
        temperature=Union{Int64,Missing}[],
        battery_status=Union{Float64,Missing}[],
    )

getMeasurementDataForRow(row::Any) =
    map(key -> row[key] !== nothing ? row[key] : missing, createContainerMeasurementDataFrame() |> names)

function containerMeasurementsJSONToDataFrame(measurements::Vector{Any})::DataFrame
    df = createContainerMeasurementDataFrame()
    for (index, m) in enumerate(measurements)
        row = getMeasurementDataForRow(m)
        push!(df, row)
    end

    return df
end

getContainerMeasurementsLocation(containerId::String) =
    "./container-measurements/$(CONTAINER_MEASUREMENT_DATA_VERSION)/$(containerId).csv"

getContainerMeasurements(containerId::String)::DataFrame =
    getContainerMeasurementsLocation(containerId) |> CSV.File |> DataFrame |> parseContainerMeasurements!

function parseContainerMeasurements!(measurements::DataFrame)
    measurements.measured_at = map(c -> DateTime(ZonedDateTime(c)), measurements.measured_at_utc)
    return measurements
end

function createContainerDataFrame()
    DataFrame(
        container_id=Union{String,Missing}[],
        lat=Union{Number,Missing}[],
        lng=Union{Number,Missing}[],
        district=Union{String,Missing}[],
        name=Union{String,Missing}[],
        location_id=Union{String,Missing}[],
        knsko_id=Union{Int64,Missing}[],
        trash_type_id=Union{Int64,Missing}[],
        trash_type_description=Union{String,Missing}[],
        container_type=Union{String,Missing}[],
        cleaning_frequency_duration=Union{String,Missing}[],
        cleaning_frequency_frequency=Union{Int64,Missing}[],
        cleaning_frequency_id=Union{Int64,Missing}[],
        sensor_supplier=Union{String,Missing}[],
        sensor_code=Union{String,Missing}[],
        sensor_id=Union{String,Missing}[],
    )
end

getContainerDataForRow(container::Dict, properties::Dict, geometry::Dict) =
    [
        container["container_id"],
        geometry["coordinates"][1], # lat
        geometry["coordinates"][2], # lng
        properties["district"],
        properties["name"],
        properties["id"],
        haskey(container, "knsko_id") ? container["knsko_id"] : missing,
        container["trash_type"]["id"],
        container["trash_type"]["description"],
        container["container_type"],
        container["cleaning_frequency"]["duration"],
        container["cleaning_frequency"]["frequency"],
        container["cleaning_frequency"]["id"],
        haskey(container, "sensor_supplier") ? container["sensor_supplier"] : missing,
        haskey(container, "sensor_code") ? container["sensor_code"] : missing,
        haskey(container, "sensor_id") ? container["sensor_id"] : missing,
    ]

function containersJSONToDataFrame(locations::Vector{Any})
    df = createContainerDataFrame()
    for location in locations
        geometry = location["geometry"]
        properties = location["properties"]
        if (!haskey(properties, "containers"))
            continue
        end
        for container in properties["containers"]
            row = getContainerDataForRow(container, properties, geometry)
            row = map(r -> isnothing(r) ? missing : r, row)
            push!(df, row)
        end
    end
    return df
end

getContainersLocation() = "./generated/containers.csv"

loadContainers() =
    getContainersLocation() |>
    CSV.File |>
    DataFrame

loadMeasuredContainers() =
    filter(r -> !ismissing(r[:sensor_id]), loadContainers())

function loadLandRegistryGeoJSONData(fileName::String)
    data = let
        res = GeoJSON.read(open("./downloaded-data/land-registry-geojson-3/$(601527)/$(fileName).geojson") |> read |> String) |> geo2dict
        res["features"] = []
        ids = @pipe readdir("./downloaded-data/land-registry-geojson-3/") |>
                    filter(x -> x[1] != '.', _)

        for (idx, id) in enumerate(ids)
            open("downloaded-data/land-registry-geojson-3/$(id)/$(fileName).geojson") do f
                t = GeoJSON.read(f |> read |> String) |> geo2dict
                append!(res["features"], t["features"])
            end

        end
        res |> dict2geo
    end
    data
end

getContainersGDAL()::DataFrame = GDF.read("downloaded-data/containers-geojson/containers.geojson")

getContainerLocationsGDAL()::DataFrame =
    @pipe "downloaded-data/containers-geojson/container-locations.geojson" |>
          GDF.read |>
          convertDataframeJSONColumn!(_, :containers)

getContainerLocationsRawGDAL()::DataFrame =
    @pipe "downloaded-data/containers-geojson/container-locations.geojson" |>
          GDF.read

getPublicContainerLocationsByTrashTypeGDAL(trashTypeId::Integer) =
    @pipe getContainerLocationsGDAL() |>
          filter(DataConversion.isContainerLocationIncludesTrashType(trashTypeId), _) |>
          filter(DataConversion.isContainerLocationPublic, _)

getFilteredBuildingsGDAL(trashTypeId::Integer)::DataFrame =
    GDF.read("downloaded-data/filtered-buildings/buildings_without_private_containers_$(trashTypeIdToDescription[trashTypeId])_$(trashTypeId).geojson")

getCadastralZonesGDAL()::DataFrame =
    GDF.read("downloaded-data/KATASTRALNI_UZEMI_P.geojson")

getBuildingsWithNumberOfFloorsGDAL()::DataFrame =
    GDF.read("URK_SS_Podlaznost_p_shp/URK_SS_Podlaznost_p.geojson")

getPopulationCountPerCadastralZone()::DataFrame =
    "/Users/jakubzika/School/Bachelor-thesis/Explorations/downloaded-data/population-count-per-cadastral-teritory.csv" |>
    CSV.File |>
    DataFrame


getCadastralZoneIds()::Vector{Integer} =
    getCadastralZonesGDAL().KATUZE_KOD

function getCadastralZoneGDAL(id::Integer)::DataFrameRow
    zones = getCadastralZonesGDAL()
    res = filter(zones) do zone
        zone.KATUZE_KOD == id
    end
    return res[1, :]
end

function getFilteredBuildingsInCadastralTeritoryGDAL(
    trashTypeId::Integer,
    cadastralZoneId::Integer
)
    zone = getCadastralZoneGDAL(cadastralZoneId)
    buildings = getFilteredBuildingsGDAL(trashTypeId)
    isInPredicate = isInZonePredicate(zone.geom)

    buildingsInZone = filter(buildings) do building
        isInPredicate(building.geom)
    end

    return buildingsInZone
end

getCadastralTeritories()::DataFrame =
    GDF.read("downloaded-data/KATASTRALNI_UZEMI_P.geojson")


function tryParseJsonString(s::Any)
    if typeof(s) != String
        return missing
    else
        try
            return copy(JSON3.read(s))
        catch e
            return missing
        end
    end

end

function convertDataframeJSONColumn!(df::DataFrame, column::Symbol)
    df[!, column] = [tryParseJsonString(x) for x in df[!, column]]
    return df
end

function convertDataFrameDictToJSONColumn!(df::DataFrame, column::Symbol)
    df[!, column] = [isnothing(x) ? nothing : JSON3.write(x) for x in df[!, column]]
    return df
end

isContainerPublicPredicate(container::DataFrameRow) = container.accessibility_id == 1

isContainerLocationPublic(containerLocation::DataFrameRow) = isContainerPublicPredicate(containerLocation)

isContainerOfTrashType(trashTypeId::Number) =
    container::DataFrameRow -> container.trash_type_id == trashTypeId


isContainerLocationIncludesTrashType(trashtypeId::Number) =
    containerLocation::DataFrameRow ->
        containerLocation.containers !== nothing && containerLocation.containers !== missing &&
            any(
                c -> c[:trash_type][:id] == trashtypeId,
                values(containerLocation.containers)
            )

getLocationTrashTypes(location::DataFrameRow) =
    (ismissing(location.containers) || isnothing(location.containers)) ?
    [] :
    map(c -> c[:trash_type][:id], location.containers) |> unique

isContainerLocationIncludesTrashTypes(trashTypeIds::Vector{Int64}) =
    (location::DataFrameRow) ->
        (intersect(getLocationTrashTypes(location), trashTypeIds) |> length) == (trashTypeIds |> length)


isInZonePredicate(zone) =
    point -> AGDAL.within(point, zone)

# isContainerMeasured(container::DataFrameRow) =

getPathForNearestContainerForBuilding(trashTypeId::Integer, cadastralZoneId::Integer) =
    "downloaded-data/nearest-container-for-buildings/$(trashTypeId)/$(cadastralZoneId).csv"

getPathForCadastralRegistryData(fileName::String, cadastralZoneId::Integer) =
    "downloaded-data/land-registry-geojson-3/$(cadastralZoneId)/$(fileName).geojson"

getBuildingPopulations() =
    CSV.read("downloaded-data/calcualted-population.csv") |> DataFrame

function getNearestContainerForBuildings(trashTypeId::Integer)
    cadastralZoneIds = getCadastralZoneIds()

    df = DataFrame()

    for (idx, cadastralZoneId) in enumerate(cadastralZoneIds)
        # println("Loading building $(idx)/$(length(cadastralZoneIds)) - $(cadastralZoneId)")
        buildingDf =
            getPathForNearestContainerForBuilding(trashTypeId, cadastralZoneId) |>
            CSV.File |>
            DataFrame
        filteredBuildingDf = filter(buildingDf) do row
            row.nearestIdx == 1
        end
        df = vcat(df, filteredBuildingDf)
    end

    return df
end

function getCadastralRegistryDataGDAL(fileName::String; log::Bool=false)
    cadastralZoneIds = getCadastralZoneIds()
    df = DataFrame()
    for (idx, cadastralZoneId) in enumerate(cadastralZoneIds)
        log && println("Loading $(cadastralZoneId)")
        tempDf =
            getPathForCadastralRegistryData(fileName, cadastralZoneId) |>
            GDF.read
        df = vcat(df, tempDf)
    end

    return df
end

archGDALPointToStaticArrayPoint(point)::SVector{2,Float32} =
    @pipe point |>
          coordinates |>
          reverse |>
          SVector(_[1], _[2])

function getGDALSearchTree(data::DataFrame)::NNTree

    adjustFn =
        if typeof(data.geom[1]) === AGDAL.IGeometry{AGDAL.wkbPolygon}
            AGDAL.centroid
        else
            identity
        end

    points =
        @pipe data.geom |> map(adjustFn, _) |>
              map(archGDALPointToStaticArrayPoint, _)
    return BallTree(points, Haversine())
end

function convertGDALToGeoJSON(df::DataFrame)
    path, io = mktemp()
    close(io)
    rm(path)
    GDF.write(path, df, driver="GeoJSON")
    resString = read(path, String)
    rm(path)
    resString
end


# TODO: use real enahnced locations when done
getServerEnhancedContainerLocationsGDAL() =
    @pipe GDF.read("downloaded-data/server-ready-containers.geojson") |>
          convertDataframeJSONColumn!(_, :containers) |>
          convertDataframeJSONColumn!(_, :trash_type_info)

getServerEnhancedContainerLocationsString() =
    read("downloaded-data/server-ready-containers.geojson", String)

end
