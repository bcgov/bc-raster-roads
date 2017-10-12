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

OutDir<-('out/')
figsOutDir<-paste(OutDir,'figures/',sep='')
dataOutDir<-paste(OutDir,'data/',sep='')
tileOutDir<-paste(dataOutDir,'tile/',sep='')
dir.create(file.path(OutDir), showWarnings = FALSE)
dir.create(file.path(figsOutDir), showWarnings = FALSE)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
dir.create(file.path(tileOutDir), showWarnings = FALSE)
DataDir <- ("data/")

#Consolidated roads will be downloadable from some CE maintained location data
ConRdsFile<-'2017'
ConRds_zip <- paste(DataDir,ConRdsFile,".zip",sep='')

unzip(ConRds_zip, exdir = DataDir, overwrite = TRUE)

#zipped and zip files may not have the same name - search directory for gdb
Rd_gdb<-paste(DataDir,ConRdsFile,'/',(list.files(path=paste(DataDir,ConRdsFile,'/',sep=''), pattern='gdb')[1]),sep='')

# List feature classes in the geodatabase
fc_list <- ogrListLayers(Rd_gdb)
print(fc_list)

# Read integrated roads feature class-usually the first record in list
IntRds <- readOGR(dsn=Rd_gdb,layer=fc_list[1])

#set projection to BC Albers
crs(IntRds) <- "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"

# Determine the FC extent, projection, and attribute information
summary(IntRds)


