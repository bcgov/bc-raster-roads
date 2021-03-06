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

require(gdalUtils)
require(raster)

#code to read rasters from a directory and mosaic - faster than merge or mosaic
#Code snippet from: https://stackoverflow.com/questions/15876591/merging-multiple-rasters-in-r

#Build list of all raster files you want to join (in your current working directory).
Tiles<- list.files(path=tileOutDir, pattern='rdTile_')

#Make a template raster file to build onto
template<-ProvRast
writeRaster(template, file=file.path(tileOutDir,"RoadDensR.tif"), format="GTiff", overwrite=TRUE)
#Merge all raster tiles into one big raster.
RoadDensR<-mosaic_rasters(gdalfile=file.path(tileOutDir,Tiles),
                          dst_dataset=file.path(tileOutDir,"RoadDensR.tif"),
                          of="GTiff",
                          output_Raster=TRUE)
gdalinfo(file.path(tileOutDir,"RoadDensR.tif"))
#Plot to test
plot(RoadDensR)
#lines(roadsIN,col='red')

# Check total sum of road lengths and compare to total sum from vector object
rast_sum_len <- cellStats(RoadDensR, "sum")
as.numeric(sum(roads_sf$rd_len)) - rast_sum_len
# ~ 250 km difference - pretty good!

file.copy("out/data/tile/RoadDensR.tif", "../roadless-areas-indicator/data/", overwrite = TRUE)
