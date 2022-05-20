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

# ╔═╡ a38854f9-53a5-4800-98f8-75c7082a7efd
begin
	import Pkg
	Pkg.activate(Base.current_project())
end

# ╔═╡ d9839258-9acf-11ec-25fa-cb4e28c5b8da
using CSV,DataFrames, Dates, PlutoUI, Plots, TimeZones

# ╔═╡ 4ecc75c7-609c-46e7-8f1a-cdc6136fc4d7
begin
	include("src/data-conversion.jl")
end

# ╔═╡ e708282e-5bf5-4515-8716-370eec8b0290
include("src/golemioAPI.jl")

# ╔═╡ 720486f9-ca07-4883-90a1-8e1748c2cbdf
md"""# Data explorations"""

# ╔═╡ 21a3a5bf-cb9a-452b-bc1f-0b3f72c86faf
plotly()

# ╔═╡ 2c6673d3-ba77-4831-8dcd-da02ed379e98
md"""## Load data"""

# ╔═╡ bade15a6-1711-4a82-b1f5-dd354d0e3418
begin
	# containersDf = DataFrame(CSV.File("generated/detected-containers.csv"))
	containersDf = DataConversion.loadMeasuredContainers()
end

# ╔═╡ 84f6d655-89f5-4623-9afe-84f3e1e6d451
config = GolemioAPI.createConfig(accessToken="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Imt1YmEuemlrYUBlbWFpbC5jeiIsImlkIjoxMDg5LCJuYW1lIjpudWxsLCJzdXJuYW1lIjpudWxsLCJpYXQiOjE2NDUwMjUxNzcsImV4cCI6MTE2NDUwMjUxNzcsImlzcyI6ImdvbGVtaW8iLCJqdGkiOiI5MTU4MjdmYS1jNTcwLTQ2MWEtODE4Mi0yMTUwMWMzZTEyNjAifQ.Y4nRVJ91GScPy7UypSCPXyewMP9ONwMRU5i9TEgwnkk")

# ╔═╡ 1ec46c6d-714c-4712-b6f0-7a4769bb6f0b
md"""Select index of container from generated containers data"""

# ╔═╡ 3fd2e6b3-ab9c-4b23-a1a7-02d6678c2701
@bind selectedContainer NumberField(1:nrow(containersDf))

# ╔═╡ 89a7e878-bb29-4f71-b62b-2105dbdb7bf6
selectedContainerObj = containersDf[selectedContainer, :]

# ╔═╡ 3b22be3b-1e59-40a6-bbaf-4a3e6b64cb6d
wastePicks = GolemioAPI.getContainerWastePicks(config, containerId=selectedContainerObj.container_id)

# ╔═╡ b4fa924f-7b9e-4ad5-93da-e21912c3f018
md"""
Loading container: **$(containersDf[selectedContainer,:container_id])**

with trash type **$(selectedContainerObj.trash_type_description)**

and container type **$(selectedContainerObj.container_type)**
"""

# ╔═╡ a0d880b1-ab4f-4944-8b6b-a612119ed3db
    
begin
	range = 2
	lower = max(selectedContainer - range, 1)
	higher = min(selectedContainer + range, nrow(containersDf))
	# (
	# 	containersDf[lower:(selectedContainer - 1),:], containersDf[selectedContainer:selectedContainer, :],
	# 	containersDf[(selectedContainer + 1):higher,:], 
	# )
	containersDf[selectedContainer:selectedContainer, :]
end;

# ╔═╡ 514e19bf-ff42-4329-833c-bb1712bdea69
begin
	containerId = containersDf[selectedContainer,:container_id]
	measurementsDf = DataConversion.getContainerMeasurements(containerId)
	# containerDf = DataFrame(CSV.File("container-measurements/01/$(containerId).csv"))
end;


# ╔═╡ 7469cb0b-d941-46ce-9959-5f49a04a57bf
md"""## Experiments"""

# ╔═╡ 7bd4358a-7008-43a7-81dd-eb5ff1cb4507


# ╔═╡ 6525d3cf-6eb7-4134-9e51-d4c6e22137e0
begin
	altRange = 1:min(100, nrow(measurementsDf))
	fullnessData = measurementsDf.percent_calculated[altRange] |> reverse;
	measuredDateTimes = measurementsDf.measured_at[altRange] |> reverse;
	batteryStatus = measurementsDf.battery_status[altRange] |> reverse;
end;


# ╔═╡ 62c3d00e-9061-432b-bde7-4d05c0d9666d
plot(measuredDateTimes, fullnessData,
	ylims=(0, 110),
	xlabel="Date",
	ylabel="Fullness",
	xrotation=45,
	ticks=:native
)

# ╔═╡ 92535b95-3561-4acc-8d1c-b2c3db1e2bee
md"""
## Ideas
Estabilish some sort of scores for container, transforming its time series data into some indicator

- percent of time its full
- how predictable it is (periodical vs chaotic)
- identify filling cycles ()
"""

# ╔═╡ 1e090b49-07a8-4c72-b49a-605db3c13ad9
md"""
## Goals 
*and how to measure closeness to that goal*

- estimate filling intensity - (litres per hour)
  - to see if the area is high demand
  - find out if the cleaning frequency is enough to cover the demand

"""

# ╔═╡ ac9c9c7b-2a9e-45d8-8a3d-ffd6b8e0846e


# ╔═╡ Cell order:
# ╟─720486f9-ca07-4883-90a1-8e1748c2cbdf
# ╠═a38854f9-53a5-4800-98f8-75c7082a7efd
# ╠═d9839258-9acf-11ec-25fa-cb4e28c5b8da
# ╠═4ecc75c7-609c-46e7-8f1a-cdc6136fc4d7
# ╠═e708282e-5bf5-4515-8716-370eec8b0290
# ╠═21a3a5bf-cb9a-452b-bc1f-0b3f72c86faf
# ╟─2c6673d3-ba77-4831-8dcd-da02ed379e98
# ╠═bade15a6-1711-4a82-b1f5-dd354d0e3418
# ╠═84f6d655-89f5-4623-9afe-84f3e1e6d451
# ╟─1ec46c6d-714c-4712-b6f0-7a4769bb6f0b
# ╟─3fd2e6b3-ab9c-4b23-a1a7-02d6678c2701
# ╠═89a7e878-bb29-4f71-b62b-2105dbdb7bf6
# ╠═3b22be3b-1e59-40a6-bbaf-4a3e6b64cb6d
# ╟─b4fa924f-7b9e-4ad5-93da-e21912c3f018
# ╟─a0d880b1-ab4f-4944-8b6b-a612119ed3db
# ╟─514e19bf-ff42-4329-833c-bb1712bdea69
# ╟─7469cb0b-d941-46ce-9959-5f49a04a57bf
# ╠═7bd4358a-7008-43a7-81dd-eb5ff1cb4507
# ╟─6525d3cf-6eb7-4134-9e51-d4c6e22137e0
# ╠═62c3d00e-9061-432b-bde7-4d05c0d9666d
# ╠═92535b95-3561-4acc-8d1c-b2c3db1e2bee
# ╠═1e090b49-07a8-4c72-b49a-605db3c13ad9
# ╠═ac9c9c7b-2a9e-45d8-8a3d-ffd6b8e0846e
