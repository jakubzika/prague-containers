export getContainerMeasurements

using Dates

include("../core.jl")
using .GolemioAPI

Maybe{T} = Union{T,Nothing} where T

function getContainers(config::GolemioAPI.GolemioConfig;
    lat::Maybe{Number}=nothing,
    lng::Maybe{Number}=nothing,
    range::Maybe{Number}=nothing,
    accessibility::Maybe{Int64}=nothing,
    limit::Int64=10_000,
    offset::Int64=0,
    onlyMonitored::Bool=false,
    id::Maybe{String}=nothing,
    knskoId::Maybe{String}=nothing,
    )

    convertedLatLng = begin
        if isnothing(lat) || isnothing(lng)
            nothing
        elseif lat isa Number && lng isa Number
            "$(lat),$(lng)"
        end
    end

    queryParams = Dict(
        "latlng" => convertedLatLng,
        "range" => range,
        "accessibility" => accessibility,
        "limit" => limit,
        "offset" => offset,
        "onlyMonitored" => onlyMonitored,
        "id" => id,
        "knskoId" => knskoId,
    )

    path = "/sortedwastestations/"

    return getRequest(config, path, queryParams)
end

function getAllContainers(config::GolemioAPI.GolemioConfig;
    accessibility::Maybe{String}=nothing,
    onlyMonitored::Maybe{Bool}=nothing,
    apiVersion::Symbol=:V1
    )

    queryParams = Dict(
        "accessibility" => accessibility,
        "onlyMonitored" => onlyMonitored,
        "limit" => 0,
        "offset" => 0,
    )

    arrayAccessFunction(data) = data["features"]

    path = "/sortedwastestations/"

    return getRequestAllPaged(config, path, queryParams,
        limit=5_000,
        arrayAccessFunction=arrayAccessFunction,
        apiVersion=apiVersion
    )

end

function getContainerMeasurements(config::GolemioAPI.GolemioConfig;
    containerId::Maybe{String}=nothing,
    knskoId::Maybe{String}=nothing,
    limit::Int64=10_000,
    offset::Int64=0,
    from::Maybe{DateTime}=nothing,
    to::Maybe{DateTime}=nothing,
    )

    if (containerId === nothing && knskoId === nothing)
        throw(DomainError("one of parameters: containerId, knskoId must be present"))
    end

    queryParams = Dict(
        "containerId" => containerId,
        "knskoId" => knskoId,
        "limit" => limit,
        "offset" => offset,
        "from" => from,
        "to" => to,
    )
    path = "/sortedwastestations/measurements/"

    return getRequest(config, path, queryParams)
end

function getAllContainerMeasurements(config::GolemioAPI.GolemioConfig, containerId::String)
    queryParams = Dict(
        "containerId" => containerId,
        "offset" => 0,
        "limit" => 0,
    )

    path = "/sortedwastestations/measurements/"

    return getRequestAllPaged(config, path, queryParams, limit=5_000)
end


function getContainerWastePicks(config::GolemioAPI.GolemioConfig;
    containerId::Maybe{String}=nothing,
    knskoId::Maybe{String}=nothing,
    limit::Int64=10_000,
    offset::Int64=0,
    from::Maybe{DateTime}=nothing,
    to::Maybe{DateTime}=nothing,
    )

    if (containerId === nothing && knskoId === nothing)
        throw(DomainError("one of parameters: containerId, knskoId must be present"))
    end

    queryParams = Dict(
        "containerId" => containerId,
        "knskoId" => knskoId,
        "limit" => limit,
        "offset" => offset,
        "from" => from,
        "to" => to,
    )

    path = "/sortedwastestations/picks"

    return getRequest(config, path, queryParams)
end


function getAllContainerWastePicks(config::GolemioAPI.GolemioConfig, containerId::String)

    queryParams = Dict(
        "containerId" => containerId,
        "offset" => 0,
        "limit" => 0,
    )

    path = "/sortedwastestations/picks"

    return getRequestAllPaged(config, path, queryParams, limit=5_000)
end