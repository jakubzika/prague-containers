### A Pluto.jl notebook ###
# v0.18.0

using Markdown
using InteractiveUtils

# ╔═╡ d3082dd2-2768-4d8f-a6f6-943fc3387d2d
begin
	import Pkg
	Pkg.activate(Base.current_project())
end

# ╔═╡ ddd9b0aa-c304-11ec-36f3-2bec0f5041b6
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
end

# ╔═╡ 78117ce4-d61c-45dc-ab05-9bdd5f534aad
include("src/data-conversion.jl")

# ╔═╡ 1dc328d0-6a4e-4b52-b040-bb4f782c5e71
include("src/containerCapacity.jl")

# ╔═╡ 65afc588-c4ab-4243-934e-209a3a7560f7
plotlyjs()

# ╔═╡ 6fde3296-4ebe-4bf1-9906-b81bc2bae7aa
containerLocations = DataConversion.getContainerLocationsGDAL();

# ╔═╡ 5c2bea02-dc19-4e9b-9ac3-1709f2e58af9
allContainers = @pipe containerLocations.containers |> filter(!isnothing,_)

# ╔═╡ cfc6a160-9791-4719-874c-34c52811c32b
flatContainers = [(allContainers...)...]

# ╔═╡ d3bbd77f-4a43-45da-a904-ceaed75e479f
conts = DataConversion.getContainersGDAL()

# ╔═╡ 2850421e-62e9-43d2-889f-0717badf67e8
map(conts.container_type |> unique) do t
	if(t === missing) 
		return missing
	end

	s = split(t," ")
	cs = s[1]
	c = parse(Int64, cs)
	
end

# ╔═╡ 9eac34d1-ffea-421e-9bec-e6ca03e8dc64
begin
	ids = [c[:cleaning_frequency][:id] for c in flatContainers]
	
	groups = ids |> @groupby(_) |> collect
	groupSizes = map(groups) do g
	    (g[1], length(g))
	end
	
	ids = [x[1] for x in groupSizes]
	counts = [x[2] for x in groupSizes]
end

# ╔═╡ 2504681d-b0c0-48b8-9590-5503309a257c
begin
	locations = Dict()

	for i in 1:8
		locations[i] = DataConversion.getPublicContainerLocationsByTrashTypeGDAL(i)
	end
end

# ╔═╡ b74545cd-d371-40f4-adf1-7f714408c9f3
locations[1]

# ╔═╡ 7c1cc5fe-d517-4585-99bf-6bcf4344ae94
formatNum(c) = isnothing(c) ? 0 : round(c * 100) / 100

# ╔═╡ d9989a7e-188b-481c-94af-e6b30f71f483
begin
	p = plot(xformatter=x->format( x, precision=2 ),)

	map(1:8) do i
		containerLocations = locations[i];
		allContainers = @pipe containerLocations.containers |>
			filter(!isnothing,_)
			
		flatContainers = @pipe [(allContainers...)...] |> 
			filter(c -> c[:trash_type][:id] == i, _)

	

			ids = [c[:cleaning_frequency][:id] for c in flatContainers]
	
		groups = ids |> @groupby(_) |> collect
		groupSizes = map(groups) do g
			(g[1], length(g))
		end

		alc = flatContainers |> length
		
		ids = [
			ContainerCapacity.getContainerMonthlyCleaningFrequency(x[1],1) |> formatNum
			# x[1]
			for x in groupSizes
		]
		
		counts = [x[2] for x in groupSizes]

		df = DataFrame(id=ids, count=counts)

		sort!(df, :id)
		size(100,100)
		f = bar(
			string.(df.id),df.count,
			fontfamily="Computer Modern",
			color=DataConversion.trashTypeIdToColor[i],
			label=DataConversion.trashTypeIdToDescription[i],
			xformatter=x->format( x, precision=0),
			ylabel="Počet kontejnerů",
			xlabel="Měsíční frekvence svozu odpadu"
			# ylims=(0,4000)
		)
		savefig(f, "plots/waste-pick-frequencies-$(i).pdf",
			# width=100,
			# height=100
		)
	end
end

# ╔═╡ Cell order:
# ╠═d3082dd2-2768-4d8f-a6f6-943fc3387d2d
# ╠═ddd9b0aa-c304-11ec-36f3-2bec0f5041b6
# ╠═78117ce4-d61c-45dc-ab05-9bdd5f534aad
# ╠═1dc328d0-6a4e-4b52-b040-bb4f782c5e71
# ╠═65afc588-c4ab-4243-934e-209a3a7560f7
# ╠═6fde3296-4ebe-4bf1-9906-b81bc2bae7aa
# ╠═5c2bea02-dc19-4e9b-9ac3-1709f2e58af9
# ╠═cfc6a160-9791-4719-874c-34c52811c32b
# ╠═d3bbd77f-4a43-45da-a904-ceaed75e479f
# ╠═2850421e-62e9-43d2-889f-0717badf67e8
# ╠═9eac34d1-ffea-421e-9bec-e6ca03e8dc64
# ╠═2504681d-b0c0-48b8-9590-5503309a257c
# ╠═b74545cd-d371-40f4-adf1-7f714408c9f3
# ╠═7c1cc5fe-d517-4585-99bf-6bcf4344ae94
# ╠═d9989a7e-188b-481c-94af-e6b30f71f483
