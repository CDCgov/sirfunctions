#' Update City Spatial data
#'
#' @description
#' Function to download latest city data for mapping purposes.
#'
#' @param edav `logical` `TRUE` or `FALSE` depending on if final save location is in Azure.
#' @param city.loc `str` Location to save city spatial rds.
#' @returns `NULL`, invisibly.
#' @export
update_city_spatial_data <- function(edav, city.loc = "Data/spatial/cities.new.rds"){

  #create temp file to store city data
  temp.cities.loc <- tempfile(fileext=".geojson")

  download.file(url = "https://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/rest/services/World_Cities/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson",
                destfile = temp.cities.loc)

  cities <- sf::st_read(temp.cities.loc)

  if(edav){
    edav_io(io = "write", file_loc = city.loc, obj = cities)
  }else{
    readr::write_rds(cities, city.loc)
  }

  invisible()

}


#' Update Roads Spatial data
#'
#' @description
#' Function to download latest roads data for mapping purposes
#' @param edav `logical` `TRUE` or `FALSE` depending on if final save location is in Azure.
#' @param road_loc `str` Location to save roads spatial rds.
#' @returns `NULL`, invisibly.
#' @export
update_road_spatial_data <- function(edav, road_loc = "Data/spatial/roads.new.rds"){

  if (!requireNamespace("rnaturalearth", quietly = TRUE)) {
    stop('Package "rnaturalearth" must be installed to use this function.',
         .call = FALSE
    )
  }

  roads <- rnaturalearth::ne_download(scale = 10, type = "roads")

  if(edav){
    edav_io(io = "write", file_loc = road.loc, obj = roads)
  }else{
    readr::write_rds(roads, road_loc)
  }

  invisible()

  }

