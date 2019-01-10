# # # Locate Trees
#----------------------------
#
# creates tree points out of the tree segmentation
# adds information to the trees from the ufcWaldorte Shapefile

library(rgdal)
library(mapview)
library(rgeos)
library(raster)
library(caret)

source("~/repositories/envimaR/R/getEnvi.R")
p <- getEnvi("~/natur40/cartography/")

# tree segmentation from stephan
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

# additional environmental information
aspect <- raster(paste0(p$raster$here, "lidar_aspect_01m.tif"))

trees@data$aspect <- extract(aspect, trees)



# # # INCLUDE HERE:
# tree species from lcc!
#----------------------------

# remove trees outside the forest
trees <- trees[!is.na(trees@data$FO_BASISTY),]

# thin out attribute table
trees <- trees[,c(1:13, 53, 133,183)]
colnames(trees@data) <- c("heightR", "chmHeight", "elev", "chmStd", "chmRatio", "slope",
                          "prCAN", "LAI", "FHD", "AGB", "area", "circularity", "calliper", "species", "age", "aspect")

# save as geoJSON
writeOGR(trees, paste0(p$sample_trees$here, "mof_trees.shp"), driver = "ESRI Shapefile", layer = "trees")


