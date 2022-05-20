### A Pluto.jl notebook ###
# v0.18.0

using Markdown
using InteractiveUtils

# ╔═╡ 7213d0c6-bcf9-11ec-3950-6765f7e22585
begin
	import Pkg
	Pkg.activate(Base.current_project())

	using Pipe
	using OpenStreetMapX
	using DataFrames
	using PyCall
	using GeoInterface
	import JSON3
	import ArchGDAL as AGDAL
	using KissThreading
end

# ╔═╡ 422631ba-18a9-42d3-b0df-a24d5dc7570d
begin
	include("./src/nearestContainer.jl")
	include("./src/data-conversion.jl")
	include("./src/nearestContainerForBuildings.jl")
end

# ╔═╡ 3af05774-5f3f-400d-a833-3283b77b983a
begin
	flm = pyimport("folium")
	matplotlib_cm = pyimport("matplotlib.cm")
	matplotlib_colors = pyimport("matplotlib.colors")
end

# ╔═╡ dd07dc28-2dc1-43df-a1ae-23861fd4d53b
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
	name = Symbol(basename(path))
	m = Module(name)
	Core.eval(m,
        Expr(:toplevel,
             :(eval(x) = $(Expr(:core, :eval))($name, x)),
             :(include(x) = $(Expr(:top, :include))($name, x)),
             :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
             :(include($path))))
	m
end

# ╔═╡ 0fac2d9d-133e-43fa-bb58-ea38996c3ed8
res = NearestContainerForBuildings.computeNearestContainerForTrashType(6)


# ╔═╡ Cell order:
# ╠═7213d0c6-bcf9-11ec-3950-6765f7e22585
# ╠═3af05774-5f3f-400d-a833-3283b77b983a
# ╠═dd07dc28-2dc1-43df-a1ae-23861fd4d53b
# ╠═422631ba-18a9-42d3-b0df-a24d5dc7570d
# ╠═c3df58b3-492b-4f2c-9803-83bc40801f8e
# ╠═645d9c15-7c38-4b3c-b2c2-955b16315372
# ╠═0fac2d9d-133e-43fa-bb58-ea38996c3ed8
# ╠═090437eb-17fd-455e-b4e0-a594db0d02c2
