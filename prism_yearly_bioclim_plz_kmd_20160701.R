### reprojecting and aggregating PRISM data ###
### written by Kyla Dahlin adapted from Phoebe Zarnetske
### last updated 20160701

#library(maptools)
library(sp)
library(dismo)
library(rgdal)

#### getting lagos projection #####
## by making a fake shapefile for the HU12.prj file from Ed 
# in.test <- readOGR("C:/Users/kdahlin/Dropbox/watercube_2015/lagos_projection",
#                    "contients")
# crs(in.test)
#####

setwd("W:/DATA/raw_data/PRISM/PRISM_monthly/")
out.folder <- "W:/DATA/reprojected_data/PRISM_bioclim/4km/"

in.ppt <- raster("ppt/us_ppt_2001.01.asc")
res.in <- res(in.ppt)

old.crs <- "+proj=longlat +datum=NAD83 +ellps=GRS80"

new.crs <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 
            +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"

out.suffix <- c("bio01", "bio02", "bio03", "bio04", "bio05", "bio06", "bio07",
                "bio08", "bio09", "bio10", "bio11", "bio12", "bio13", "bio14",
                "bio15", "bio16", "bio17", "bio18", "bio19")


for(y in 2001:2011) {
  print(paste("starting", y, date()))
  # takes the Jan data from each year
  tmin<-raster(paste("./tmin/us_tmin_",y,".01.asc",sep=""))
  tmax<-raster(paste("./tmax/us_tmax_",y,".01.asc",sep=""))
  ppt<-raster(paste("./ppt/us_ppt_",y,".01.asc",sep=""))

  # takes Feb-Sep data from each year
  for (i in 2:9) {
    tmin<-
      stack(tmin,raster(paste("./tmin/us_tmin_",y,".0",i,".asc",sep="")))
    tmax<-
      stack(tmax,raster(paste("./tmax/us_tmax_",y,".0",i,".asc",sep="")))
    ppt<-
      stack(ppt,raster(paste("./ppt/us_ppt_",y,".0",i,".asc",sep="")))
  }
  # takes Oct-Dec data from each year
  for (i in 10:12) {
    tmin<-
      stack(tmin,raster(paste("./tmin/us_tmin_",y,".",i,".asc",sep="")))
    tmax<-
      stack(tmax,raster(paste("./tmax/us_tmax_",y,".",i,".asc",sep="")))
    ppt<-
      stack(ppt,raster(paste("./ppt/us_ppt_",y,".",i,".asc",sep="")))
  }
  
  # divide all values by 100 to get in proper units
  ppt<-ppt/100
  tmin<-tmin/100
  tmax<-tmax/100

  ## (2) Compute the Bioclim Variables
  print("starting biovar calc")
  bioclim<-biovars(ppt,tmin,tmax)
  crs(bioclim) <- old.crs
  names(bioclim) <- out.suffix
  
  # reproject into Albers projection
  print("starting reprojection")
  # fun fact: if you set the resolution in projectRaster, remember that it's the
  # resolution in the NEW units, so if you're going from degrees to meters things
  # can get wonky (e.g. don't use old )
  bioclim.rp <- projectRaster(bioclim, crs = new.crs, method =
                                "bilinear")
  
  writeRaster(bioclim.rp,
              file=paste0(out.folder, "prism_bioclim_conus_aea", y, ".tif"),
              format = "GTiff", bylayer = TRUE, suffix = 'names')
  
}









