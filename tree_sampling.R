# Stratified tree sampling with minimum distance
#----------------------------------------------------
library(rgdal)
library(mapview)

# load trees (from segments_to_trees.R)
trees <- readOGR("~/natur40/cartography/sample_trees/mof_trees.json")

# attributes to filter:
str(trees@data)

# define criteria
cr1 <- trees@data$chmHeight > 15
cr2 <- trees@data$species %in% c("BU", "EI")

# prefilter trees based on the defined criteria
prefilter_trees <- trees[cr1 & cr2, ]

# sampling
#-------------------
# 1. stratified sampling
# 2. minimum distance sampling

# stratified sample of the tree age
set.seed(1)
sample1 <- unlist(caret::createDataPartition(prefilter_trees@data$age, times = 1, p = 0.5, list = TRUE))

trees_sample1 <- prefilter_trees[sample1,]


# only keep trees which are 50 m apart

# source the buffer function    
#---------------------------------------------------------
source("~/repositories/TreeSampling/buffer_sampling.R")
#---------------------------------------------------------

coord_df <- as.data.frame(trees_sample1@coords)
names(coord_df) <- c("x", "y")
sample2 <- as.numeric(rownames(buffer.f(foo = coord_df, buffer = 50, reps = 1)))


trees_sample2 <- trees_sample1[sample2,]

# how many trees are left over?
nrow(trees_sample2)
# how many oaks and beeches?
table(trees_sample2@data$species)

# save sample
writeOGR(trees_sample2, "~/repositories/TreeSampling/data/sample_trees.json", driver = "GeoJSON", layer = "trees_sample2")

