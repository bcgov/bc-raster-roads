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

library(raster)
library(spex) # fast conversion of raster to polygons
# For parallel processing tiles to rasters
library(foreach)
library(doMC)

roads_sf <- readRDS("tmp/DRA_roads_sf_clean.rds")

# Set up Provincial raster based on hectares BC extent, 1ha resolution and projection
ProvRast <- raster(
  nrows = 15744, ncols = 17216, xmn = 159587.5, xmx = 1881187.5, ymn = 173787.5, ymx = 1748187.5, 
  crs = st_crs(roads_sf)$proj4string, resolution = c(100, 100), vals = 0
)

#ProvRast <- raster(extent(roads_sf), crs = st_crs(roads_sf)$proj4string,
#                   resolution = c(100, 100), vals = 0)

#---------------------
#split Province into tiles for processing

# extent of input layer
ProvBB <- st_bbox(ProvRast)

#Number of tile rows, number of columns will be the same
nTileRows <- 10

prov_grid <- st_make_grid(st_as_sfc(ProvBB), n = rep(nTileRows, 2))
prov_grid <- st_sf(tile_id = seq_along(prov_grid), 
                   geometry = prov_grid, crs = 3005)

# Plot grid and Prov bounding box just to check
plot(prov_grid)
ProvPlt <- st_as_sfc(ProvBB, crs = 3005)
plot(ProvPlt, add = TRUE, col = NA, border = "red")

# Chop the roads up by the 10x10 tile grid. This takes a while but you only have to 
# do it once.
roads_gridded <- st_intersection(roads_sf, prov_grid)

# Loop through each tile and calculate road density for each 1ha cell.
# Choose number of cores to use in parallel carefully... too many and
# it will fill up memory and grind to a halt.
registerDoMC(3)

ptm <- proc.time()
foreach(i = prov_grid$id) %dopar% {
  Pcc <- raster::extent(prov_grid[prov_grid$id == i, ])
  DefaultRaster <- raster(Pcc, crs = st_crs(roads_gridded)$proj4string, 
                          resolution = c(100, 100), vals = 0, ext = Pcc)
  
  ## Use the roads layer that has already been chopped into tiles
  TilePoly <- roads_gridded[roads_gridded$id == i, ]
  
  if (nrow(TilePoly) > 0) {
    
    ##  This calculates lengths more directly than psp method...
    DefaultRaster[] <- 1:ncell(DefaultRaster)
    rsp <- spex::polygonize(DefaultRaster) # spex pkg for quickly making polygons from raster
    # Split tile poly into grid by the polygonized raster
    rp1 <- st_intersection(TilePoly[,1], rsp)
    rp1$rd_len <- as.numeric(st_length(rp1)) # road length in m for each grid cell
    # Sum of road lengths in each grid cell
    x <- tapply(rp1$rd_len, rp1$layer, sum, na.rm = TRUE)
    # Create raster and populate with sum of road lengths
    roadlengthT <- raster(DefaultRaster)
    roadlengthT[as.integer(names(x))] <- x
    roadlengthT[is.na(roadlengthT)] <- 0
    
  } else {
    roadlengthT <- DefaultRaster
  }
  writeRaster(roadlengthT, filename = paste(tileOutDir, "rdTile_", i, ".tif", sep = ""), format = "GTiff", overwrite = TRUE)
  print(paste(tileOutDir, "rdTile_", i, ".tif", sep = ""))
  rm(Pcc, DefaultRaster, TilePoly, rsp, rp1, x, roadlengthT)
  gc()
}
proc.time() - ptm

#Memory functions - object.size(roadsIN), gc(), rm()
