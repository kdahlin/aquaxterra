#### processing MODIS LAI data ####

library(raster)
library(rts)
library(RCurl)
library(rgdal)

setwd("W:/DATA/raw_data/MODIS/MOD15A2_LAI_FPAR/")


### get directory names (by date, so not consistent by data type) ####
all.files <- getURL("http://e4ftl01.cr.usgs.gov/MOLT/MOD15A2.005/", 
                    ftp.use.epsv = FALSE,
                    dirlistonly = TRUE)
filenames <- strsplit(all.files, "\r*\n")[[1]]
sub.files <- substr(filenames, 1,4)
sub.filenames <- subset(filenames, sub.files == "<img")
files.list <- substr(sub.filenames, 52, 61)

# turn this into a list for the 'date in' parameter in loop
files.2001.2011 <- subset(files.list, as.numeric(substr(files.list,1,4)) >= 2001
                          & as.numeric(substr(files.list,1,4)) <= 2011)
#######################################################################

#### parameters for reading in CONUS data
#date.in <- '2001.01.01'
n <- length(files.2001.2011)
prod <- 'MOD15A2'
vers <- '005'
res <- 1000
h <- 8:13
v <- 4:6
bands <- "1 1 1 0 0 0"

# figured these 'output_projection_parameters" out using Appendix C in 
# https://lpdaac.usgs.gov/sites/default/files/public/mrt41_usermanual_032811.pdf
# and based on info in http://spatialreference.org/ref/sr-org/6703/html/
### not reprojecting here because it takes FOREVER! need to stack and avg first
#out.p.p <- "0.0 0.0 29.5 45.5 -96.0 23.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0"

##### loop over all dates from 2001 (first year of full data) thru 2011
##### takes about a minute per n (and there are ~50 per year)
for (i in 1:n) {
  ModisDownload(prod, h=h, v=v, version=vers, bands_subset=bands,
              dates=files.2001.2011[i], mosaic=TRUE, delete=FALSE, 
              MRTpath='C:/MODIS/bin', proj=FALSE, 
              pixel_size=res)
  print(paste("done with", i))
}

### this results in a whole bunch of mosaic-ed files for CONUS of LAI, FPAR
### and the QC file as .hdf all called 'Mosaic_YYYY-MM-DD.hdf'
### need to get into R, stack by year, calc mean, then reproject to Albers



