# tree sampling based on segmentation
library(rgdal)
library(mapview)
library(rgeos)
library(dplyr)
library(caret)
library(raster)
library(magrittr)

source("~/repositories/envimaR/R/getEnvi.R")
p <- getEnvi("~/natur40/cartography/")

# tree segmentation from stefan
seg <- sapply(list.files(p$uniwald_segmentierung_2018_09_10$here,
                         pattern = ".gpkg$", full.names = TRUE), readOGR)
seg <- do.call(rbind, seg)

# convert to centroid point
trees <- gCentroid(seg, byid = TRUE)
trees <- SpatialPointsDataFrame(trees, seg@data)


# forest parts data
forest <- readOGR(paste0(p$shapes$here, "uwcWaldorte.shp"))

forest_at_trees <- over(trees, forest)
trees@data <- cbind(trees@data, forest_at_trees)

# remove trees outside the forest
trees <- trees[!is.na(trees@data$FO_BASISTY),]

# thin out attribute table
trees <- trees[,c(1:13, 53, 133)]
colnames(trees@data) <- c("heightR", "chmHeight", "elev", "chmStd", "chmRatio", "slope",
                          "prCAN", "LAI", "FHD", "AGB", "area", "circularity", "calliper", "species", "age")

writeOGR(trees, paste0(p$sample_trees$here, "mof_trees.shp"), driver = "ESRI Shapefile", layer = "trees")

