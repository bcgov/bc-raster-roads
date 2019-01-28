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

roads_sf <- readRDS("tmp/Integrated_roads_sf.rds")

# Make table of all possible combinations to determine how to classify roads
# into use types, capture all cases and if contribute to non-intact land
Rd_Tbl <- st_set_geometry(roads_sf, NULL) %>% 
  count(ROAD_SURFACE, ROAD_CLASS)
write_csv(Rd_Tbl, "out/Rd_x_tbl.csv")

# Not roads - TYPE = Ferry routes, non motorized Trails, proposed, pedestrian mall
notRoads <- c("ferry", "water", "proposed", "trail", "pedestrian") 
# No longer roads - SURFACE_TYPE = decomissioned, overgrown, and boat
NoLongerRoads <- c("boat", "decommissioned", "overgrown")

roads_sf <- roads_sf %>% 
  filter(!ROAD_CLASS %in% notRoads, 
         !ROAD_SURFACE %in% NoLongerRoads)

# Save as RDS for quicker access later.
saveRDS(roads_sf, file = "tmp/DRA_roads_sf_clean.rds")
# Also save as geopackage format for use in other software
write_sf(roads_sf, "out/data/roads_clean.gpkg")
