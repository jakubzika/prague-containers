### A Pluto.jl notebook ###
# v0.19.4

using Markdown
using InteractiveUtils

# ╔═╡ 38b58e86-c215-11ec-29ea-559bbc376182
begin
  import Pkg
  Pkg.activate(Base.current_project())
end

# ╔═╡ f448a4a1-9633-4e14-8f52-7113c34c70c7
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

# ╔═╡ 4d8dc335-39ac-4069-ab54-d69e40313a96
include("src/data-conversion.jl")

# ╔═╡ 7220716e-f5b4-4872-8a12-ece449080879
include("src/containerCapacity.jl")

# ╔═╡ 18071f96-1bbc-4b33-b550-afba075b2f10
plotly()

# ╔═╡ 6a5c1745-c673-4b91-85ca-daaabfe764d5
trashTypeId = 7

# ╔═╡ 713021cf-aad1-4ccd-a584-1a3a1e809884
paperBuildings = DataConversion.getFilteredBuildingsGDAL(trashTypeId);

# ╔═╡ 46270d88-5875-4112-ae55-9ff3ec81c91f
buildings = DataConversion.getCadastralRegistryDataGDAL("BUDOVY_DEF");

# ╔═╡ 51dc9eac-fa0c-4b89-a1a3-01ee41b4fbd8
population = CSV.File("downloaded-data/calcualted-population.csv", stringtype=String) |> DataFrame;

# ╔═╡ d42fc5c1-3ae1-46b4-85a0-7902b8953cd9
landUse = CSV.File("downloaded-data/building-land-use.csv", stringtype=String) |> DataFrame;

# ╔═╡ dc6116b8-06b4-405e-b1a6-09d23fe86081
landUse[!, :ID_2] = string.(landUse.ID_2);

# ╔═╡ 47af98c9-4dd6-49b0-9903-63ad50d273e9
population[!, :ID_2] = string.(population.ID_2);

# ╔═╡ a2ba9c89-2ffd-4017-b7b7-59ba8bb892cf
joined =
  @pipe leftjoin(buildings, population, on=:ID_2) |>
        leftjoin(_, landUse, on=:ID_2, matchmissing=:equal) |>
        unique(_, :ID_2);

# ╔═╡ b2a8472b-e1c1-40e7-a351-12c6e0e51025
joined.population[ismissing.(joined.population)] .= 0;

# ╔═╡ b3ccbd66-09be-48c8-9789-096630617ad1
selected = select(joined, :geom, :ID_2, :population, :landUseCode);

# ╔═╡ 939ed401-0fad-46d7-8aa1-7b5ad88cb311
nearestContainers = DataConversion.getNearestContainerForBuildings(trashTypeId);

# ╔═╡ 53daf3bf-61eb-4d2d-ba14-323cc9274fca
nearestContainers[!, :buildingId2] = string.(nearestContainers.buildingId2);

# ╔═╡ 3033f9cb-bfb8-40cc-9dc7-85eb338511f5
nearestJoined = innerjoin(nearestContainers, selected, on=:buildingId2 => :ID_2);

# ╔═╡ d076669c-d1f6-4b06-9d80-d74765630356
grouped = groupby(nearestJoined, :containerId);

# ╔═╡ 18dac483-41df-4e67-b8f4-adb333c88099
peoplePerContainer = combine(grouped, :population => sum)

# ╔═╡ 9b1e967c-57a4-401b-8ff4-9a64c3839c85
sort(peoplePerContainer,)

# ╔═╡ 13ce0c0d-e3b7-4c87-8b9c-04be3cadb4c7
histogram(peoplePerContainer.population_sum, bins=200, orientation=:v)

# ╔═╡ e1001d93-074b-4f12-a362-20d655847941
mean(peoplePerContainer.population_sum)

# ╔═╡ 4604609d-c3bf-4645-a640-ca3b04a5a8f9
std(peoplePerContainer.population_sum)

# ╔═╡ 52bf2bca-fdea-49c8-b1e4-d8b0a1ff8707
locations = DataConversion.getPublicContainerLocationsByTrashTypeGDAL(trashTypeId);

# ╔═╡ 1204ae02-a5d7-4bf8-97ce-a3bdd673fe8d
containerDemand = leftjoin(locations, peoplePerContainer, on=:id => :containerId)

# ╔═╡ f5036234-1ca6-4c2a-a8a4-7812b82c4a16
containerDemand.population_sum[ismissing.(containerDemand.population_sum)] .= 0;

# ╔═╡ 4519dff3-fd0b-4163-bad7-bf543ed9cb6a
containerDemand.containers[1][1]

# ╔═╡ 85ce1133-eb09-4f48-babd-6c7052e5328a
begin
  for r in eachrow(containerDemand)
    r.containers = filter(c -> c[:trash_type][:id] == 5, r.containers)
  end

  for r in eachrow(containerDemand)
    for c in r.containers
      frequency = ContainerCapacity.getContainerMonthlyCleaningFrequency(c[:cleaning_frequency][:id])
      capacity = ContainerCapacity.getContainerCapacity(c[:container_type])
      maxMonthlyThroughput = frequency * capacity
      c[:monthly_throughput] = maxMonthlyThroughput
    end
  end
end

# ╔═╡ 001fce51-8a29-4d64-8b21-1d08a17ba9c9
function getRowThroughput(containers)
  reduce(containers, init=0) do acc, i
    try
      acc + i[:monthly_throughput]
    catch e
      # throw(e)
    end

  end
end

# ╔═╡ 8dd587c1-fbc1-4e15-976b-ac15c12e579b
withThroughput = transform(containerDemand,
  :containers =>
    ByRow(getRowThroughput)
    =>
      :location_throughput
);

# ╔═╡ 27fa678c-8df9-4d8d-9392-c90a512e2d66
demandNormalized = transform(withThroughput,
  [:location_throughput, :population_sum] =>
    ByRow((t, p) -> t == 0 ? 0 : p / t)
    =>
      :normalized_demand
);

# ╔═╡ 24919c40-d95c-4c83-a5be-e503f4e480bd
demandNormalized[!, :location_throughput] = Float32.(demandNormalized.location_throughput);

# ╔═╡ e8b1e900-603e-455f-84a5-21499683cde3
demandNormalized[!, :normalized_demand] = Float32.(demandNormalized.normalized_demand);

# ╔═╡ 743cb4ee-5ad4-4121-a045-d4c2c177456c
demandCopy = DataFrame(demandNormalized);

# ╔═╡ f50b796d-2f88-4f1c-be98-3138a77d7d49
DataConversion.convertDataFrameDictToJSONColumn!(demandCopy, :containers);

# ╔═╡ 9b6f39e0-c311-41ea-ab08-d59813a870fa
function computeDemandForTrashType(trashTypeId::Int64)


end

# ╔═╡ 8c78ca20-2ceb-4798-bf56-fe9b1c1eaf78
GDF.write("tmp/$(trashTypeId)-container-demand-normalized.geojson", demandCopy)

# ╔═╡ c57fdf9d-2456-4b14-9b52-469976cfcd43
# DataConversion.convertDataFrameDictToJSONColumn!(containerDemand, :containers);

# ╔═╡ 7c082a34-8f16-49a0-9db7-0bc908cf830c
# GDF.write("tmp/paper-container-demand.geojson", containerDemand)

# ╔═╡ 67ee66d1-409e-43e6-8711-e0fb14e31bcf
# GDF.write("downloaded-data/building-populations.geojson", select(joined, :geom, :ID_2, :population, :landUseCode))

# ╔═╡ Cell order:
# ╠═38b58e86-c215-11ec-29ea-559bbc376182
# ╠═f448a4a1-9633-4e14-8f52-7113c34c70c7
# ╠═18071f96-1bbc-4b33-b550-afba075b2f10
# ╠═4d8dc335-39ac-4069-ab54-d69e40313a96
# ╠═7220716e-f5b4-4872-8a12-ece449080879
# ╠═6a5c1745-c673-4b91-85ca-daaabfe764d5
# ╠═713021cf-aad1-4ccd-a584-1a3a1e809884
# ╠═46270d88-5875-4112-ae55-9ff3ec81c91f
# ╠═51dc9eac-fa0c-4b89-a1a3-01ee41b4fbd8
# ╠═d42fc5c1-3ae1-46b4-85a0-7902b8953cd9
# ╠═dc6116b8-06b4-405e-b1a6-09d23fe86081
# ╠═47af98c9-4dd6-49b0-9903-63ad50d273e9
# ╠═a2ba9c89-2ffd-4017-b7b7-59ba8bb892cf
# ╠═b2a8472b-e1c1-40e7-a351-12c6e0e51025
# ╠═b3ccbd66-09be-48c8-9789-096630617ad1
# ╠═939ed401-0fad-46d7-8aa1-7b5ad88cb311
# ╠═53daf3bf-61eb-4d2d-ba14-323cc9274fca
# ╠═3033f9cb-bfb8-40cc-9dc7-85eb338511f5
# ╠═d076669c-d1f6-4b06-9d80-d74765630356
# ╠═18dac483-41df-4e67-b8f4-adb333c88099
# ╠═9b1e967c-57a4-401b-8ff4-9a64c3839c85
# ╠═13ce0c0d-e3b7-4c87-8b9c-04be3cadb4c7
# ╠═e1001d93-074b-4f12-a362-20d655847941
# ╠═4604609d-c3bf-4645-a640-ca3b04a5a8f9
# ╠═52bf2bca-fdea-49c8-b1e4-d8b0a1ff8707
# ╠═1204ae02-a5d7-4bf8-97ce-a3bdd673fe8d
# ╠═f5036234-1ca6-4c2a-a8a4-7812b82c4a16
# ╠═4519dff3-fd0b-4163-bad7-bf543ed9cb6a
# ╠═85ce1133-eb09-4f48-babd-6c7052e5328a
# ╠═001fce51-8a29-4d64-8b21-1d08a17ba9c9
# ╠═8dd587c1-fbc1-4e15-976b-ac15c12e579b
# ╠═27fa678c-8df9-4d8d-9392-c90a512e2d66
# ╠═24919c40-d95c-4c83-a5be-e503f4e480bd
# ╠═e8b1e900-603e-455f-84a5-21499683cde3
# ╠═743cb4ee-5ad4-4121-a045-d4c2c177456c
# ╠═f50b796d-2f88-4f1c-be98-3138a77d7d49
# ╠═9b6f39e0-c311-41ea-ab08-d59813a870fa
# ╠═8c78ca20-2ceb-4798-bf56-fe9b1c1eaf78
# ╠═c57fdf9d-2456-4b14-9b52-469976cfcd43
# ╠═7c082a34-8f16-49a0-9db7-0bc908cf830c
# ╠═67ee66d1-409e-43e6-8711-e0fb14e31bcf
