using Pkg
Pkg.activate(".")

using HTTP
using Sockets
import GeoDataFrames as GDF
using Pipe
using StaticArrays
using NearestNeighbors
using JSON3
using Dates
using DataFrames
using LRUCache

include("data-conversion.jl")

containerLocations = DataConversion.getServerEnhancedContainerLocationsGDAL()
containerLocationsString = DataConversion.getServerEnhancedContainerLocationsString()

searchTreeLRUCache = LRU{Tuple{Vector{Int64},Bool},Tuple{NNTree,DataFrame}}(maxsize=16)

function cachedSearchTree(trashTypes::Vector{Int64}, onlyPublic::Bool)
    get!(searchTreeLRUCache, (trashTypes, onlyPublic)) do
        filteredLocations = filter(
            DataConversion.isContainerLocationIncludesTrashTypes(trashTypes),
            containerLocations
        )

        if (onlyPublic)
            filter!(
                DataConversion.isContainerLocationPublic,
                filteredLocations
            )
        end

        (DataConversion.getGDALSearchTree(filteredLocations), filteredLocations)
    end
end

function getNearestLocations(req::HTTP.Request)

    target = HTTP.Messages.getfield(req, :target)
    params = HTTP.queryparams(HTTP.URI(target))

    trashTypes::Vector{Int64} = Vector()

    if (!(haskey(params, "lat") && haskey(params, "lng")))
        return HTTP.Response(404)
    end
    if haskey(params, "trashTypes")
        try
            trashTypes = @pipe params["trashTypes"] |> split(_, ",") |> map(v -> parse(Int64, v), _) |> sort
        catch e

        end
    end

    onlyPublic::Bool = false
    if haskey(params, "onlyPublic")
        onlyPublic = params["onlyPublic"] === "true"
    end

    lat = parse(Float32, params["lat"])
    lng = parse(Float32, params["lng"])

    ballTree, filteredLocations = cachedSearchTree(trashTypes, onlyPublic)

    searchPoint = SVector(lat, lng)
    nearestIdx, distance = NearestNeighbors.knn(ballTree, searchPoint, 10)

    nearestLocations = filteredLocations[nearestIdx, :]

    DataConversion.convertDataFrameDictToJSONColumn!(nearestLocations, :containers)
    DataConversion.convertDataFrameDictToJSONColumn!(nearestLocations, :trash_type_info)
    resString = DataConversion.convertGDALToGeoJSON(nearestLocations)

    HTTP.Response(200, resString)
end

function getAllLocations(req::HTTP.Request)
    HTTP.Response(200, containerLocationsString)
end

function getLocations(req::HTTP.Request)
    target = HTTP.Messages.getfield(req, :target)
    params = HTTP.queryparams(HTTP.URI(target))

    locationIds = []
    if (haskey(params, "locationIds"))
        locationIds = JSON3.read(params["locationIds"]) |> Vector
    end

    filteredLocation = filter(:id => ∈(locationIds), containerLocations)

    DataConversion.convertDataFrameDictToJSONColumn!(filteredLocation, :containers)
    DataConversion.convertDataFrameDictToJSONColumn!(filteredLocation, :trash_type_info)
    resString = DataConversion.convertGDALToGeoJSON(filteredLocation)

    HTTP.Response(200, resString)
end

function startServer()
    router = HTTP.Router()
    HTTP.@register(router, "GET", "/api/v1/nearest-locations", getNearestLocations)
    HTTP.@register(router, "GET", "/api/v1/all-locations", getAllLocations)
    HTTP.@register(router, "GET", "/api/v1/locations", getLocations)

    println("Starting server")
    HTTP.serve(router, ip"0.0.0.0", 8080)
end

startServer()

