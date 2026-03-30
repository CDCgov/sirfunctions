#' Update City Spatial data
#'
#' @description
#' Function to download latest city data for mapping purposes.
#'
#' @param edav `logical` `TRUE` or `FALSE` depending on if final save location is in Azure.
#' @param output_path `str` Absolute file path location to save city spatial data. Outputs in RDS by default,
#' but also supports `.qs2` format.
#' @returns `NULL`, invisibly.
#' @export
#' @examples
#' \dontrun{
#' update_city_spatial_data(edav = TRUE)
#' }
#'
update_city_spatial_data <- function(edav, output_path = "GID/PEB/SIR/Data/spatial/cities.new.rds"){

  if (!endsWith(output_path, ".rds") &
      !endsWith(output_path, ".qs2")) {
    cli::cli_abort("Only 'rds' and 'qs2' outputs are supported at this time.")
  }

  #create temp file to store city data
  temp.cities.loc <- tempfile(fileext=".geojson")

  download.file(url = paste0("https://services.arcgis.com/P3ePLMYs2RVChkJx/arcgis/",
                             "rest/services/World_Cities/FeatureServer/0/",
                             "query?outFields=*&where=1%3D1&f=geojson"),
                destfile = temp.cities.loc)

  cities <- sf::st_read(temp.cities.loc)

  sirfunctions_io("write", NULL, file_loc = output_path, edav = edav, obj = cities)
  invisible()

}


#' Update Roads Spatial data
#'
#' @description
#' Function to download latest roads data for mapping purposes
#' @param edav `logical` `TRUE` or `FALSE` depending on if final save location is in Azure.
#' @param output_path `str` Absolute file path location to save roads spatial data. Outputs in RDS by default,
#' but also supports `.qs2` format.
#' @param resolution `int` options are 110 (low resolution), 50 (medium resolution)
#' and 10 (high resolution); default is 10
#' @returns `NULL`, invisibly.
#' @export
#' @examples
#' \dontrun{
#' update_road_spatial_data(edav = TRUE)
#' }
#'
update_road_spatial_data <- function(edav, output_path = "GID/PEB/SIR/Data/spatial/roads.new.rds",
                                     resolution = 10){

  if (!endsWith(output_path, ".rds") &
      !endsWith(output_path, ".qs2")) {
    cli::cli_abort("Only 'rds' and 'qs2' outputs are supported at this time.")
  }


  if (!requireNamespace("rnaturalearth", quietly = TRUE)) {
    stop('Package "rnaturalearth" must be installed to use this function.',
         .call = FALSE
    )
  }

  if (!resolution %in% c(10, 50, 110)) {
    stop("Resolution must be either 10, 50 or 110", .call = FALSE)
  }

  roads <- rnaturalearth::ne_download(scale = resolution, type = "roads")

  sirfunctions_io("write", NULL, file_loc = output_path, edav = edav, obj = roads)
  invisible()

  }

