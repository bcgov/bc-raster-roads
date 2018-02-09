# Copyright 2017 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
require(rgdal)
library(sf)

OutDir<-('out/')
figsOutDir<-paste(OutDir,'figures/',sep='')
dataOutDir<-paste(OutDir,'data/',sep='')
tileOutDir<-paste(dataOutDir,'tile/',sep='')
dir.create(file.path(OutDir), showWarnings = FALSE)
dir.create(file.path(figsOutDir), showWarnings = FALSE)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
dir.create(file.path(tileOutDir), showWarnings = FALSE)
DataDir <- "data"
dir.create(DataDir, showWarnings = FALSE)

## DRA from BCDC: 
## https://catalogue.data.gov.bc.ca/dataset/digital-road-atlas-dra-master-partially-attributed-roads/resource/a06a2e11-a0b1-41d4-b857-cb2770e34fb0
# download.file("ftp://ftp.geobc.gov.bc.ca/sections/outgoing/bmgs/DRA_Public/dgtl_road_atlas.gdb.zip", 
#               destfile = file.path(DataDir, "dra.gdb.zip"))
# unzip(file.path(DataDir, "dra.gdb.zip"), exdir = file.path(DataDir, "DRA"))

# List feature classes in the geodatabase
Rd_gdb <- list.files(file.path(DataDir, "DRA"), pattern = ".gdb", full.names = TRUE)[1]
fc_list <- ogrListLayers(Rd_gdb)
print(fc_list)

# Read TRANSPORT_LINE layer which has the acutal lines
IntRds <- readOGR(dsn = Rd_gdb, layer = "TRANSPORT_LINE")

# Also read as sf
roads_sf <- read_sf(Rd_gdb, layer = "TRANSPORT_LINE")

# Write metadata from gdb to csv files
lapply(fc_list[grepl("CODE$", fc_list)], function(l) {
  system(paste0("ogr2ogr -f CSV data/", l, ".csv ", Rd_gdb, " ", l))
})

# Determine the FC extent, projection, and attribute information
summary(IntRds)

dir.create("tmp")
saveRDS(IntRds, file = "tmp/IntRds.rds")
saveRDS(roads_sf, file = "tmp/DRA_roads_sf.rds")
