# tree sampling based on segmentation
library(rgdal)
library(mapview)
library(rgeos)
library(dplyr)
library(sampling)

source("~/repositories/envimaR/R/getEnvi.R")
p <- getEnvi("natur40/cartography/")

seg <- sapply(list.files(p$uniwald_segmentierung_2018_09_10$here,
                         pattern = ".gpkg$", full.names = TRUE), readOGR)

trees <- do.call(rbind, seg)

# remove small trees and very large ones
hist(trees$chmHeight)
trees <- trees[trees$chmHeight > 10 & trees$chmHeight < 40, ]

# beech and oak information
bu <- readOGR(paste0(p$shapes$here, "uwcWaldorte_BU.shp"))
ei <- readOGR(paste0(p$shapes$here, "uwcWaldorte_EI.shp"))

abt <- gUnion(bu, ei)
cont <- as.vector(rgeos::gContains(abt, trees, byid = TRUE))
trees <- trees[cont,]
trees$species <- "bu"
trees$species[as.vector(rgeos::gContains(ei, trees, byid = TRUE))] <- "ei"

# sample 50 oaks and 50 beeches
set.seed(1)
s <- c(sample(which(trees$species == "ei"), 50), sample(which(trees$species == "bu"), 50))

# convert to points and visualize
tree_points <- gCentroid(trees[s,], byid = TRUE, id = rownames(trees@data[s,]))
tree_points <- SpatialPointsDataFrame(tree_points, trees@data[s,])
mapView(tree_points, zcol = "species")

rownames(trees)
