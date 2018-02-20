library(sf)
library(dplyr)
library(readr)

OutDir<-('out/')
figsOutDir<-paste(OutDir,'figures/',sep='')
dataOutDir<-paste(OutDir,'data/',sep='')
tileOutDir<-paste(dataOutDir,'tile/',sep='')
DataDir <- "data"
dir.create(file.path(OutDir), showWarnings = FALSE)
dir.create(file.path(figsOutDir), showWarnings = FALSE)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
dir.create(file.path(tileOutDir), showWarnings = FALSE)
dir.create(DataDir, showWarnings = FALSE)
