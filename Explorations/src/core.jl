using HTTP
using JSON
using GeoJSON
using GeoInterface

include("./util.jl")

Maybe{T} = Union{T,Nothing} where T

const API_BASE_URL = "https://api.golemio.cz/v2"

struct GolemioConfig
    accessToken::String
    base::String
    headers::Array{Tuple{String,String}}
end

createConfig(;accessToken::String, base::String=API_BASE_URL)::GolemioConfig =
    GolemioConfig(
        accessToken,
        base,
        createHeaders(accessToken),
    )

createHeaders(accessToken::String)::Array{Tuple{String,String}} =
    [
        ("Content-Type", "application/json; charset=utf-8"),
        ("x-access-token", accessToken),
    ]


function getRequest(config::GolemioConfig, path::String, queryParams::Dict; apiVersion::Symbol=:V1)
    if (apiVersion === :V1)
        return getRequestV1(config, path, queryParams)
    elseif (apiVersion === :V2)
        return getRequestV2(config, path, queryParams)
    end
end 


function getRequestV1(config::GolemioConfig, path::String, queryParams::Dict)
    params = convertDictToQueryParams(queryParams)
    url = HTTP.URI(HTTP.URI("$(config.base)$(path)"), query=params)
    response = HTTP.get(url, config.headers)

    return JSON.parse(String(response.body))
end 

function getRequestAllPaged(config::GolemioConfig, path::String, queryParams::Dict;
    initialOffset::Int64=0,
    limit::Int64=10_000,
    arrayAccessFunction::Function=identity,
    apiVersion::Symbol=:V1
)
    if (apiVersion === :V1)
        return getRequestAllPagedV1(config, path, queryParams, initialOffset=initialOffset, limit=limit, arrayAccessFunction=arrayAccessFunction)
    elseif (apiVersion === :V2)
        return getRequestAllPagedV2(config, path, queryParams, initialOffset=initialOffset, limit=limit)
    end
end


function getRequestAllPagedV1(config::GolemioConfig, path::String, queryParams::Dict;
        initialOffset::Int64=0,
        limit::Int64=10_000,
        arrayAccessFunction::Function=identity
    )
    offset = initialOffset
    queryParams["limit"] = limit
    queryParams["offset"] = offset

    iteration = 0

    iteration!() = begin
        data = getRequest(config, path, queryParams, apiVersion=:V1)
        offset += limit 
        queryParams["offset"] = offset
        iteration += 1
        convertedData = arrayAccessFunction(data)
        if (!(convertedData isa Vector{Any}))
            throw(DomainError("Array transform function did not return array, got $(typeof(data)) instead"))
        end
        return convertedData
    end

    agregatedData = Vector()

    data = iteration!()
    append!(agregatedData, data)

    if (typeof(data) !== Vector{Any})
        throw(DomainError("Endpoint did not return Vector, got $(typeof(data)) instead"))
    end

    println("First request $(length(agregatedData))")

    numOfRequests = 1
    while length(data) === limit
        data = iteration!()
        append!(agregatedData, data)
        numOfRequests += 1
        println("$(numOfRequests) request $(length(agregatedData))")
    end

    println("Data fetching took $(numOfRequests) requests")

    return agregatedData
end


function getRequestV2(config::GolemioConfig, path::String, queryParams::Dict)
    params = convertDictToQueryParams(queryParams)
    url = HTTP.URI(HTTP.URI("$(config.base)$(path)"), query=params)
    response = HTTP.get(url, config.headers)

    return JSON.parse(String(response.body))
end

function getRequestAllPagedV2(config::GolemioConfig, path::String, queryParams::Dict;
    initialOffset::Int64=0,
    limit::Int64=10_000)

    offset = initialOffset
    queryParams["limit"] = limit
    queryParams["offset"] = offset

    iteration = 0

    iteration!() = begin
        data = getRequest(config, path, queryParams, apiVersion=:V2)
        offset += limit 
        queryParams["offset"] = offset
        iteration += 1
        return data
        end

    data = iteration!()
    resultFeatureCollection = data

    println("First request $(length(features(data)))")

    numOfRequests = 1
    while length(features(data)) === limit
        data = iteration!()  
        # append!(features(resultFeatureCollection), features(data))
        numOfRequests += 1
        println("$(numOfRequests) request $(length(features(resultFeatureCollection)))")
    end

    println("Data fetching took $(numOfRequests) requests")

    return resultFeatureCollection

    end