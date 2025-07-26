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
#' @param output_path `str` Absolute file path location to save coverage
#' data. Outputs in RDS by default, but also supports `.qs2` format.
#' @returns `NULL`, invisibly.
#' @export
#' @examples
#' \dontrun{
#' update_vacc_cov_data()
#' }
#'
update_vacc_cov_data <- function(tif_folder, edav, output_path){

  if (!endsWith(output_path, ".rds") &
      !endsWith(output_path, ".qs2")) {
    cli::cli_abort("Only 'rds' and 'qs2' outputs are supported at this time.")
  }


  if (!requireNamespace("terra", quietly = TRUE)) {
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

  tif_files <- list.files(tif_folder, pattern = "\\.tif$", full.names = TRUE)

  my_brick2 <- terra::rast(tif_files)

  x <- exactextractr::exact_extract(my_brick2, ctry, fun = "mean")
}
