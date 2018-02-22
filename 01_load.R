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

# Source the common header file that loads packages and sets directories etc.
source("header.R")

# Raw road file 
# DRA from BCDC:
# https://catalogue.data.gov.bc.ca/dataset/digital-road-atlas-dra-master-partially-attributed-roads/resource/a06a2e11-a0b1-41d4-b857-cb2770e34fb0
RdsZip <- 'dra.gdb.zip'
download.file("ftp://ftp.geobc.gov.bc.ca/sections/outgoing/bmgs/DRA_Public/dgtl_road_atlas.gdb.zip",
              destfile = file.path(DataDir, RdsZip))
unzip(file.path(DataDir, RdsZip), exdir = file.path(DataDir, "DRA"))

# List feature classes in the geodatabase
Rd_gdb <- list.files(file.path(DataDir, "DRA"), pattern = ".gdb", full.names = TRUE)[1]
fc_list <- st_layers(Rd_gdb)

# Read as sf and calculate road lengths
roads_sf <- read_sf(Rd_gdb, layer = "TRANSPORT_LINE") %>% 
  mutate(rd_len = st_length(.))

# Write metadata from gdb to csv files (need ogr2ogr on the command line)
lapply(fc_list[grepl("CODE$", fc_list)], function(l) {
  system(paste0("ogr2ogr -f CSV data/", l, ".csv ", Rd_gdb, " ", l))
})

# Determine the FC extent, projection, and attribute information
summary(roads_sf)

# Save as RDS for quicker access later
saveRDS(roads_sf, file = "tmp/DRA_roads_sf.rds")
