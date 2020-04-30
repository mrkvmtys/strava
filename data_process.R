library(strava)
library(tidyverse)
library(gtools)
library(XML)
library(trackeR)
library(sp)

# list all tcx tracks
# enter your path here where the bulk exported data is 
setwd("C:/Users/.../activities")
file_list <- list.files(pattern = ".tcx$")

# read data

# 1. GPX files are easy to process thanks to strava package
data_gps <- process_data("C:/Users/.../activities")

# 2. TCX files need to be merged together
df <- data.frame()

for (i in 1:length(file_list)){

  temp_data <- readTCX(file_list[i])
  temp_data$id <- sub(".tcx","",file_list[i])
  
  colnames(temp_data)[2:3] <- c("lat","lon")
  
  # when the GPS signal is lost, we fill it up with the latest non NA
  temp_data$lat <- na.locf(temp_data$lat, na.rm = F)
  temp_data$lon <- na.locf(temp_data$lon, na.rm = F)
  temp_data$distance <- na.locf(temp_data$distance, na.rm = F)
  
  # if all we have is NA's, then we do not keep it since it's probably a manual activity
  
  if (nrow(temp_data[is.na(temp_data$lat) == F , ]) > 0) {
    
    temp_data <- temp_data[is.na(temp_data$lat) == F , ]
    
    temp_data <- temp_data %>% dplyr::mutate(dist_to_prev = c(0, 
                               sp::spDists(x = as.matrix(.[, c("lon", "lat")]), longlat = TRUE, segments = TRUE)),
                               cumdist = cumsum(dist_to_prev), 
                               time = as.POSIXct(.$time, tz = "GMT", format = "%Y-%m-%dT%H:%M:%OS")) %>% 
                               dplyr::mutate(time_diff_to_prev = as.numeric(difftime(time, 
                               dplyr::lag(time, default = .$time[1]))), cumtime = cumsum(time_diff_to_prev))
    
  df <- rbind(df, temp_data)
 
 }
}

# data transformation
# TODO: extract activity type from XML files (run, swim, hike etc)
df$type <- NA

# bind .gpx and .tcx files
data <- rbind(data_gps, df[ , c(12,2,3,1,17,13:16)])
