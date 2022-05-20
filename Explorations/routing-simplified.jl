### A Pluto.jl notebook ###
# v0.19.4

using Markdown
using InteractiveUtils

# ╔═╡ e9e7b590-b762-11ec-37ff-edb0051d454a
begin
	import Pkg
	Pkg.activate(Base.current_project())
end

# ╔═╡ 76ed3956-f5e7-4910-9496-d36fb9384531
begin
	using Pipe
	using OpenStreetMapX
	using DataFrames
	using PyCall
	using GeoInterface
	import JSON3
	import ArchGDAL as AGDAL
	using KissThreading
end

# ╔═╡ d8f94aef-e25f-45f4-81cb-9efc10ba040a
begin
	include("./src/nearestContainer.jl")
	include("./src/data-conversion.jl")
end

# ╔═╡ c87a7127-f36f-4515-9cfd-1b04dd24ec06
begin
	flm = pyimport("folium")
	matplotlib_cm = pyimport("matplotlib.cm")
	matplotlib_colors = pyimport("matplotlib.colors")
end

# ╔═╡ bb6b2eaf-4393-43e8-9d3f-d86222ae4fed
selectedTrashTypeId = 6

# ╔═╡ 3be37e9b-291d-4dc0-8d07-ace42c6297e4
cadastralTeritoryName = 729051

# ╔═╡ 30a21397-d4ca-4180-8b36-bf0086a9358e
begin
	containers = DataConversion.getContainersGDAL();
	containerLocations = DataConversion.getContainerLocationsGDAL();
	buildings = DataConversion.getFilteredBuildingsGDAL(selectedTrashTypeId);
	cadastralTeritories = DataConversion.getCadastralTeritories()
	osmMap = get_map_data("map.osm")
end;

# ╔═╡ 54e5845c-5635-4532-9b0f-4b842323103d
selectedTeritory = 
	filter(t-> t.KATUZE_KOD == cadastralTeritoryName,cadastralTeritories)[1,:]

# ╔═╡ 58b2c3ea-8f74-4867-a901-48a5de40388e
buildings

# ╔═╡ 54074c70-ee9a-4fcb-9b92-1a7342774111
filteredBuildings = filter(buildings) do b
	AGDAL.within(b.geom,selectedTeritory.geom)
end

# ╔═╡ 1c7a6d30-8994-4390-aee3-d04ab0df0109
(filter(containerLocations) do loc
	loc.id === "ec4e33aa-1b08-5866-91f2-2be206dd349d"
end)[1,:].containers

# ╔═╡ 3cd09582-ba5f-48ba-85b7-59964d6f4790
res = filter(buildings) do b
	b.ID_2 == "880842101"
end

# ╔═╡ 88ac4a27-2524-4904-b358-078467017b6d
selectedBuilding = buildings[6969, :]

# ╔═╡ 362d0d88-eee6-4355-b652-69a6f4058a54
filteredContainers =
	@pipe containers |>
	filter(DataConversion.isContainerPublicPredicate, _) |>
	filter(DataConversion.isContainerOfTrashType(selectedTrashTypeId), _);

# ╔═╡ fac8ab0f-f8a0-4211-af96-743afc4c6c09
filteredContainerLocations = 
	@pipe containerLocations |>
	filter(DataConversion.isContainerLocationIncludesTrashType(selectedTrashTypeId),_) |>
	filter(DataConversion.isContainerLocationPublic, _);

# ╔═╡ b9b7d33f-c4d1-4fa5-8587-25b87b3412bc
archGDALPointToTuple(point) = 
	@pipe point |> coordinates |> reverse |> Tuple

# ╔═╡ 3f188003-b48b-4363-8c17-39da514d59ee
searchTree = NearestContainer.getContainersBallTree(filteredContainerLocations)

# ╔═╡ 17dc609d-28ef-4683-88e1-6b643e37e8fa
results = NearestContainer.getNearestContainerForBuildingByMapRoute(
    searchTree,
    filteredContainerLocations,
    selectedBuilding,
    osmMap,
    n=10
)

# ╔═╡ 8f3aeefc-e5ad-4928-91ac-b97b32ee737f
results[1].containerLocation.containers

# ╔═╡ 6fbdbde2-a4cb-4643-8925-5dc12583519c
begin
	m = flm.Map()
	m.fit_bounds([(49.9,14.22),(50.2,14.71)])
	
	
	
	flm.Marker(archGDALPointToTuple(selectedBuilding.geom), icon=flm.Icon(color="red")).add_to(m)

	for (index, res) in enumerate(results)

		markerStyle = """
		background-color: yellow;
		padding: 3px;
		border: 2px solid black;
		width: 2.4rem;
		border-radius: 100%;
		"""
		
		icon=flm.DivIcon(html="""<div style="$(markerStyle)">$(index)</div>""")
		flm.Marker(archGDALPointToTuple(res.containerLocation.geom),icon=icon).add_to(m)

		locations = [LLA(osmMap.nodes[n], osmMap.bounds) for n in res.mapNodes]
		if(length(locations) === 0)
			continue
		end
		flm.PolyLine(
			[(loc.lat, loc.lon) for loc in locations],
			color="black"
		).add_to(m)
	end

	m.add_child(flm.LatLngPopup())
	
	m
end

# ╔═╡ 271f14be-6291-4069-9aad-088a22e25996


# ╔═╡ Cell order:
# ╠═e9e7b590-b762-11ec-37ff-edb0051d454a
# ╠═76ed3956-f5e7-4910-9496-d36fb9384531
# ╠═c87a7127-f36f-4515-9cfd-1b04dd24ec06
# ╠═d8f94aef-e25f-45f4-81cb-9efc10ba040a
# ╠═bb6b2eaf-4393-43e8-9d3f-d86222ae4fed
# ╠═3be37e9b-291d-4dc0-8d07-ace42c6297e4
# ╠═30a21397-d4ca-4180-8b36-bf0086a9358e
# ╠═54e5845c-5635-4532-9b0f-4b842323103d
# ╠═58b2c3ea-8f74-4867-a901-48a5de40388e
# ╠═54074c70-ee9a-4fcb-9b92-1a7342774111
# ╠═1c7a6d30-8994-4390-aee3-d04ab0df0109
# ╠═3cd09582-ba5f-48ba-85b7-59964d6f4790
# ╠═88ac4a27-2524-4904-b358-078467017b6d
# ╠═362d0d88-eee6-4355-b652-69a6f4058a54
# ╠═fac8ab0f-f8a0-4211-af96-743afc4c6c09
# ╠═b9b7d33f-c4d1-4fa5-8587-25b87b3412bc
# ╠═3f188003-b48b-4363-8c17-39da514d59ee
# ╠═17dc609d-28ef-4683-88e1-6b643e37e8fa
# ╠═8f3aeefc-e5ad-4928-91ac-b97b32ee737f
# ╠═6fbdbde2-a4cb-4643-8925-5dc12583519c
# ╠═271f14be-6291-4069-9aad-088a22e25996
