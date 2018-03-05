library(sf)
library(dplyr)
library(readr)

TmpDir <- 'tmp'
OutDir <- 'out'
DataDir <- 'data'
dataOutDir <- file.path(OutDir,'data')
tileOutDir <- file.path(dataOutDir,'tile')

dir.create(TmpDir, showWarnings = FALSE)
dir.create(OutDir, showWarnings = FALSE)
dir.create(DataDir, showWarnings = FALSE)
dir.create(file.path(dataOutDir), showWarnings = FALSE)
dir.create(file.path(tileOutDir), showWarnings = FALSE)

