using Dates
using TimeZones
using DataFrames
using CSV
using GeoJSON
using GeoInterface
using JSON
using LibGEOS
using Plots



# containers = GeoJSON.parsefile("downloaded-data/containers-geojson/container-locations.geojson");
# cadastralTeritories = GeoJSON.parsefile("downloaded-data/KATASTRALNI_UZEMI_P.geojson");

τ = features(cadastralTeritories)[1];
η = containers;

# plot()