#' @title NVI_Sea_distances: Function to calculate Sea distances. 
#' @description The function \code{NVI_Sea_distances} returns a map with shortest 
#' distances from a given location to points locations in the sea. 
#' @details Based on script from Lars Qviller, NVI
#' @param sea_shape_path [\code{character}] path to file with shape-files
#' for the sea area.
#' @param location [\code{sf-object}?] containing one point. Needs to be same 
#' crs as used in \code{sea_shape_path}.
#' @param  radius [\code{number}]. The radius for whithin distances should be 
#' calculated. In \code{meters}.
#' @param  resolution [\code{number}]. Resolution/ size of raster pixels. 
#' In \code{meters}.
#' 
#' @return To come....
#' 
#'
#' @author Lars Erik Gangsei\cr
#' lars.erik.gangsei@@vetinst.no\cr
#' +47 950 61 231
#' 
#' @import sf
#' @import gdistance
#' @import sf
#' @import tidyverse
#' 
#' @examples
#' \dontrun{
#'
#' # Might come
#' 
#' }
#'
#'
#' @export
NVI_Sea_distances <- function(sea_shape_path = file.path('//vetinst.no\\dfs-felles',
                    'StasjonK','FAG','EksterneDatakilder','Lokreg','StotteData',
                    'hav_300_100','hdr.adf'),
                    location, 
                    radius = 200000,
                    resolution = 100) 
{
  # Set some options fpr the rasteroptions
  rasterOptions(maxmemory = 32e+09)
  rasterOptions(memfrac = 0.9)
  
  # Get the sea as a rastermap
  sea_raster <- raster::raster(paste0(sea_shape_path,'hdr.adf'))
  
  if(st_crs(sea_raster)!=st_crs(location))
  {stop('Need same crs for location and sea raster')}
  
  # Get the are of interest based on the set radius distance
  crop_clip <- sf::st_buffer(location, dist = radius)
  sea_raster <- raster::crop(sea_raster, crop_clip)
  
  h16 <- transition(sea_raster, transitionFunction = function(x){1}, 
                    directions = 16)
  h16 <-  geoCorrection(h16,  scl=FALSE)
   
  if(dim(location)[1]==1){
  cost  <-  accCost(h16,sf::st_coordinates(location))
  }else{
    cost <- as.matrix(gdistance::costDistance(h16,sf::st_coordinates(location)))
  }
   
  return(cost) 
  
   
}


