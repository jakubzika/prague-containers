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
# data = GolemioAPI.getAllContainers(config, apiVersion=:V1, accessibility="2");
# locations = GeoJSON.parsefile("/Users/jakubzika/School/Bachelor-thesis/Explorations/ZPK_O_Kont_TOstan_b.json")

allKeys = [
    "trash_type",
    "cleaning_frequency",
    "trash_type_description",
    "container_type",
    "district",
    "name",
    "knsko_id",
    "container_id",
    "sensor_supplier",
    "last_measurement",
    "station_number",
    "last_pick",
    "trash_type_id",
    "accessibility_id",
    "accessibility_description",
    "sensor_code",
    "sensor_id",
]


allKeys[findall(∉(["knsko_id"]), allKeys)]

function findLocation(stationNumber)
    res = filter(features(locations)) do l
        geom = geometry(l)
        properties(l)["STATIONNAME"] == stationNumber
    end
    if (length(res) > 0)
        return res[1]
    else
        return nothing
    end
end


function parseAccessibility(accessibility)
    if (accessibility == "volně")
        (1, "volně")
    elseif (accessibility == "obyvatelům domu")
        (2, "obyvatelům domu")
    else
        (3, "neznámá dostupnost")
    end
end

[data[i]["properties"]["id"] for i in 1:length(keys(data))] |> length
[data[i]["properties"]["id"] for i in 1:length(keys(data))] |> unique |> length

onlyContainers = []
for loc in data
    if "containers" ∉ keys(loc["properties"])
        continue
    end
    for c in loc["properties"]["containers"]


        base = copy(loc)
        container = copy(c)
        props = base["properties"]

        altLocation = findLocation(props["name"])
        if (altLocation !== nothing)
            id, acc = parseAccessibility(properties(altLocation)["PRISTUP"])
            container["accessibility_id"] = id
            container["accessibility_description"] = acc
        else
            container["accessibility_id"] = 3
            container["accessibility_description"] = "neznámá dostupnost"
        end
        # println(props["id"])

        container["location_id"] = props["id"]
        container["district"] = props["district"]
        container["name"] = props["name"]
        container["station_number"] = props["station_number"]
        # container["accessibility_id"] = props["accessibility"]["id"]
        # container["accessibility_description"] = props["accessibility"]["description"]
        container["station_number"] = props["station_number"]
        container["trash_type_id"] = c["trash_type"]["id"]
        container["trash_type_description"] = c["trash_type"]["description"]

        missingKeys = allKeys[findall(∉(keys(container)), allKeys)]
        for missingKey in missingKeys
            container[missingKey] = "null"
        end


        base["properties"] = container
        push!(onlyContainers, base)
    end
end


open("downloaded-data/containers-geojson/containers.geojson", "w") do f
    write(f, JSON.json(Dict(
        "type" => "FeatureCollection",
        "name" => "Containers",
        "features" => onlyContainers
    )))
end

