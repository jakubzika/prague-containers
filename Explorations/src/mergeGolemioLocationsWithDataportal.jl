include("./golemioAPI.jl")
include("./data-conversion.jl")
include("./util.jl")

using Dates
using TimeZones
using DataFrames
using CSV
using GeoJSON
using GeoInterface
using JSON

using .GolemioAPI

config = GolemioAPI.createConfig(accessToken="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Imt1YmEuemlrYUBlbWFpbC5jeiIsImlkIjoxMDg5LCJuYW1lIjpudWxsLCJzdXJuYW1lIjpudWxsLCJpYXQiOjE2NDUwMjUxNzcsImV4cCI6MTE2NDUwMjUxNzcsImlzcyI6ImdvbGVtaW8iLCJqdGkiOiI5MTU4MjdmYS1jNTcwLTQ2MWEtODE4Mi0yMTUwMWMzZTEyNjAifQ.Y4nRVJ91GScPy7UypSCPXyewMP9ONwMRU5i9TEgwnkk")
# golemioLocations = GolemioAPI.getAllContainers(config, apiVersion=:V1);
# geoportalLocations = GeoJSON.parsefile("/Users/jakubzika/School/Bachelor-thesis/Explorations/ZPK_O_Kont_TOstan_b.json")

containerstest = DataConversion.getContainerLocationsGDAL()

function parseAccessibility(accessibility)
    if (accessibility == "volně")
        (1, "volně")
    elseif (accessibility == "obyvatelům domu")
        (2, "obyvatelům domu")
    else
        (3, "neznámá dostupnost")
    end
end

function findLocation(stationNumber)
    res = filter(features(geoportalLocations)) do l
        geom = geometry(l)
        properties(l)["STATIONNAME"] == stationNumber
    end
    if (length(res) > 0)
        return res[1]
    else
        return nothing
    end
end

zippedLocations = map(golemioLocations) do golemioLocation
    (golemioLocation, findLocation(golemioLocation["properties"]["name"]))
end

getGeoportalLocationAccessibility(location) =
    location !== nothing ?
        parseAccessibility(properties(location)["PRISTUP"]) :
        parseAccessibility(nothing)


function mergeZippedLocations(golemioLocation, geoportalLocation)
    mergedLocation = copy(golemioLocation)
    delete!(mergedLocation["properties"], "accessibility")
    
    accessibility_id, accessibility_description = getGeoportalLocationAccessibility(geoportalLocation)

    mergedLocation["properties"]["accessibility_id"] = accessibility_id
    mergedLocation["properties"]["accessibility_description"] = accessibility_description

    return mergedLocation
end

mergedLocations = map(a -> mergeZippedLocations(a[1], a[2]), zippedLocations)


open("downloaded-data/containers-geojson/container-locations.geojson","w") do f
    write(f,JSON.json(Dict(
        "type" => "FeatureCollection",
        "name" => "ContainerLocations",
        "features" => mergedLocations
    )))
end
