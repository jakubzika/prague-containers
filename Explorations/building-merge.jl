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

# ╔═╡ 1800109e-0813-4a4c-8a5c-b42491a61bcc
begin
	import Pkg
	Pkg.activate(Base.current_project())
end

# ╔═╡ e0ceefa1-7f43-44e6-9c97-d5e1db0bfed8
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
end

# ╔═╡ a3ffd585-ed19-40d7-811b-91df971baa36
using CSV

# ╔═╡ 4306bb98-1423-4616-9762-03cd87cc6f43
include("src/data-conversion.jl")

# ╔═╡ f50b0b34-c156-11ec-1958-63b52c3be452


# ╔═╡ e20b1b5c-851c-4434-8992-d0de850783d4
begin
    println("Loading data")
    buildingFloors = DataConversion.getBuildingsWithNumberOfFloorsGDAL()
    allBuildings = DataConversion.getCadastralRegistryDataGDAL("BUDOVY_DEF")
    allBuildingShapes = DataConversion.getCadastralRegistryDataGDAL("BUDOVY_P", log=true)
    println("Loading finished")
end

# ╔═╡ 7ec42df2-e268-4a48-b46d-f70d8aa389e0
cadastralZones = DataConversion.getCadastralTeritories()

# ╔═╡ 9783a376-80d7-42d4-aab8-679d5c396d22
begin
    j = 1:1000
    c = plot()
    for i in j
        plot!(buildingFloors.geom[i] |> coordinates |> Polygon)
        plot!(buildingFloors.geom[i] |> AGDAL.centroid |> coordinates |> Point)
    end 
    c
end


# ╔═╡ e9810f8a-d24b-44a1-a22a-837d517aa9e4
createMappingDataFrame() = DataFrame(
    buildingId = String[],
    numberOfFloors = Integer[],
    area = AbstractFloat[],
    heightAdjustedArea = AbstractFloat[],
    numberOfPeople = Integer[],
    wasEmpty = Bool[]
)

# ╔═╡ 45f6cd8c-94c8-483b-86fb-cf1d49c1e47a
emptyMappingRow(building::DataFrameRow) = [
    # building.ID_2,
    # 1,
]

# ╔═╡ 8764ab78-f884-470a-b41d-e98c25ef4c3a
mappingRow(building::DataFrameRow, buildingFloor::DataFrameRow) = buildingFloor

# ╔═╡ c09ccb8c-3374-4083-93d2-83187926e863
buildingsBallTree = DataConversion.getGDALSearchTree(allBuildingShapes)

# ╔═╡ 57ab6105-9963-4222-8fde-0fe26c864a40
buildingFloorsBallTree = DataConversion.getGDALSearchTree(buildingFloors)

# ╔═╡ 8f8d8e6b-2bed-44af-be70-58df46a97672
allBuildingShapes

# ╔═╡ d9298488-3bca-4f00-8633-fb4612857e64
function getBuildingFloorMapping()
    resMapping = Dict()

    for building in eachrow(allBuildingShapes)
        resMapping[building.ID_2] = Vector()
    end
    distFn = Haversine()


    for bf in eachrow(buildingFloors)
        bfCentroid = AGDAL.centroid(bf.geom)
		bfInPoint = AGDAL.pointonsurface(bf.geom)
        point = DataConversion.archGDALPointToStaticArrayPoint(bfCentroid)
        
        nearestBuildingIdxs, distances = knn(buildingsBallTree, point, 8)
        for nearestBuildingIdx in nearestBuildingIdxs
            nearestBuildingShape = allBuildingShapes[nearestBuildingIdx, :]
			intersection = nothing
			try
            	intersection = AGDAL.intersection(nearestBuildingShape.geom, bf.geom)
			catch
				continue
			end
			if(intersection === nothing)
				continue
			end
			intersectionFactor = AGDAL.geomarea(intersection) / AGDAL.geomarea(bf.geom)
            if (
    #             distFn(
    #                 nearestBuildingShape.geom |> AGDAL.pointonsurface |> coordinates,
    #                 bf.geom |> AGDAL.pointonsurface |> coordinates
				# ) < 10  
				AGDAL.within(bfInPoint, nearestBuildingShape.geom) || 
				intersectionFactor > 0.9
				# && abs(AGDAL.geomarea(bf.geom) - AGDAL.geomarea(nearestBuildingShape.geom)) < 1e-8
			)
				if(!haskey(resMapping, nearestBuildingShape.ID_2))
					resMapping[nearestBuildingShape.ID_2] = Vector()
				end
				push!(resMapping[nearestBuildingShape.ID_2], mappingRow(nearestBuildingShape, bf))
				continue
				#resMapping[nearestBuildingShape.ID_2] = mappingRow(nearestBuildingShape, bf)
				
            end
        end
    end

    return resMapping
end

# ╔═╡ 3c4801d1-ba53-4642-9609-689a880b8d08
res = getBuildingFloorMapping()

# ╔═╡ 0328186d-a1cb-47f7-90d0-e39d3c4c9f2b


# ╔═╡ 18fa847b-fa67-4565-9375-10aafbd555e9
filter(c -> length(c) == 0,collect(values(res))) |> length

# ╔═╡ 51c9b077-cf88-4bd7-be6b-84417e152b2a
values(res)

# ╔═╡ cd442eb4-441b-44ab-a8fe-4b7e4a896cad
resZip = zip(keys(res), values(res)) |> collect

# ╔═╡ 6d7571a1-c353-44b4-920e-73377c939e1d
resDoubles = map(resZip) do (buildingId, bf)
	(
		filter(:ID_2 => ==(buildingId),allBuildingShapes)[1,:],
		bf
	)
end

# ╔═╡ 89025ada-2b96-410d-ae96-75a854243f58
md"""
something $(@bind i NumberField(1:length(resDoubles)))
"""

# ╔═╡ 9283c60e-9017-4f49-81eb-d0dd8d861b2b
resDoubles[1]

# ╔═╡ dfb932a2-6b1b-46f4-8e66-c8512d4eb5e3
begin
	(b, f) = resDoubles[i]
	p = plot(b.geom, color = :blue)
	for k in f
		plot!(k.geom, color="#ee000055")
		# plot!(k.geom |> AGDAL.centroid, color=:red)
		plot!(k.geom |> AGDAL.pointonsurface, color=:yellow)
	end
	p
	plot!(b.geom |> AGDAL.centroid, color = :blue)
	#plot!(b.geom |> AGDAL.pointonsurface, color = :black)
	# plot!(f.geom |> AGDAL.centroid)
end

# ╔═╡ 0f223b94-1800-4b04-9b16-43ebdb36faf9
length(f)

# ╔═╡ 4bf3d38d-800a-4377-8ea7-e9f7c2bb7946
begin
	ab = AGDAL.geomarea(b.geom)
	af = AGDAL.geomarea(f.geom)
	(
		ab,
		af,
		ab-af
	)
end

# ╔═╡ 52c2fd78-983e-4af0-a446-67c5961679bc
names(buildingFloors)

# ╔═╡ 91ed9eae-2452-4336-8ddf-41eb6e6aba14
map(eachrow(buildingFloors)) do bf
	AGDAL.geomarea(bf.geom)
end

# ╔═╡ d601707e-81f5-496b-b3ef-51e03009f46b
buildingFloors

# ╔═╡ 40b3c04d-eb30-43b6-b7e2-f7e01175328c
convert.(Float64, buildingFloors.POČET_POD)

# ╔═╡ b238260c-f8e5-4365-aad3-5c343430b8f5
dot(convert.(Float64,buildingFloors.POČET_POD),buildingFloors.Shape_Area) / sum(buildingFloors.Shape_Area)

# ╔═╡ ccd75c76-21c6-4fd0-94c2-79594e55fb80
sum(buildingFloors.POČET_POD)/nrow(buildingFloors)

# ╔═╡ f05aa5be-f323-4e72-997c-ee3f1e3a7124
function calculateBuildingArea(building::DataFrameRow, buildingFloors::Vector{Any})
	pie = building.geom
	totalArea = 0
	for bf in buildingFloors
		intersection = nothing
		try
			intersection = AGDAL.intersection(bf.geom, pie)
			pie = AGDAL.difference(pie, intersection)
		catch e
			continue
		end
		totalArea += bf.POČET_POD * AGDAL.geomarea(intersection)
	end
	totalArea += 3 * AGDAL.geomarea(pie)
	return totalArea
end

# ╔═╡ 8fc5241b-0bfb-44f3-a312-055d136ccb09
function getCadastralZoneForPoint(cadastralZones::DataFrame, point::Any)
	res = filter(cadastralZones) do zone
		AGDAL.within(point, zone.geom)
	end
	if(nrow(res) == 1) 
		return res[1,:]
	end
	return nothing
end

# ╔═╡ 7908dc7e-9a00-4526-b472-52d1db5c65bb
buildingAreas = map(resDoubles) do (b, bfs)
	(
		b,
		calculateBuildingArea(b,bfs),
		getCadastralZoneForPoint(cadastralZones, b.geom |> AGDAL.centroid)
	)
end

# ╔═╡ 1f122bfc-a052-459b-b74c-15d3fa4d9aa6
begin
	df = DataFrame(
		buildingId=String[],
		area=AbstractFloat[],
		adjustedArea=AbstractFloat[],
		cadastralZoneId=Union{Integer, Missing}[]
	)

	for i in buildingAreas
		
		push!(df, [
			i[1].ID_2,
			AGDAL.geomarea(i[1].geom),
			i[2],
			isnothing(i[3]) ? missing : i[3].KATUZE_KOD
		])
	end
	df
	
end

# ╔═╡ 27fa8408-36f9-4d28-a4c4-4529b633c597
groups = groupby(df, :cadastralZoneId)

# ╔═╡ 26b58709-7b16-4d66-a9a7-82df1575fd8c
# ╠═╡ disabled = true
#=╠═╡
CSV.write("downloaded-data/buildings-with-floor-area.csv", df)
  ╠═╡ =#

# ╔═╡ 41e143c9-18a1-40ac-8021-0c46361ff538
combine(groups, :adjustedArea => sum)

# ╔═╡ Cell order:
# ╠═f50b0b34-c156-11ec-1958-63b52c3be452
# ╠═1800109e-0813-4a4c-8a5c-b42491a61bcc
# ╠═e0ceefa1-7f43-44e6-9c97-d5e1db0bfed8
# ╠═4306bb98-1423-4616-9762-03cd87cc6f43
# ╠═e20b1b5c-851c-4434-8992-d0de850783d4
# ╠═7ec42df2-e268-4a48-b46d-f70d8aa389e0
# ╠═9783a376-80d7-42d4-aab8-679d5c396d22
# ╠═e9810f8a-d24b-44a1-a22a-837d517aa9e4
# ╠═45f6cd8c-94c8-483b-86fb-cf1d49c1e47a
# ╠═8764ab78-f884-470a-b41d-e98c25ef4c3a
# ╠═c09ccb8c-3374-4083-93d2-83187926e863
# ╠═57ab6105-9963-4222-8fde-0fe26c864a40
# ╠═8f8d8e6b-2bed-44af-be70-58df46a97672
# ╠═d9298488-3bca-4f00-8633-fb4612857e64
# ╠═3c4801d1-ba53-4642-9609-689a880b8d08
# ╠═0328186d-a1cb-47f7-90d0-e39d3c4c9f2b
# ╠═18fa847b-fa67-4565-9375-10aafbd555e9
# ╠═51c9b077-cf88-4bd7-be6b-84417e152b2a
# ╠═cd442eb4-441b-44ab-a8fe-4b7e4a896cad
# ╠═6d7571a1-c353-44b4-920e-73377c939e1d
# ╠═89025ada-2b96-410d-ae96-75a854243f58
# ╠═9283c60e-9017-4f49-81eb-d0dd8d861b2b
# ╠═dfb932a2-6b1b-46f4-8e66-c8512d4eb5e3
# ╠═0f223b94-1800-4b04-9b16-43ebdb36faf9
# ╠═4bf3d38d-800a-4377-8ea7-e9f7c2bb7946
# ╠═52c2fd78-983e-4af0-a446-67c5961679bc
# ╠═91ed9eae-2452-4336-8ddf-41eb6e6aba14
# ╠═d601707e-81f5-496b-b3ef-51e03009f46b
# ╠═40b3c04d-eb30-43b6-b7e2-f7e01175328c
# ╠═b238260c-f8e5-4365-aad3-5c343430b8f5
# ╠═ccd75c76-21c6-4fd0-94c2-79594e55fb80
# ╠═f05aa5be-f323-4e72-997c-ee3f1e3a7124
# ╠═8fc5241b-0bfb-44f3-a312-055d136ccb09
# ╠═7908dc7e-9a00-4526-b472-52d1db5c65bb
# ╠═1f122bfc-a052-459b-b74c-15d3fa4d9aa6
# ╠═27fa8408-36f9-4d28-a4c4-4529b633c597
# ╠═a3ffd585-ed19-40d7-811b-91df971baa36
# ╠═26b58709-7b16-4d66-a9a7-82df1575fd8c
# ╠═41e143c9-18a1-40ac-8021-0c46361ff538
