### calculating annual max LAI from 8-day MODIS data and reprojecting ####

library(raster)
library(rts)
library(RCurl)
library(rgdal)
library(gdalUtils)

setwd("W:/DATA/raw_data/MODIS/MOD15A2_LAI_FPAR/")
out.folder <- "W:/DATA/reprojected_data/MODIS/MOD15A2_LAI_FPAR/"
rasterOptions(tmpdir="C:/Temp")

in.filenames <- list.files(".")
keep <- substr(in.filenames, 1, 6) == "Mosaic"
filenames.to.keep <- subset(in.filenames, keep)

new.crs <- "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 
+y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0"

#### QUICK ASIDE ON TRANSLATING QC CODES #####
# we only want to consider data that is either...
# 00000000 == 0
# 00000010 == 2   (but won't get this since it's from the Aqua sat)
# 00100000 == 32
# 00100010 == 34  (but won't get this since it's from the Aqua sat)

# to convert numbers to MODIS bits use (where NUMBER is your number)
# as.integer(intToBits(NUMBER)[1:8])[8:1]
# NOTE: qa codes are read from right to left, but each qa 'bit word' is left
# to right. blargh.


for (y in 2007:2011) {
  print(paste("starting", y, date()))
  year.to.keep <- subset(filenames.to.keep, 
                         as.numeric(substr(filenames.to.keep, 8,11)) == y)
  out.names <- substr(year.to.keep, 1,17)
  all.n <- length(year.to.keep)
  
  in.name <- paste0("W:\\DATA\\raw_data\\MODIS\\MOD15A2_LAI_FPAR\\Mosaic_", y, "-01-01.hdf")
  
  shell(cmd=paste("C:\\MODIS\\bin\\resample -p W:\\DATA\\raw_data\\MODIS\\MOD15A2_LAI_FPAR\\mod_prm.prm -i", in.name, "-o Temp_tif.tif"))
  
  in.fpar <- raster("Temp_tif.Fpar_1km.tif")
  in.fpar[in.fpar > 100] <- NA
  in.lai <- raster("Temp_tif.Lai_1km.tif")
  in.lai[in.lai > 100] <- NA
  in.qc <- raster("Temp_tif.FparLai_QC.tif")
  
  qc.mask <- in.qc == 0 | in.qc == 32
  qc.mask[qc.mask == 0] <- NA
  
  in.fpar <- in.fpar * qc.mask * 0.01
  in.lai <- in.lai * qc.mask * 0.1
  
  for (i in 2:all.n) {
    in.name <- paste0("W:\\DATA\\raw_data\\MODIS\\MOD15A2_LAI_FPAR\\", year.to.keep[i])
    shell(cmd= paste("C:\\MODIS\\bin\\resample -p W:\\DATA\\raw_data\\MODIS\\MOD15A2_LAI_FPAR\\mod_prm.prm -i", in.name ,"-o Temp_tif.tif"))
    
    new.fpar <- raster("Temp_tif.Fpar_1km.tif")
    new.fpar[new.fpar > 100] <- NA
    new.lai <- raster("Temp_tif.Lai_1km.tif")
    new.lai[new.lai > 100] <- NA
    in.qc <- raster("Temp_tif.FparLai_QC.tif")
    
    qc.mask <- in.qc == 0 | in.qc == 32
    qc.mask[qc.mask == 0] <- NA
    
    new.fpar <- new.fpar * qc.mask * 0.01
    new.lai <- new.lai * qc.mask * 0.1
    
    in.fpar <- stack(in.fpar, new.fpar)
    in.lai <- stack(in.lai, new.lai)
    
    print(paste("done with", y, "-", i))
  }
  
  fpar.max <- max(in.fpar, na.rm = TRUE)
  lai.max <- max(in.lai, na.rm = TRUE)
  
  fpar.range <- fpar.max - min(in.fpar, na.rm = TRUE)
  lai.range <- lai.max - min(in.lai, na.rm = TRUE)
  
  stack.data <- stack(fpar.max, lai.max, fpar.range, lai.range)
  
  stack.data.aea <- projectRaster(stack.data, res = res(fpar.max), crs = new.crs, method =
                                    "bilinear")
  
  writeRaster(stack.data.aea[[1]], paste0(out.folder, "fpar_max_aeaproj_", y, ".tif"))
  writeRaster(stack.data.aea[[2]], paste0(out.folder, "lai_max_aeaproj_", y, ".tif"))
  writeRaster(stack.data.aea[[3]], paste0(out.folder, "fpar_range_aeaproj_", y, ".tif"))
  writeRaster(stack.data.aea[[4]], paste0(out.folder, "lai_range_aeaproj_", y, ".tif"))
  
  # this part is to keep the temp directory from filling up
  # see where I set the temp dir at the top, or check using tmpDir()
  setwd("C:/Temp")
  temp.files <- normalizePath(list.files(pattern=glob2rx("*tmp*"),full.names =TRUE))
  if (length(temp.files) > 0) {
    do.call(file.remove, as.list(temp.files))
  }
  setwd("W:/DATA/raw_data/MODIS/MOD15A2_LAI_FPAR/")
  
  print(paste("done with 1 yr!", date()))
  
}




