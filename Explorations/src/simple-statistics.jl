include("data-conversion.jl")
import GeoDataFrames as GDF

using JSON3

Vector(JSON3.read("[\"a7a44d06-b419-5772-a314-7a46f82b6eee\",\"dd08a6a7-1241-568a-9b1b-f384d69c358a\",\"0a292077-4dbd-501a-ac60-d11c80e889c5\",\"e221e737-27db-52f7-af16-165154bc97cf\",\"9467318c-4cf1-507b-a4bb-e97cee1bbef0\",\"2da8ad7c-dd99-5d86-85e7-64ddd95b36d8\",\"c468c49f-12fe-567f-8342-40e166c53698\",\"26146616-0037-5bdf-beb3-5992c32b035a\",\"81afd7dc-be16-5f25-aa28-f36f0e670192\",\"a68aea5d-3c0c-597a-bddd-d8d53c3777bf\"]"))


d = Dict([1, 2, 3] => "123", [5, 6, 7] => "5,6,7")

d[[1, 2, 3]]

locations = DataConversion.getServerEnhancedContainerLocationsGDAL()

locations.id[1:10]


["a7a44d06-b419-5772-a314-7a46f82b6eee",
  "dd08a6a7-1241-568a-9b1b-f384d69c358a",
  "0a292077-4dbd-501a-ac60-d11c80e889c5",
  "e221e737-27db-52f7-af16-165154bc97cf",
  "9467318c-4cf1-507b-a4bb-e97cee1bbef0",
  "2da8ad7c-dd99-5d86-85e7-64ddd95b36d8",
  "c468c49f-12fe-567f-8342-40e166c53698",
  "26146616-0037-5bdf-beb3-5992c32b035a",
  "81afd7dc-be16-5f25-aa28-f36f0e670192",
  "a68aea5d-3c0c-597a-bddd-d8d53c3777bf"]