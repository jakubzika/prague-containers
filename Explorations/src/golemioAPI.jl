module GolemioAPI

export getRequest, createConfig, Config, Maybe, getContainerMeasurements, getAllContainerMeasurements, getContainerWastePicks,getAllContainerWastePicks
export getAllContainers, getContainers


include("./core.jl")
include("./endpoints/containers.jl")

end

