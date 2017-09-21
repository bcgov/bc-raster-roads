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

require(sp)
require(raster)
require(rgdal)
require(spatstat)
require(maptools)
dir.create("tmp", showWarnings = FALSE)

#Calculate time for routine to run
ptm <- proc.time()
roadsIN<-IntRds
#Set up Provincial raster based on hectares BC extent, 1ha resolution and projection
ProvRast<-raster(nrows=15744, ncols=17216, xmn=159587.5, xmx=1881187.5, ymn=173787.5,ymx=1748187.5,crs="+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")

# Convert to a line segment pattern object using maptools
roadsPSP <- as.psp(as(roadsIN, 'SpatialLines')) #approx 3 mins with Morice
proc.time() - ptm

#Calculate time for routine to run
ptm <- proc.time()

#use map extents to set dimensions for the pixellate used to calculate lengths per cell
#e <- extent( roadsIN )#used with the smaller test data
e <- extent( ProvRast )
RdExt<-c((e[4]-e[3]-1),(e[2]-e[1]-1))/100 #should result in 1 ha 100x100 cells based on ProvRast
roadLengthIM <- pixellate.psp(roadsIN, dimyx=RdExt)

# Convert pixel image to a raster with km roads in each cell
roadlength<-raster(roadLengthIM/1000)
prod(roadlength)
#check output if resolution is not exactly 100 then need to re set resolution
#Set raster to have 1ha cells so maps onto Provincial raster (hectares BC format)
#roadlengthP<-resample(rdLeng,ProvRast,method='bilinear')
proc.time() - ptm #1,802,111 cells took 122 seconds, 271,048,704 for the province ?

#write out road length raster as a geotif
rf <- writeRaster(roadlength, filename="rdLength.tif", format="GTiff", overwrite=TRUE)
#rdLeng<-raster("rdLength.tif")

#Some code snipets if need to break Province into tiles for processing
library(SpaDES) #for splitting up large rasters

#split raster into smaller chunks for processing
rTiles=splitRaster(ProvRaster, nx=10, ny=10, path=DataDir)#100 tiles

#Loop through each tile and calclate lenght of road in each cell
i<-1
rs<-rTiles[[i]]

rs[] <- 1:ncell(rs)
.....
