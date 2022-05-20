import ArchGDAL as AGDAL
import GeoDataFrames as GDF
using DataFrames

include("../data-conversion.jl")

data = GDF.read("URK_SS_VyuzitiZakl_p_shp/URK_SS_VyuzitiZakl_p.shp")

zones = GDF.read("downloaded-data/KATASTRALNI_UZEMI_P.geojson")

selectedZone = filter(:KATUZE_KOD => ==(727181),zones)[1,:]

validCodes = [
  "BD",
  "BQ",
  "BRR"
]

names(data)

groupby(data, :KOD)

unique(data.KOD)

filtered = filter(
  :geom => z -> AGDAL.within(AGDAL.centroid(z), selectedZone.geom),
  data)



GDF.write("tmp/land-use-727181.geojson",filtered)