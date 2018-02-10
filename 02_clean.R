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
#
#Stack Overflow code snipet use is licensed under the open source licence: : https://opensource.org/licenses/MIT
#Other code snipets have published reference

# require(sp)
require(raster)
# require(rgdal)
require(spatstat)
require(maptools)
# require(rgeos)
require(RColorBrewer)
require(dplyr)
require(sf)

# IntRds <- readRDS("tmp/IntRds.rds")
roads_sf <- readRDS("tmp/DRA_roads_sf.rds")

# roadsIN <- IntRds
# Set up Provincial raster based on hectares BC extent, 1ha resolution and projection
ProvRast <- raster(
  nrows = 15744, ncols = 17216, xmn = 159587.5, xmx = 1881187.5, ymn = 173787.5, ymx = 1748187.5, 
  crs = st_crs(roads_sf)$proj4string, resolution = c(100, 100), vals = 0
)
#ProvRast <- raster(extent(roadsIN), crs=projection(roadsIN),res=c(100,100),vals=0)

#---------------------
#split Province into tiles for processing
#identify the extents for each tile and use to clip for processing

#extents of input layer
ProvBB <- bbox(ProvRast)

#Number of tile rows, number of columns will be the same
nTileRows <- 10

#Determine the seed extents for generating the tile extents
#Code modified from https://stackoverflow.com/questions/38851909/divide-bounding-box-extent-into-several-parts-in-r

Tseed <- data.frame(x = seq(1:nTileRows))
xFactor <- (ProvBB[3] - ProvBB[1])/nTileRows
yFactor <- (ProvBB[4] - ProvBB[2])/nTileRows
Tseed$xCH <- Tseed$x*xFactor + ProvBB[1]
Tseed$yCH <- Tseed$x*yFactor + ProvBB[2]

#generate data.frame of tile extents based on bounding box
Tdf <- data.frame(xmin = double(), xmax = double(), ymin = double(), ymax = double())
i <- 1
for (i in 1:nTileRows) {
  for (j in 1:nTileRows) {
    Tdfn <- data.frame(xmin = Tseed$xCH[i] - xFactor, xmax = Tseed$xCH[i], 
                       ymin = Tseed$yCH[j] - yFactor, ymax = Tseed$yCH[j])
    Tdf <- rbind(Tdf, Tdfn)
    # rbind(df, setNames(de, names(df)))
  }
}

#Plot Province bbox to check
ProvPlt <- st_as_sfc(as(raster::extent(ProvRast), "SpatialLines"), crs = 3005)
plot(ProvPlt)


#' convert a bounding box to a sfc polygon object
#'
#' @param bb a bounding box or list with xmin, xmax, ymin, ymax elements
#' @param crs 
bb_to_polygon <- function(bb, crs) {
  st_sfc(st_polygon(list(rbind(
    c(bb$xmin, bb$ymin),
    c(bb$xmin, bb$ymax),
    c(bb$xmax, bb$ymax),
    c(bb$xmax, bb$ymin),
    c(bb$xmin, bb$ymin)
  ))), crs = crs)
}

#Add each tile as a check
i <- 1
for (i in 1:(nTileRows*nTileRows)) {
  e <- bb_to_polygon(Tdf[i, ], 3005)
  plot(e, add = TRUE)
}

plot(ProvPlt,col='red', add = TRUE)

#Loop through each tile and generate road density raster
#Function that takes a shape file and bounding box and generates a clipped shape file
#code snippet based on: https://www.rdocumentation.org/packages/stplanr/versions/0.1.9

st_clip <- function(shp, bb){
  b_poly <- bb_to_polygon(bb, 3005)
  st_intersection(shp, b_poly)#last parameter to fix gIntersect error
}


#Loop through each tile and calculate road density for each 1ha cell
ptm <- proc.time()
i <- 1
for (i in 1:(nTileRows * nTileRows)) {
  Pc <- as.vector(as.matrix(Tdf[i, ]))
  Pcc <- raster::extent(Pc)
  TilePoly <- st_clip(roads_sf, Tdf[i, ])
  DefaultRaster <- raster(Pcc, crs = st_crs(roads_sf)$projfstring, resolution = c(100, 100), vals = 0, ext = Pcc)

  # Code snippet for using spatstat package approach to calculating 1ha raster cell road density
  # originally posted at: https://stat.ethz.ch/pipermail/r-sig-geo/2015-March/022483.html
  if (length(TilePoly) > 0) {
    roadlengthT1 <- as.psp(as(TilePoly, "Spatial")) %>%
      pixellate.psp(eps = 100)

    roadlengthT2 <- raster(roadlengthT1, crs = st_crs(roads_sf)$proj4string)
    roadlengthT3 <- extend(roadlengthT2, Pcc, value = 0)
    roadlengthT <- resample(roadlengthT3, DefaultRaster, method = "ngb")
  } else {
    roadlengthT <- DefaultRaster
  }
  writeRaster(roadlengthT, filename = paste(tileOutDir, "rdTile_", i, ".tif", sep = ""), format = "GTiff", overwrite = TRUE)
  print(paste(tileOutDir, "rdTile_", i, ".tif", sep = ""))
  gc()
}
## To here sf-ified

#Memory functions - object.size(roadsIN), gc(), rm()

#code to read rasters from a directory and mosaic - faster than merge or mosaic
#Code snipet from: https://stackoverflow.com/questions/15876591/merging-multiple-rasters-in-r

library(gdalUtils)
#Build list of all raster files you want to join (in your current working directory).
Tiles<- list.files(path=paste(tileOutDir,sep=''), pattern='rdTile_')

#Make a template raster file to build onto
template<-ProvRast
writeRaster(template, file=paste(tileOutDir,"RoadDensR.tif",sep=''), format="GTiff",overwrite=TRUE)
#Merge all raster tiles into one big raster.
RoadDensR<-mosaic_rasters(gdalfile=paste(tileOutDir,Tiles,sep=''),
                          dst_dataset=paste(tileOutDir,"RoadDensR.tif",sep=''),
                          of="GTiff",
                          output_Raster=TRUE,
                          output.vrt=TRUE)
gdalinfo(paste(tileOutDir,"RoadDensR.tif",sep=''))
#Plot to test
plot(RoadDensR)
#lines(roadsIN,col='red')
proc.time() - ptm 

