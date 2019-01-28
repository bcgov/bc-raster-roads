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

# Raw CE road file downloaded from Provincial CE data directory - internal to government
# access and place in data/CE_Roads/

# List feature classes in the geodatabase
Rd_gdb <- list.files(file.path(DataDir, "CE_Roads/2017"), pattern = ".gdb", full.names = TRUE)[1]
fc_list <- st_layers(Rd_gdb)

# Read as sf and calculate road lengths
roads_sf <- read_sf(Rd_gdb, layer = "integrated_roads") %>% 
  mutate(rd_len = st_length(.))

# Write metadata from gdb to csv files - none in this CE file
# (sf >= 0.6-1 supports reading non-spatial tables))
lapply(fc_list$name[grepl("CODE$", fc_list$name)], function(l) {
  metadata <- st_read(Rd_gdb, layer = l, stringsAsFactors = FALSE)
  write_csv(metadata, path = file.path("data", paste0(l, ".csv")))
})

# Determine the FC extent, projection, and attribute information
summary(roads_sf)

# Save as RDS for quicker access later
saveRDS(roads_sf, file = "tmp/Integrated_roads_sf.rds")

