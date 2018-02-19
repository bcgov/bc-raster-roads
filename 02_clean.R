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
require(raster)
require(rgdal)
require('plyr')
library(readr) # load data

#Reference loaded roads
IntRds<-RdsLoad

#Stack Overflow code snipet use is licensed under the open source licence: : https://opensource.org/licenses/MIT
#Other code snipets have published reference

# Make table of all possible combinations to determine how to classify roads
# into use types, capture all cases and if contribute to non-intact land
Rd_Tbl<-count(IntRds@data,vars=c('TRANSPORT_LINE_SURFACE_CODE','TRANSPORT_LINE_TYPE_CODE'))
write_csv(Rd_Tbl, "out/Rd_x_tbl.csv")

# Not roads - Ferry routes, non motorized Trails, proposed
notRoads<-c("F","FP","FR","RP","T", "TD", "RWA") 
# No longer roads - decomissioned and overgrown
NoLongerRoads<-c("D","O")

Roads<-subset(IntRds, 
              !(TRANSPORT_LINE_TYPE_CODE %in% notRoads)|
                (TRANSPORT_LINE_SURFACE_CODE %in% NoLongerRoads))
writeOGR(obj=Roads, dsn=dataOutDir, layer="Roads", driver="ESRI Shapefile", overwrite_layer=TRUE) 
#Roads <- readOGR(dsn=dataOutDir, layer="Roads")

