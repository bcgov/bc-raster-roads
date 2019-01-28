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

RoadDensR<-raster(file.path(tileOutDir,"RoadDensR.tif"))

  # Caculate km/km2 of roads within a km of a cell
  # run reduce if want to include multiple linear raster feature types
  # T1<-Reduce("+",list(RdDensR,RailR))
  
  # Focal function to caluclate a 1km diameter cirular window radius - 564.9769748m
  fw<-focalWeight(raster(res=c(100,100)),565,type='circle')
  fw[fw>0]<-1
  
  # Method 1 - use raw RoadeDensR - includes meters of road in each cell can vary from 1 to 2516.344 (in urban)
  # Method 2 - set cell to 100m if it contains any roads - range 0 to 100
  T1<-RoadDensR
  T1[T1>0]<-100
  
  RdRaw <- focal(RoadDensR, w=as.matrix(fw), fun='sum', na.rm=FALSE, pad=TRUE) # to make it km/km2 max should 27.90163 km/km2
  Rd100 <- focal(T1, w=as.matrix(fw), fun='sum', na.rm=FALSE, pad=TRUE) # to make it km/km2 max should 9.7 km/km2
  
  # divide by 1000 to get km/km2 for each cell
  Roadkmkm2Raw<-RdRaw/1000
  Roadkmkm2100<-Rd100/1000
  writeRaster(Roadkmkm2Raw, filename=file.path(OutDir,"Roadkmkm2Raw.tif"), format="GTiff", overwrite=TRUE)
  writeRaster(Roadkmkm2100, filename=file.path(OutDir,"Roadkmkm2100.tif"), format="GTiff", overwrite=TRUE)
  
  #Note: function to make a circular matrix for focal function, from:
  #https://scrogster.wordpress.com/2012/10/05/applying-a-circular-moving-window-filter-to-raster-data-in-r/

