### A Pluto.jl notebook ###
# v0.19.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 5481d23e-c31c-11ec-2b93-adf609341030
begin
	import Pkg
	Pkg.activate(Base.current_project())
end

# ╔═╡ 437019bf-e138-45e1-bb5a-78f0fe93137e
begin
	using Pipe
	using DataFrames
	using Plots
	using GeoInterface
	import JSON3
	import ArchGDAL as AGDAL
	using Distances
	using NearestNeighbors
	using PlutoUI
	using LinearAlgebra
	using CSV
	import GeoDataFrames as GDF
	using Plots
	using Statistics
	using Query
	using Formatting
	using DataInterpolations
	using Random
	using Dates
	using TimeZones
	using Colors
end

# ╔═╡ 555bfff9-bed3-4189-9902-646e682441a0
include("src/data-conversion.jl")

# ╔═╡ 4e35c7d5-2195-4508-aa24-ddd9559c04e2
include("src/containerCapacity.jl")

# ╔═╡ a3d8b864-0e14-45e0-baa5-d3b2970ab8a5
plotly()

# ╔═╡ 1a9291e5-63f1-47a6-80d5-035a6a1ebff3
containers = DataConversion.getContainersGDAL();

# ╔═╡ 9f88528d-61a1-4933-af7e-63d2099d5efd
unique(containers.location_id) |> length

# ╔═╡ dcd39a9e-c549-40bd-8fd4-2cadf6df7eac
trashTypeId = 6

# ╔═╡ 4d00f3f5-e9fb-4af2-ba5e-00eef3fcb1a2
locationsWithCalculatedDemand = GDF.read("tmp/$(trashTypeId)-container-demand-normalized.geojson");

# ╔═╡ f9cf3836-5924-49a5-9eb7-5ab823c97456
calculatedDemand = select(locationsWithCalculatedDemand, :id, :normalized_demand, :location_throughput, :population_sum);

# ╔═╡ b4b58be4-bf3f-40b0-8404-75574aa52972
begin
	DataConversion.convertDataframeJSONColumn!(containers, :trash_type)
	DataConversion.convertDataframeJSONColumn!(containers, :cleaning_frequency)
	DataConversion.convertDataframeJSONColumn!(containers, :last_measurement)
end;

# ╔═╡ 5ededbd9-9e59-4322-a507-4378ff4ed65e
measuredContainers = filter(c -> c.sensor_code !== "null" ,containers);

# ╔═╡ ce879a9a-a165-44d8-8981-e019284b4d67
md"""
Select date range:

`fromDate` = $(@bind fromDate DateField(default=today()))

`toDate` = $(@bind toDate DateField(default=today()))
"""

# ╔═╡ 23631f81-f48c-4424-ab23-712866975d6f
hourInterval = 1000 * 60 * 60

# ╔═╡ 7a1ec622-4134-4f17-8a35-6107520343bc
filterRows(m, from, to) = filter(r -> !isnothing(r.measured_at) && r.measured_at > from && r.measured_at < to, m)

# ╔═╡ 2a97eacc-fdef-43da-951d-615d4b84e03b
function fullnessFactor(measurements::DataFrame, from::DateTime, to::DateTime)
	filteredRows = filterRows(measurements, from, to)
	fd = filteredRows[!, :percent_calculated] |> reverse
	if (length(fd) === 0)
		return 0
    	end
	td = @pipe filteredRows[!, :measured_at] |> map(v -> Dates.value(v), _) |> reverse
	ifd = LinearInterpolation(fd, td)

	# println("fd:", length(fd))
	it = Dates.value(from):hourInterval:Dates.value(to)

	fullnessPredicate(v) = v >= 99
	sumFull = @pipe it |> map(v -> ifd(v), _) |> filter(v -> fullnessPredicate(v), _) |> length

	# println("sum full: ", sumFull)
	# println("length: ", length(it))
    
	return sumFull / length(it)
end


# ╔═╡ b38da687-a65f-4f26-b0cc-6cf43bac5bb3
function getFullnessFactorForContainer(containerId::String, from::DateTime, to::DateTime)
	# println("Container id: $(containerId)")
	m = measurements = DataConversion.getContainerMeasurements(containerId)
	if (nrow(measurements) === 0)
		return 0
    	end
	f = fullnessFactor(m, from, to)
	return f
end

# ╔═╡ af3d3707-856c-4845-8db8-3fd3e519600f
res = transform(measuredContainers, 
	:container_id => ByRow(c -> getFullnessFactorForContainer(c, fromDate, toDate)) => :fullness_factor
);

# ╔═╡ 8cfc6d5e-6f40-435c-9b10-a51872da22b5
resJoined =  innerjoin(res,calculatedDemand, on = :location_id => :id);

# ╔═╡ 8e043df7-e206-43e2-af29-f8da98000dac
begin
	resCopy = DataFrame(resJoined)
	DataConversion.convertDataFrameDictToJSONColumn!(resCopy, :trash_type)
	DataConversion.convertDataFrameDictToJSONColumn!(resCopy, :cleaning_frequency)
	DataConversion.convertDataFrameDictToJSONColumn!(resCopy, :last_measurement)
	 resCopy[!,:fullness_factor] = Float32.(resCopy.fullness_factor);
end

# ╔═╡ f0a123fc-0ba4-4aaa-8387-d69939d94995
resJoinedTrash = filter(:trash_type_id => ==(trashTypeId),resJoined);

# ╔═╡ d4db940a-5c4a-472a-920e-16a354f29f7b
GDF.write("tmp/measured-fullness-factors.geojson", resCopy)

# ╔═╡ c13184e0-d928-4fb4-8ec1-59866c36f78a
select(resJoined, :fullness_factor, :normalized_demand);

# ╔═╡ a7046c3b-daf2-44f8-a2c2-ed0f614b5faf
cleaningFrequencies = map(
	
	f -> ContainerCapacity.getContainerMonthlyCleaningFrequency(f[:id]),
	resJoinedTrash.cleaning_frequency
)

# ╔═╡ 9373d31b-95d5-459e-ba50-74b29105213e
cor(resJoinedTrash.fullness_factor,resJoinedTrash.population_sum)

# ╔═╡ e3a8c011-a71e-4a77-bf13-a54843c93300
cor(resJoinedTrash.fullness_factor,resJoinedTrash.normalized_demand)

# ╔═╡ f636af59-5e6f-4b3f-a276-00a131035f7d
cor(resJoinedTrash.normalized_demand, resJoinedTrash.location_throughput)

# ╔═╡ 03c627c5-affa-4728-a869-420fb88ff41e
scatter(resJoinedTrash.fullness_factor,resJoinedTrash.population_sum)

# ╔═╡ 2899e873-6724-4907-b597-d2dfa05233e1
resJoinedTrash.fullness_factor[resJoinedTrash.fullness_factor .== 0] |> length

# ╔═╡ 92371b0e-d4de-40ac-b14f-07fc221d9af3
resJoinedTrash.fullness_factor |> length

# ╔═╡ c93d464e-8315-4a90-a807-8726470ee2b0
resJoinedTrash

# ╔═╡ Cell order:
# ╠═5481d23e-c31c-11ec-2b93-adf609341030
# ╠═437019bf-e138-45e1-bb5a-78f0fe93137e
# ╠═a3d8b864-0e14-45e0-baa5-d3b2970ab8a5
# ╠═555bfff9-bed3-4189-9902-646e682441a0
# ╠═4e35c7d5-2195-4508-aa24-ddd9559c04e2
# ╠═1a9291e5-63f1-47a6-80d5-035a6a1ebff3
# ╠═9f88528d-61a1-4933-af7e-63d2099d5efd
# ╠═dcd39a9e-c549-40bd-8fd4-2cadf6df7eac
# ╠═4d00f3f5-e9fb-4af2-ba5e-00eef3fcb1a2
# ╟─f9cf3836-5924-49a5-9eb7-5ab823c97456
# ╟─b4b58be4-bf3f-40b0-8404-75574aa52972
# ╠═5ededbd9-9e59-4322-a507-4378ff4ed65e
# ╟─ce879a9a-a165-44d8-8981-e019284b4d67
# ╟─23631f81-f48c-4424-ab23-712866975d6f
# ╟─7a1ec622-4134-4f17-8a35-6107520343bc
# ╟─2a97eacc-fdef-43da-951d-615d4b84e03b
# ╟─b38da687-a65f-4f26-b0cc-6cf43bac5bb3
# ╟─af3d3707-856c-4845-8db8-3fd3e519600f
# ╠═8cfc6d5e-6f40-435c-9b10-a51872da22b5
# ╟─8e043df7-e206-43e2-af29-f8da98000dac
# ╠═f0a123fc-0ba4-4aaa-8387-d69939d94995
# ╠═d4db940a-5c4a-472a-920e-16a354f29f7b
# ╠═c13184e0-d928-4fb4-8ec1-59866c36f78a
# ╟─a7046c3b-daf2-44f8-a2c2-ed0f614b5faf
# ╠═9373d31b-95d5-459e-ba50-74b29105213e
# ╠═e3a8c011-a71e-4a77-bf13-a54843c93300
# ╠═f636af59-5e6f-4b3f-a276-00a131035f7d
# ╠═03c627c5-affa-4728-a869-420fb88ff41e
# ╠═2899e873-6724-4907-b597-d2dfa05233e1
# ╠═92371b0e-d4de-40ac-b14f-07fc221d9af3
# ╠═c93d464e-8315-4a90-a807-8726470ee2b0
