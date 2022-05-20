### A Pluto.jl notebook ###
# v0.18.0

using Markdown
using InteractiveUtils

# ╔═╡ 59a76f92-cca6-11ec-2bd2-e185fd1ac521
begin
  import Pkg
  Pkg.activate(Base.current_project())
end

# ╔═╡ 8d85878d-6385-4d4a-82ee-caaed6f0f816
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
end

# ╔═╡ 8b06f6e6-f41a-4cc1-b6c9-74f9d49cbc8b
include("src/containerCapacity.jl")

# ╔═╡ 7d8e1b2c-f5ef-4d5c-98a1-cc3e39a230d3
include("src/data-conversion.jl")

# ╔═╡ f55fa499-7dd2-4cf9-92a6-f571f3b8c1c7
begin
	population = CSV.File("downloaded-data/calcualted-population.csv", stringtype=String) |> DataFrame;
	population[!, :ID_2] = string.(population.ID_2);
end

# ╔═╡ 256d5cba-dae8-4e38-9251-0082b34cb2fe
buildings = DataConversion.getCadastralRegistryDataGDAL("BUDOVY_DEF");

# ╔═╡ 7b997c40-aa31-4a81-aeac-771d3f11299f
containerLocations = DataConversion.getContainerLocationsGDAL()

# ╔═╡ 0270e6c7-d320-443f-aab0-bf0f9f347276
begin
	buildingsWithPopulation =
  		@pipe leftjoin(buildings, population, on=:ID_2) |>
		unique(_, :ID_2)
	buildingsWithPopulation.population[ismissing.(buildingsWithPopulation.population)] .= 0;
	select!(buildingsWithPopulation, :geom, :ID_2, :population);
end

# ╔═╡ 7728df24-5be8-4dbf-86ee-92d5ca059090
function getNearestContainersWithBuildings(trashTypeId::Int64)
	nearestContainers = DataConversion.getNearestContainerForBuildings(trashTypeId)
	nearestContainers[!, :buildingId2] = string.(nearestContainers.buildingId2)
	nearestContainers = innerjoin(nearestContainers, buildingsWithPopulation, on=:buildingId2 => :ID_2);
	nearestContainers
end

# ╔═╡ a59d68a9-aff8-42e8-8ceb-cace9ba976fa
getNearestContainersWithBuildings(6)

# ╔═╡ 3a52e288-4b96-4ef2-a5ee-a83d9de93494
function getRowThroughput(containers)
  reduce(containers, init=0) do acc, i
    try
      return acc + i[:monthly_throughput]
    catch e
      # throw(e)
		return acc
    end

  end
end

# ╔═╡ 6c185186-9f5d-4a83-89fb-511150426f37
function computeTrashThroughput(
	containerDemandOriginal::DataFrame,
	trashTypeId::Int64
)
	containerDemand = DataFrame(containerDemandOriginal)
	for r in eachrow(containerDemand)
    	r.containers = filter(c -> c[:trash_type][:id] == trashTypeId, r.containers)
  	end
	
	for r in eachrow(containerDemand)
    	for c in r.containers
	      	frequency = ContainerCapacity.getContainerMonthlyCleaningFrequency(
			  	c[:cleaning_frequency][:id]
		  	)
	      	capacity = ContainerCapacity.getContainerCapacity(c[:container_type])
	      	maxMonthlyThroughput = frequency * capacity
	      	c[:monthly_throughput] = maxMonthlyThroughput
    	end
	end

	containerDemand = transform(containerDemand,
  		:containers => ByRow(getRowThroughput) => :location_throughput
	)

	demandNormalized = transform(containerDemand,
		[:location_throughput, :population_sum] =>
		ByRow((t, p) -> t == 0 ? 0 : p / t) => 
		:normalized_demand
	);

	demandNormalized[!, :location_throughput] = Float32.(demandNormalized.location_throughput);

	demandNormalized.normalized_demand[
		ismissing.(demandNormalized.normalized_demand)
	] .= 0;

	demandNormalized[!, :normalized_demand] = Float32.(demandNormalized.normalized_demand);

	return demandNormalized
end

# ╔═╡ 4f3d5231-0077-45f2-95e8-4fa13582c5dd
function computeTrashTypeDemand(trashTypeId::Int64)
	buildingsWithContainers = getNearestContainersWithBuildings(trashTypeId)
	groupedByContainerId = groupby(buildingsWithContainers, :containerId)
	peoplePerContainer = combine(groupedByContainerId, :population => sum)
	locations = DataConversion.getPublicContainerLocationsByTrashTypeGDAL(trashTypeId)
	containerDemand = leftjoin(locations, peoplePerContainer, on=:id => :containerId);

	demand = computeTrashThroughput(containerDemand ,trashTypeId)
	return demand
end

# ╔═╡ 8e4a5d6b-e398-4514-96f4-ea77d5f31d27
res = computeTrashTypeDemand(6)

# ╔═╡ 6f8e93f8-e573-4901-9403-30a1602309c3
function computeDemand()
	res = DataFrame()
	for trashTypeId in 1:7
		demand = computeTrashTypeDemand(trashTypeId)
		demand[!,:trash_type_id] = repeat([trashTypeId], nrow(demand))
		res = vcat(res, demand)
	end
	select!(res,:id, :population_sum, :location_throughput, :normalized_demand => :demand, :trash_type_id)
end

# ╔═╡ 69c93dc5-47b7-4f77-8c0a-8b8a6c9b8685
totalDemand = computeDemand();

# ╔═╡ 90fb4dd3-3650-481e-b0ec-48a406a6c343
groups = groupby(totalDemand, :id)

# ╔═╡ f3008fb9-5565-4167-87c1-2842b11091e3
groups[1]

# ╔═╡ 8524447b-6d46-4cfd-bcad-8cf28382964c
function combineFn(group)
	d = Dict()
	for g in eachrow(group)
		d[g.trash_type_id] = Dict(
			"population_sum" => g.population_sum,
			"location_throughput" => g.location_throughput,
			"demand" => g.demand,
		)
	end
	d
end

# ╔═╡ 7c4ff26a-f163-4046-b8bb-87e196c62b03
begin
	serverEnhancedContainers = 
		leftjoin(containerLocations, combine(groups, combineFn), on=:id)
	rename!(serverEnhancedContainers, :x1 => :trash_type_info)
end

# ╔═╡ 2615d1db-9c29-429b-8d50-83e5cf1c4198
begin
	serverEnhancedContainersSave = DataFrame(serverEnhancedContainers)
	DataConversion.convertDataFrameDictToJSONColumn!(
		serverEnhancedContainersSave,
		:trash_type_info
	)
	DataConversion.convertDataFrameDictToJSONColumn!(
		serverEnhancedContainersSave,
		:containers
	)
end

# ╔═╡ eb3c9751-b7a0-4577-8ded-0ac94eae0b5a
GDF.write("downloaded-data/server-ready-containers.geojson", serverEnhancedContainersSave)

# ╔═╡ Cell order:
# ╠═59a76f92-cca6-11ec-2bd2-e185fd1ac521
# ╠═8d85878d-6385-4d4a-82ee-caaed6f0f816
# ╠═7d8e1b2c-f5ef-4d5c-98a1-cc3e39a230d3
# ╠═8b06f6e6-f41a-4cc1-b6c9-74f9d49cbc8b
# ╠═f55fa499-7dd2-4cf9-92a6-f571f3b8c1c7
# ╠═256d5cba-dae8-4e38-9251-0082b34cb2fe
# ╠═7b997c40-aa31-4a81-aeac-771d3f11299f
# ╠═0270e6c7-d320-443f-aab0-bf0f9f347276
# ╠═7728df24-5be8-4dbf-86ee-92d5ca059090
# ╠═a59d68a9-aff8-42e8-8ceb-cace9ba976fa
# ╠═3a52e288-4b96-4ef2-a5ee-a83d9de93494
# ╠═6c185186-9f5d-4a83-89fb-511150426f37
# ╠═4f3d5231-0077-45f2-95e8-4fa13582c5dd
# ╠═8e4a5d6b-e398-4514-96f4-ea77d5f31d27
# ╠═6f8e93f8-e573-4901-9403-30a1602309c3
# ╠═69c93dc5-47b7-4f77-8c0a-8b8a6c9b8685
# ╠═90fb4dd3-3650-481e-b0ec-48a406a6c343
# ╠═f3008fb9-5565-4167-87c1-2842b11091e3
# ╠═8524447b-6d46-4cfd-bcad-8cf28382964c
# ╠═7c4ff26a-f163-4046-b8bb-87e196c62b03
# ╠═2615d1db-9c29-429b-8d50-83e5cf1c4198
# ╠═eb3c9751-b7a0-4577-8ded-0ac94eae0b5a
