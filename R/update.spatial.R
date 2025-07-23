#' Update City Spatial data
#'
#' @description
#' Function to download latest city data for mapping purposes
#' @param edav boolean: T or F depending on if final save location is in Azure
#' @param city.loc str: location to save city spatial rds
#' @returns NULL
update.city.spatial.data <- function(edav, city.loc = "Data/spatial/cities.new.rds"){

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

}


#' Update Roads Spatial data
#'
#' @description
#' Function to download latest roads data for mapping purposes
#' @param edav boolean: T or F depending on if final save location is in Azure
#' @param city.loc str: location to save roads spatial rds
#' @returns NULL
update.road.spatial.data <- function(edav, road.loc = "Data/spatial/roads.new.rds"){

  roads <- rnaturalearth::ne_download(scale = 10, type = "roads")

  if(edav){
    edav_io(io = "write", file_loc = road.loc, obj = roads)
  }else{
    readr::write_rds(roads, road.loc)
  }

}

