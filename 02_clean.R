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

#Summarize all types of ROAD_SURFACE, ROAD_TYPE, ROAD_CLASS, FEATURE_TYPE, TRANSPORT_LINE_TYPE_Code
#for categrozing roads used by vehicles
rd_surface<-unique(IntRds@data$TRANSPORT_LINE_SURFACE_CODE)
print(rd_surface)
rd_type<-unique(IntRds@data$TRANSPORT_LINE_TYPE_CODE)
print(rd_type)

# Make table of all possible combinations to determine how to classify roads
# into use types, capture all cases and if contribute to non-intact land
Rd_Tbl<-count(IntRds@data,vars=c('TRANSPORT_LINE_SURFACE_CODE','TRANSPORT_LINE_TYPE_CODE'))
write_csv(Rd_Tbl, "out/Rd_x_tbl.csv")

#Group roads based on surface material - adapted from Forest Practices Board report Special Report #49
pavedTypes<-c('P')
gravelTypes<-c('L','R','S')
otherTypes<-c('D','O','B')
unknownTypes<-c('U')
pavedRds<-subset(IntRds,IntRds@data$TRANSPORT_LINE_SURFACE_CODE %in% pavedTypes)
gravelRds<-subset(IntRds, IntRds@data$TRANSPORT_LINE_SURFACE_CODE %in% gravelTypes)
otherRds<-subset(IntRds, IntRds@data$TRANSPORT_LINE_SURFACE_CODE %in% otherTypes)
unknownRds<-subset(IntRds, IntRds@data$TRANSPORT_LINE_SURFACE_CODE %in% otherTypes)

#Group roads based on use - adopted from CE Grizzly Bear Protocol
#Roads are classified into 'Use Class" using TRANSPORT_LINE_TYPE_CODE as follows:

# Not roads - Ferry routes, non motorized Trails, proposed
notRoads<-c("F","FP","FR","RP","T", "TD", "RWA") 
# High use roads - arterial, collectors, driveways, freeways, highways, road local, runway, pedestrial mall, ramp, strata
HighUse<-c("RA1","RA2","RC2", "RC1","RDN","RF","RH1","RH2","RLO","RPD","RPM","RR","RRP","RST")
# Moderate use roads - recreation
ModUse<-c("REC")
ModUseUsurf<-c("RRD","RRS", "RSV")
# Low use roads - lane, road water access, skid trails
LowUse<-c("RLN","TS")
LowUseUsurf<-c("RRN","RU","TR")
#Classification depends on surface type - alleyway, runway non-demographic, resource demographic, 
# resource non-status, resource, restricted, service, unclassified, recreation trail
dependsOnSurface<-c("RR1","RRC","RRD","RRN","RRS","RRT","RSV","RU", "TR")
NoLongerRoads<-c("D","O")

RdUse_notRoads<-subset(IntRds, 
                   (TRANSPORT_LINE_TYPE_CODE %in% notRoads)|
                     (TRANSPORT_LINE_SURFACE_CODE %in% NoLongerRoads) )
RdUse_High<-subset(IntRds, 
                   (TRANSPORT_LINE_SURFACE_CODE %in% pavedTypes & 
                      TRANSPORT_LINE_TYPE_CODE %in% dependsOnSurface) |
                     (TRANSPORT_LINE_TYPE_CODE %in% HighUse) )
RdUse_Mod<-subset(IntRds, 
                   (TRANSPORT_LINE_SURFACE_CODE %in% gravelTypes & 
                      TRANSPORT_LINE_TYPE_CODE %in% dependsOnSurface) |
                     (TRANSPORT_LINE_TYPE_CODE %in% ModUse)|
                    (TRANSPORT_LINE_SURFACE_CODE %in% unknownTypes & 
                       TRANSPORT_LINE_TYPE_CODE %in% ModUseUsurf))
RdUse_Low<-subset(IntRds, 
                   (TRANSPORT_LINE_SURFACE_CODE %in% otherTypes & 
                      TRANSPORT_LINE_TYPE_CODE %in% dependsOnSurface) |
                     (TRANSPORT_LINE_TYPE_CODE %in% LowUse)|
                    (TRANSPORT_LINE_SURFACE_CODE %in% unknownTypes & 
                       TRANSPORT_LINE_TYPE_CODE %in% LowUseUsurf))
Roads<-subset(IntRds, 
              !(TRANSPORT_LINE_TYPE_CODE %in% notRoads)|
                (TRANSPORT_LINE_SURFACE_CODE %in% NoLongerRoads))
writeOGR(obj=Roads, dsn=dataOutDir, layer="Roads", driver="ESRI Shapefile", overwrite_layer=TRUE) 
#Roads <- readOGR(dsn=dataOutDir, layer="Roads")

##############################################
#Other code

#Make data frame to check classification
dfp<-data.frame(ROAD_CLASS=pavedRds@data$ROAD_CLASS, ROAD_SURFACE=pavedRds@data$ROAD_SURFACE)
df1<-data.frame(ROAD_CLASS=RdUse_1@data$ROAD_CLASS, ROAD_SURFACE=RdUse_1@data$ROAD_SURFACE)
df2<-data.frame(ROAD_CLASS=RdUse_2@data$ROAD_CLASS, ROAD_SURFACE=RdUse_2@data$ROAD_SURFACE)
df3<-data.frame(ROAD_CLASS=RdUse_3@data$ROAD_CLASS, ROAD_SURFACE=RdUse_3@data$ROAD_SURFACE)

###Checking roads that were buffered outside of R for comparison
#Pull buffered roads out
BufRds<- readOGR(dsn=Rd_gdb,layer=fc_list[2])
raster::crs(BufRds) <- "+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"
summary(BufRds)
BufRdClip<-crop(BufRds, MClipRast)

#Modify CE Grizzly Bear open roads to keep all roads, but remove overgrown and boat
#Remove trails and skids - small areas and minimum effect
#For 'Open Roads' exclude:  ROAD_SURFACE in ('boat','overgrown')
O1<-subset(IntRds, !(IntRds@data$ROAD_SURFACE %in% c('boat','overgrown')))
#OR ROAD_CLASS in ('trail','skid'), Grizzly drops 'restricted', but kept here since still disturbe
#O2<-subset(O1, !(O1@data$ROAD_CLASS %in% c('trail','skid')))
#O2<-subset(O1, !(O1@data$ROAD_CLASS %in% c('trail','skid')))
#Keep trails and skids since many are non-status roads - see - FPB SP 49 
#field - transport line type code - 1 to 3 letter code - in data dictionary
#field for NE - capital T trails from transport line type code
#Seismic lines - not included

#OR FEATURE_CODE = 'DA25150100' (overgrown)
OpenRoads<-subset(O1, !(O1@data$FEATURE_TYPE == 'DA25150100'))
#save as a shape file
writeOGR(obj=OpenRoads, dsn=dataOutDir, layer="OpenRoads", driver="ESRI Shapefile", overwrite_layer=TRUE) 




