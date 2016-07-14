### code to import modis data - 
### need to have installed the MRT software to run properly
### (https://lpdaac.usgs.gov/tools/modis_reprojection_tool) 

library(raster)
library(rts)
library(RCurl)
library(rgdal)

setwd("W:/DATA/raw_data/MODIS/MCD12Q1_2001_landcover/")


date.in <- '2001.01.01'
prod <- 'MCD12Q1'
vers <- '051'
res <- 500
h <- 8:13
v <- 4:6
bands <- "1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"

# figured these 'output_projection_parameters" out using Appendix C in 
# https://lpdaac.usgs.gov/sites/default/files/public/mrt41_usermanual_032811.pdf
# and based on info in http://spatialreference.org/ref/sr-org/6703/html/
out.p.p <- "0.0 0.0 29.5 45.5 -96.0 23.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0"

print(date())
ModisDownload(prod, h=h, v=v, version=vers, bands_subset=bands,
              dates=date.in, mosaic=TRUE, delete=FALSE, 
              MRTpath='C:/MODIS/bin', proj=TRUE, proj_type='AEA', 
              datum='NAD83', pixel_size=res, proj_params=out.p.p)
print(date())

print(date())
reprojectHDF("Mosaic_2001-01-01.hdf", filename="MosaicRP_2001-01-01.tif",
             MRTpath='C:/MODIS/bin', proj_type='AEA', 
             datum='NODATUM', pixel_size=res, proj_params=out.p.p )
print(date())