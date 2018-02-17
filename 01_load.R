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
require(raster)

OutDir<-('out/')
figsOutDir<-paste(OutDir,'figures/',sep='')
dataOutDir<-paste(OutDir,'data/',sep='')
tileOutDir<-paste(dataOutDir,'tile/',sep='')
dir.create(file.path(OutDir), showWarnings = FALSE)
dir.create(file.path(figsOutDir), showWarnings = FALSE)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
dir.create(file.path(tileOutDir), showWarnings = FALSE)
DataDir <- ("data/")

# Raw road file 
# DRA from BCDC:
# https://catalogue.data.gov.bc.ca/dataset/digital-road-atlas-dra-master-partially-attributed-roads/resource/a06a2e11-a0b1-41d4-b857-cb2770e34fb0
RdsZip<-'dra.gdb.zip'
download.file("ftp://ftp.geobc.gov.bc.ca/sections/outgoing/bmgs/DRA_Public/dgtl_road_atlas.gdb.zip",
              destfile = file.path(DataDir, RdsZip))
unzip(file.path(DataDir, RdsZip), exdir = file.path(DataDir, "DRA"))

# zip files may not have the same name - search directory for gdb
Rd_gdb<-paste(DataDir,RdsFile,'/',(list.files(path=paste(DataDir,RdsFile,'/',sep=''), pattern='gdb')[1]),sep='')

# List feature classes in the geodatabase
fc_list <- ogrListLayers(Rd_gdb)
print(fc_list)

# "TRANSPORT_LINE" layer contains road geometry and attributes - see https://catalogue.data.gov.bc.ca/dataset/bb060417-b6e6-4548-b837-f9060d94743e/resource/2e2a8314-e619-45a1-a5e1-fd1a9e1de91c/download/dgtlroadatlas-public-delivery-data-dictionary.pdf
# Read TRANSPORT_LINE feature class
RdsLoad <- readOGR(dsn=Rd_gdb,layer="TRANSPORT_LINE")
# set projection to BC Albers
raster::crs(RdsLoad) <- "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"

# Determine the FC extent, projection, and attribute information
summary(RdsLoad)
writeOGR(obj=RdsLoad, dsn=dataOutDir, layer="RdsLoad", driver="ESRI Shapefile", overwrite_layer=TRUE) 
#RdsLoad <- readOGR(dsn=dataOutDir, layer="RdsLoad")
#RdsLoad@data$TRANSPORT_LINE_TYPE_CODE<-RdsLoad@data$TRANSPOR_1
#RdsLoad@data$TRANSPORT_LINE_SURFACE_CODE<-RdsLoad@data$TRANSPOR_2

