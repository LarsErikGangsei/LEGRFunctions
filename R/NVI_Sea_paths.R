#' @title NVI_Sea_paths: Function to find shortest sea paths. 
#' @description The function \code{NVI_Sea_paths} returns a list with shortest 
#' distances from a given set of start points to a given set of end points. 
#' @details Based on communication with ChatGPT
#' @param Starpoints,Endpoints [\code{SpatialPointDataframes}] with points defining
#' start and stop.
#' @param searaster [\code{RasterLayer}] containing map with "legal traveling areas".
#' Needs to be same crs as used in \code{Starpoints,Endpoints}.
#' 
#' @return A list with shortest (seapaths) between startpoints and endpoints. 
#' 
#'
#' @author Lars Erik Gangsei\cr
#' lars.erik.gangsei@@vetinst.no\cr
#' +47 950 61 231
#' 
#' @import sf
#' @import gdistance
#' @import tidyverse
#' @import raster
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
NVI_Sea_paths <- function(StartPoints, EndPoints, searaster) {
  # Ensure input is valid
  if (!all.equal(length(StartPoints), length(EndPoints))) {
    stop("StartPoints and EndPoints must have the same number of points.")
  }
  
  # Create transition object from raster: here we assume sea has low cost (e.g., value = 1), land = NA or high
  tr <- gdistance::transition(searaster, function(x) 1 / mean(x, na.rm = TRUE), directions = 8)
  tr <- gdistance::geoCorrection(tr, type = "c")
  
  # Prepare list to hold SpatialLines
  path_list <- vector("list", length(StartPoints))
  
  for (i in seq_along(StartPoints)) {
    sp <- coordinates(StartPoints)[i, ]
    ep <- coordinates(EndPoints)[i, ]
    
    start_coord <- SpatialPoints(matrix(sp, ncol = 2), proj4string = CRS(proj4string(StartPoints)))
    end_coord <- SpatialPoints(matrix(ep, ncol = 2), proj4string = CRS(proj4string(EndPoints)))
    
    path <- tryCatch({
      gdistance::shortestPath(tr, start_coord, end_coord, output = "SpatialLines")
    }, error = function(e) {
      warning(paste("Path", i, "failed:", e$message))
      NULL
    })
    
    path_list[[i]] <- path
  }
  
  return(path_list)
}

