using Dates

function structToDict(s)::Dict
    converted = Dict()
    for n in fieldnames(typeof(s))
        field = getfield(s, n)
        if (field !== nothing)
            converted[n] = field
        end
    end
    return converted
end

function convertDictToQueryParams(d::Dict)
    newDict = Dict()
    for (key, val) in d
        if (!isnothing(val))
            newDict[key] = val
        elseif (typeof(val) === DateTime)
            newDict[key] = Dates.format(val, ISODateTimeFormat)
        end
    end
    return newDict
end

function flattenDict(d::Dict)
    newD = empty(d)
    for (key, value) in pairs(d)
        if value isa Dict
            res = flattenDict(value)
            for (k, v) in pairs(res)
                newD["$(String(key))_$(String(k))"] = v
            end
        else
            newD["$(String(key))"] = value
        end
    end
    return newD
end