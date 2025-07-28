#' Extract vaccine coverage information from IHME estimates
#'
#' #' @description
#' Function to extract IHME vaccine coverage data to existing
#' spatial files. Key spatial data can be found at `https://www.healthdata.org/research-analysis/health-topics/vaccine-coverage-data`. Please keep in mind that these sources may chance and reach out to IHME directly for further information. Enter your email to gain access to the data folder. Inside the data folder go to `Geospatial Vaccine Coverage` > `04_Rasters`. Download the following geotifs and place them into a single folder in your local machine:
#' - `bcg1_cov_mean_raked_2000_2023.tif`
#' - `dpt1_cov_mean_raked_2000_2023.tif`
#' - `dpt3_cov_mean_raked_2000_2023.tif`
#' - `mcv1_cov_mean_raked_2000_2023.tif`
#' - `polio3_cov_mean_raked_2000_2023.tif`
#'
#' @param tif_folder `str` absolute path to the folder containing all tifs of interest
#' @param edav `logical` `TRUE` or `FALSE` depending on if final save location is in Azure.
#' @param output_folder `str` Absolute folder path location to save ctry, prov and dist coverage
#' data. Outputs in RDS by default, but also supports `.qs2` format.
#' @param output_format `str` '.rds' or '.qs2'
#' @returns `NULL`, invisibly.
#' @export
#' @examples
#' \dontrun{
#' update_vacc_cov_data()
#' }
#'
update_vacc_cov_data <- function(tif_folder, edav, output_folder, output_format = ".rds"){

  if (!output_format %in% c(".rds", ".qs2")) {
    cli::cli_abort("Only 'rds' and 'qs2' outputs are supported at this time.")
  }


  if (!requireNamespace("terra", quietly = TRUE)) {
    stop('Package "terra" must be installed to use this function.',
         .call = FALSE
    )
  }

  if (!requireNamespace("exactextractr", quietly = TRUE)) {
    stop('Package "terra" must be installed to use this function.',
         .call = FALSE
    )
  }

  cli::cli_process_start("Downloading SIR spatial data",
                         "SIR spatial data downloaded")
  ctry <- load_clean_ctry_sp()
  prov <- load_clean_prov_sp()
  dist <- load_clean_dist_sp()
  cli::cli_process_done()

  cli::cli_process_start("Generating a raster brick from geotifs", "Raster brick generated")
  tif_files <- list.files(tif_folder, pattern = "\\.tif$", full.names = TRUE)

  raster_brick <- terra::rast(tif_files)
  cli::cli_process_done()

  cli::cli_process_start("Extracting country level measurements", "Country level measurements extracted")

  #extracting the mean coverage by spatial area at the country level
  ctry_extract <- exactextractr::exact_extract(raster_brick, ctry, fun = "mean")

  #bind the columns of the spatial data and extracted output together
  ctry_cov <- dplyr::bind_cols(
    ctry |>
      tibble::as_tibble() |>
      dplyr::select(ADM0_NAME, GUID, yr.st, yr.end),
    ctry_extract
  ) |>
    #turn into wide format to more easily modify col names
    #the values here can change depending on how many years of data
    #are available and vaccines included so they are dynamically
    #chosen
    tidyr::pivot_longer(names(ctry_extract)[1]:names(ctry_extract)[length(ctry_extract)]) |>
    #dropping all extracts without values
    dplyr::filter(!is.na(value)) |>
    #removing '.mean' from the name
    dplyr::mutate(name = str_replace(name, "mean.", "")) |>
    #the rest of the name is separated by "_", here we
    #split them into 7 columns, this many need to be changed
    #if the naming convention changes
    tidyr::separate(name,
                    c("vacc", "cov", "type", "method",
                      "start", "end", "index")) |>
    #select variables of interest
    dplyr::select(ADM0_NAME, GUID, yr.st, yr.end, vacc,
                  start, end, index, value) |>
    #each name provides the range of years for which it is valid
    #and the index that it refers to in that range so 2000_2023_1
    #means that the range is from 2000 to 2023 and it's the first
    #item in that range, so 2000
    #we fist convert them all into integers
    dplyr::mutate(
      start = as.integer(start),
      end = as.integer(end),
      index = as.integer(index)
    ) |>
    #we then extract the specific year value
    dplyr::rowwise() |>
    dplyr::mutate(
      year = (start:end)[index]
    ) |>
    dplyr::ungroup() |>
    #we drop all inappropriate years
    dplyr::filter(dplyr::between(year, yr.st, yr.end)) |>
    dplyr::select(ADM0_NAME, GUID, year, vacc, value)

  sirfunctions_io("write", NULL, file_loc = file.path(output_folder, paste0("ctry_cov",output_format)), edav = edav, obj = ctry_cov)

  cli::cli_process_done()

  cli::cli_process_start("Extracting province level measurements", "Province level measurements extracted")

  #extracting the mean coverage by spatial area at the province level
  prov_extract <- exactextractr::exact_extract(raster_brick, prov, fun = "mean")

  prov_cov <- dplyr::bind_cols(
    prov |>
      tibble::as_tibble() |>
      dplyr::select(ADM1_NAME, GUID, yr.st, yr.end),
    prov_extract
  ) |>
    tidyr::pivot_longer(names(prov_extract)[1]:names(prov_extract)[length(prov_extract)]) |>
    dplyr::filter(!is.na(value)) |>
    dplyr::mutate(name = str_replace(name, "mean.", "")) |>
    tidyr::separate(name,
                    c("vacc", "cov", "type", "method",
                      "start", "end", "index")) |>
    dplyr::select(ADM1_NAME, GUID, yr.st, yr.end, vacc,
                  start, end, index, value) |>
    dplyr::mutate(
      start = as.integer(start),
      end = as.integer(end),
      index = as.integer(index)
    ) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      year = (start:end)[index]
    ) |>
    dplyr::ungroup() |>
    dplyr::filter(dplyr::between(year, yr.st, yr.end)) |>
    dplyr::select(ADM1_NAME, GUID, year, vacc, value)

  sirfunctions_io("write", NULL, file_loc = file.path(output_folder, paste0("prov_cov",output_format)), edav = edav, obj = prov_cov)

  cli::cli_process_done()

  cli::cli_process_start("Extracting district level measurements", "District level measurements extracted")

  #extracting the mean coverage by spatial area at the district level
  dist_extract <- exactextractr::exact_extract(raster_brick, dist, fun = "mean")

  dist_cov <- dplyr::bind_cols(
    dist |>
      tibble::as_tibble() |>
      dplyr::select(ADM2_NAME, GUID, yr.st, yr.end),
    dist_extract
  ) |>
    tidyr::pivot_longer(names(dist_extract)[1]:names(dist_extract)[length(dist_extract)]) |>
    dplyr::filter(!is.na(value)) |>
    dplyr::mutate(name = str_replace(name, "mean.", "")) |>
    tidyr::separate(name,
                    c("vacc", "cov", "type", "method",
                      "start", "end", "index")) |>
    dplyr::select(ADM2_NAME, GUID, yr.st, yr.end, vacc,
                  start, end, index, value) |>
    dplyr::mutate(
      start = as.integer(start),
      end = as.integer(end),
      index = as.integer(index)
    ) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      year = (start:end)[index]
    ) |>
    dplyr::ungroup() |>
    dplyr::filter(dplyr::between(year, yr.st, yr.end)) |>
    dplyr::select(ADM2_NAME, GUID, year, vacc, value)

  sirfunctions_io("write", NULL, file_loc = file.path(output_folder, paste0("dist_cov",output_format)), edav = edav, obj = dist_cov)

  cli::cli_process_done()

  invisible()

}
