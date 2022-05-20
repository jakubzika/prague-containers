using OpenStreetMapX
using OpenStreetMapXPlot
using Plots
# Plots()

ENV["MPLBACKEND"] = "qt5agg"
m = get_map_data("map.osm", use_cache=false);
import Random
Random.seed!(0);
println("Loaded the data")
p = OpenStreetMapXPlot.plotmap(m, width=600, height=400);
