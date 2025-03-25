#' @title ScatterMap: Points in a red - green scale on top of maps. 
#' @description The function \code{ScatterMap} returns a map (land/ ocean) with 
#' poinnts on top. Colors according to strength in input. 
#' @details ...
#' @param Country_name [\code{character}] has to be listed in 
#' \code{rnaturalearth::ne_countries()$name}.
#' @param Coord_lims [\code{list}] with 2 elements.\code{lat} and \code{long}, 
#' both numeric vectors of length 2 with limits (in degrees) for latitude and 
#' longitude.
#' @param Plot_df [\code{list}].Data frame with the following elements:
#' \item \code{lat} [\code{numeric}]. Latitude for points to be plotted.
#' \item \code{long}[\code{numeric}].Longitude for points to be plotted.
#' \item \code{val}[\code{numeric}].Value for points to b illustrated.
#' \item \code{t}[\code{integer}].Indicator used to split figures with 
#' \code{ggplot2::facet_wrap()}.
#' @param cex.point [\code{numeric}]: point size. Passed to [\code{geom_point()}] 
#' as argument \code{size}.
#' @param scale_lims [\code{numeric}]: Vector of length two providing limits 
#' of the scale used in color grading
#' 
#' @return To come....
#' 
#'
#' @author Lars Erik Gangsei\cr
#' lars.erik.gangsei@@vetinst.no\cr
#' +47 950 61 231
#' 
#' @import sf
#' @import ggplot2
#' @import rnaturalearth
#' 
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
ScatterMap <- function(Country_name = 'Norway',
                       Coord_lims = list(long = c(5,35),lat = c(57,72)),
                       Plot_df,cex.point = 4,scale_lims = NULL) 
{
  # Get a polygon of interest (SpatialPolygons)
  country <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
  country <- country[country$name == Country_name, ]
  
  if(is.null(Coord_lims))
  {
    Coord_lims <- sf::st_bbox(country$geometry)
    Coord_lims = list(lat = Coord_lims[c('xmin','xmax')],
                      long = Coord_lims[c('ymin','ymax')])
    names(Coord_lims$lat) <- names(Coord_lims$long)  <- rep('',2)
  }
  
  RedMap <-  sf::st_intersection(country, 
              sf::st_as_sfc(sf::st_bbox(c(xmin = Coord_lims$long[1], 
                                      ymin = Coord_lims$lat[1], 
                                      xmax = Coord_lims$long[2], 
                                      ymax = Coord_lims$lat[2]), 
                                            crs = sf::st_crs(country))))
  Ocean <- sf::st_difference(sf::st_as_sfc(sf::st_bbox(c(xmin = Coord_lims$long[1]-1, 
                                             ymin = Coord_lims$lat[1]-1, 
                                             xmax = Coord_lims$long[2]+1, 
                                             ymax = Coord_lims$lat[2]+1),
                                           crs = sf::st_crs(country))), RedMap)
 
  
  SpatialPolygons <- as(RedMap, "Spatial")
  
  
  
  ggplot(Plot_df,mapping = aes(x = long,y = lat, # lon and lat
                       colour = Val)) + # plot points
    #ggtitle(Date) 
    #col_scale(name = "n") + # attach color scale
    xlab("Longitude (deg)") + # x-axis label
    ylab("Latitude (deg)") +# y-axis label
    geom_sf(data = RedMap,#csmaps::nor_county_map_b2024_default_dt,
            color = "black",
            inherit.aes = FALSE,
            #mapping = aes(x = long,y = lat,group = group),
            fill = NA,
            linewidth = 0.2
    )+
    geom_point(data = Plot_df,size = cex.point)+
    geom_sf(data = Ocean,#csmaps::nor_county_map_b2024_default_dt,
            color = NA,
            inherit.aes = FALSE,
            #mapping = aes(x = long,y = lat,group = group),
            fill = 'blue',
            linewidth = 0.2
    )+
    scale_color_gradient(low="green", high="red" ,na.value = NA, 
                         limits = scale_lims)+
    ylim(Coord_lims$lat[1],Coord_lims$lat[2])+
    xlim(Coord_lims$long[1],Coord_lims$long[2])+
    theme(legend.position="right")+
    facet_wrap(~t)  
}


