### A Pluto.jl notebook ###
# v0.18.0

using Markdown
using InteractiveUtils

# ╔═╡ 0616b447-c08e-41b6-9a2c-b66b786b3727
begin
	import Pkg
	Pkg.activate(Base.current_project())
end

# ╔═╡ 55c18cba-c192-11ec-0c65-fb2b757da25e
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
end

# ╔═╡ 6d2984bf-5775-4e3a-9372-297aaad8e928
include("src/data-conversion.jl")

# ╔═╡ 6098b95b-ddab-4a83-922e-2c5d6bd87348


# ╔═╡ 8d96a51d-8117-4f14-b4b0-8d53e9498b1a
validCodes = [
	"BD"
	"BQ"
	"BRR"
	"BRV"
	"OKK"
	"OKM"
	"OPP"
	"OQ"
	"OUM"
	"OUO"
	"OUS"
	"OUZ"
	"SAM"
	"RAZ"
	"SLU"
	"OZA"
]


# ╔═╡ 23c986a1-5ded-42b6-88f5-99498057c1d1
popCounts = CSV.File("CR_L4_KU.csv") |> DataFrame

# ╔═╡ fa34d846-b8e5-445a-8321-b0a702e40051
popCounts.count |> sum

# ╔═╡ 12cec346-57a4-4a73-9999-504a1126c10d
split("sda,das",",")

# ╔═╡ 0d0e7cab-106a-4b9e-b026-86cba67f9697
begin
	b = [1,2]
	append!(b,10)
	append!(b,[2,3,4])
end

# ╔═╡ 9276026e-4636-41a0-b367-c840faf81c0c
function isValidCategory(categories)
	cs = split(categories, ",")
	return any(c -> c ∈ validCodes,cs)
end

# ╔═╡ 5a57d747-544c-4a23-af81-706032f7c192
isValidCategory("BRV,OUS")

# ╔═╡ bfcc55e0-8869-459e-ae51-ff883d490664
landUsage = GDF.read("URK_SS_VyuzitiZakl_p_shp/URK_SS_VyuzitiZakl_p.shp")

# ╔═╡ db2053ab-126c-46bd-899c-2a8755a36f68
# filteredLandUsage = filter(
#   :KOD => c -> c ∈ validCodes,
#   landUsage)
filteredLandUsage = landUsage


# ╔═╡ 63ced2bc-aee1-417e-b4f1-e4429e0f3d07
zonesSearchTree = DataConversion.getGDALSearchTree(filteredLandUsage)

# ╔═╡ 6ca9a8dd-03be-486a-8a56-a32c2891ce38
df = DataFrame(CSV.File("downloaded-data/buildings-with-floor-area.csv"))

# ╔═╡ 61f2b462-620e-463b-af4f-53e8c1f55e08
allBuildingShapes = DataConversion.getCadastralRegistryDataGDAL("BUDOVY_P")

# ╔═╡ 2f09bc7b-4d8a-404f-94cc-2541ea00e9a0
df[!,:buildingId] = string.(df.buildingId)

# ╔═╡ abc9f9b3-8a07-4184-bb3a-46dfa98c3aa9
joined = innerjoin(allBuildingShapes, df, on=:ID_2 => :buildingId)
	

# ╔═╡ 8d535cee-2754-4aa7-a434-2576abd2f219
joined[!,:landUseCode] = Union{Missing, String}[missing for i in 1:nrow(joined)]

# ╔═╡ 6c708019-dd72-4ff1-b11a-03d0f2ee6617
joined

# ╔═╡ f996fdb6-97cf-4ee4-ab85-f1f6ed31448f
for (i,r) in enumerate(eachrow(joined))

	point = DataConversion.archGDALPointToStaticArrayPoint(r.geom |> AGDAL.centroid)
	
	nearestIdx, distances = knn(zonesSearchTree, point, 6)
	for nIdx in nearestIdx
		zone = filteredLandUsage[nIdx,:]
		intersection = nothing
		try
			intersection = AGDAL.intersection(zone.geom, r.geom)
		catch e
			continue
		end
		intersectionFactor = AGDAL.geomarea(intersection) / AGDAL.geomarea(r.geom)
		if intersectionFactor > 0.8
			kod = [zone.KOD]
			if(!ismissing(zone.KOD_POLYFC))
				append!(kod, split(zone.KOD_POLYFC,","))
			end
			r.landUseCode = join(kod,",")
			break
		end
		
	end
	
end

# ╔═╡ a03d4140-f077-4d76-8ba5-fc1d05c4bb2f
unique(joined.landUseCode)

# ╔═╡ ea4f2a3e-0f5a-4ae1-a88b-bdecbad5e5a7
adjusted = select(joined, :ID_2, :area, :adjustedArea, :cadastralZoneId, :landUseCode)

# ╔═╡ 1fddd85d-4d13-48b3-b4bf-e08647f8462a
unique(adjusted.landUseCode)

# ╔═╡ 6b51e73a-bd21-4bab-ae0f-8efac617209f
buildingTypeMapping = select(adjusted, :ID_2, :landUseCode)

# ╔═╡ 17d947ef-1c22-47e5-afc3-9933896f377e
CSV.write("downloaded-data/building-land-use.csv", buildingTypeMapping)

# ╔═╡ ea5fbe79-af0e-4b29-8c26-f49b9f0a5fdd
adjustedFiltered = filter(:landUseCode => c -> c !== missing && isValidCategory(c), adjusted)

# ╔═╡ f54ab33b-3005-4898-a166-2390da787163
select!(adjustedFiltered, :ID_2, :area, :adjustedArea, :cadastralZoneId)

# ╔═╡ 7b258a7f-efe7-4c0a-a017-f0426529c348
gs = groupby(adjustedFiltered, :cadastralZoneId)

# ╔═╡ 9b7a5f6e-6aed-4da4-8f3a-1139a9fa90bb
c = innerjoin(
	combine(gs, :adjustedArea => sum),
	popCounts,
	on = :cadastralZoneId => :Id,
	matchmissing = :notequal
)

# ╔═╡ c868c52d-18e3-465e-9ab8-35b017d159ab
densities = transform(c,:, [:count,:adjustedArea_sum] =>  ByRow(/) => :densityToAreaAdjusted)

# ╔═╡ ad6fdf9b-d1f2-4d3c-bdb5-789a29d67318
f = rightjoin(adjustedFiltered, densities, on = :cadastralZoneId, matchmissing = :notequal)

# ╔═╡ 262e4d4f-23c3-4acb-bf21-39d236b94290
population = transform(f, :, [:adjustedArea, :densityToAreaAdjusted] => ByRow(*) => :population)

# ╔═╡ db3d6187-d051-4cd3-b458-7599ffc00e01
sum(population.population)

# ╔═╡ a083ad8d-8634-44e9-902e-c845caa3abc6
population.ID_2 |> unique |> length

# ╔═╡ 8e3e83a8-2dc6-4753-8cf1-281c68b5e2fd
CSV.write("downloaded-data/calcualted-population.csv", population)

# ╔═╡ Cell order:
# ╠═0616b447-c08e-41b6-9a2c-b66b786b3727
# ╠═55c18cba-c192-11ec-0c65-fb2b757da25e
# ╠═6098b95b-ddab-4a83-922e-2c5d6bd87348
# ╠═6d2984bf-5775-4e3a-9372-297aaad8e928
# ╠═8d96a51d-8117-4f14-b4b0-8d53e9498b1a
# ╠═23c986a1-5ded-42b6-88f5-99498057c1d1
# ╠═fa34d846-b8e5-445a-8321-b0a702e40051
# ╠═12cec346-57a4-4a73-9999-504a1126c10d
# ╠═0d0e7cab-106a-4b9e-b026-86cba67f9697
# ╠═9276026e-4636-41a0-b367-c840faf81c0c
# ╠═5a57d747-544c-4a23-af81-706032f7c192
# ╠═bfcc55e0-8869-459e-ae51-ff883d490664
# ╠═db2053ab-126c-46bd-899c-2a8755a36f68
# ╠═63ced2bc-aee1-417e-b4f1-e4429e0f3d07
# ╠═6ca9a8dd-03be-486a-8a56-a32c2891ce38
# ╠═61f2b462-620e-463b-af4f-53e8c1f55e08
# ╠═2f09bc7b-4d8a-404f-94cc-2541ea00e9a0
# ╠═abc9f9b3-8a07-4184-bb3a-46dfa98c3aa9
# ╠═8d535cee-2754-4aa7-a434-2576abd2f219
# ╠═6c708019-dd72-4ff1-b11a-03d0f2ee6617
# ╠═f996fdb6-97cf-4ee4-ab85-f1f6ed31448f
# ╠═a03d4140-f077-4d76-8ba5-fc1d05c4bb2f
# ╠═ea4f2a3e-0f5a-4ae1-a88b-bdecbad5e5a7
# ╠═1fddd85d-4d13-48b3-b4bf-e08647f8462a
# ╠═6b51e73a-bd21-4bab-ae0f-8efac617209f
# ╠═17d947ef-1c22-47e5-afc3-9933896f377e
# ╠═ea5fbe79-af0e-4b29-8c26-f49b9f0a5fdd
# ╠═f54ab33b-3005-4898-a166-2390da787163
# ╠═7b258a7f-efe7-4c0a-a017-f0426529c348
# ╠═9b7a5f6e-6aed-4da4-8f3a-1139a9fa90bb
# ╠═c868c52d-18e3-465e-9ab8-35b017d159ab
# ╠═ad6fdf9b-d1f2-4d3c-bdb5-789a29d67318
# ╠═262e4d4f-23c3-4acb-bf21-39d236b94290
# ╠═db3d6187-d051-4cd3-b458-7599ffc00e01
# ╠═a083ad8d-8634-44e9-902e-c845caa3abc6
# ╠═8e3e83a8-2dc6-4753-8cf1-281c68b5e2fd
