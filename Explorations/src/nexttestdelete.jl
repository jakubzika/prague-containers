include("./data-conversion.jl")

# locations = DataConversion.getContainerLocationsGDAL()

filterFn = DataConversion.isContainerLocationIncludesTrashType(6) ∘ DataConversion.isContainerLocationPublic

filter(filterFn, locations)

