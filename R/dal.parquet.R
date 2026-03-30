#' Convert raw data into a parquet hierarchal folder
#'
#' The function takes a `raw_data` object (output of [get_all_polio_data()]) and
#' saves it into a parquet directory
#' @param raw_data `list` A `raw_data` object.
#' @param path `str` Path to export the parquet folder to.
#'
#' @returns None.
#' @export
#'
#' @examples
#' \dontrun{
#' raw_data <- get_all_polio_data()
#' create_raw_data_parquet(raw_data, "C:/Users/ABC1/Desktop/raw_data_parquet")
#' }
create_raw_data_parquet <- function(raw_data, path){

  df_names <- names(raw_data)

  old_threads <- getOption("arrow.use_threads")
  options(arrow.use_threads = TRUE)
  on.exit(options(arrow.use_threads = old_threads), add = TRUE)

  if (!dir.exists(path)) {
    cli::cli_abort("Directory path does not exist.")
  }

  cli::cli_process_start("Creating raw_data parquet folder")
  iter <- 1
  for (i in df_names) {
    cli::cli_alert_info(paste0("Now processing: ", i))

    data <- 

    if (i %in% c("global.ctry", "global.prov", "global.dist")) {
      to_wkb_drop_sf(raw_data[[i]], "Shape") |>
        arrow::write_dataset(path = file.path(path, i),
                             partitioning = get_partition_cols(i))

    } else if (i %in% c("cities", "roads")) {
      to_wkb_drop_sf(raw_data[[i]], "geometry") |>
        arrow::write_dataset(path = file.path(path, i),
                             partitioning = get_partition_cols(i))

    } else if (i == "metadata") {
      raw_data[[i]] |>
        dplyr::as_tibble() |>
        arrow::write_dataset(path = file.path(path, i),
                             partitioning = get_partition_cols(i))
    } else {
      raw_data[[i]] |> arrow::write_dataset(path = file.path(path, i),
                                            partitioning = get_partition_cols(i))
    }

    cli::cli_alert_info(paste0(iter, "/", length(df_names), " processed."))
    iter <- iter + 1
  }

  cli::cli_process_done()
}

#' Recreate raw data from local parquet folder
#'
#' @description
#' Recreates an output of [get_all_polio_data()] from a folder housing
#' data in parquet format.
#'
#' @param path `str` Local path to the parquet folder
#' @param from_edav `bool` Build using local files or files in EDAV?
#' @param container `azcontainer` An instance of an Azure container to connect
#' to. Pass [get_azure_storage_connection()] using defaults if not accessing
#' using a service principal.
#' 
#' @details
#' For tibbles with Shapes, pass to [from_wkb_to_sf()] first before creating maps.
#'
#' @returns `list` A list containing connections to the folders associated with
#' individual datasets in the original output of [get_all_polio_data()].
#' @export
#'
#' @examples
#' \dontrun{
#' # Building raw_data locally
#' parquet_path <- "C:/Users/ABC1/Desktop/parquet_folder"
#' raw_data <- build_parquet_raw_data(parquet_path)
#'
#' # Build raw_data from EDAV
#' raw_data <- build_parquet_raw_data()
#' }
build_parquet_raw_data <- function(path = NULL, from_edav = F, container = NULL) {

  if (from_edav) {
    # Default values
    if (!is.null(path)) {
      path <- "GID/PEB/SIR/Sandbox/parquet_sandbox"
    }
    if (!is.null(container)) {
      container <- get_azure_storage_connection()
    }

    raw_data <- build_parquet_raw_data_edav(path, container)
  } else {
    raw_data <- build_parquet_raw_data_local(path)
  }

  return(raw_data)
}

#' Uploads a local parquet folder to EDAV
#'
#' Uploads a folder containing parquet files to EDAV
#'
#' @param src `str` Local path to the parquet folder.
#' @param dest `str` EDAV endpoint.
#' @param container `azcontainer` An instance of an Azure container.
#'
#' @returns None.
#' @export
#'
#' @examples
#' \dontrun{
#' local_dir <- "C:/Users/ABC1/Desktop/parquet_folder"
#' edav_dir <- "ABC/parquet_folder"
#' upload_parquet_to_edav(local_dir, edav_dir)
#' }
upload_parquet_to_edav <- function(src, dest, container = NULL) {
  if (is.null(container)) {
    container <- get_azure_storage_connection()
  }

  while (TRUE) {
    cli::cli_alert_info(paste0("Confirm upload to: ", dest, "/", basename(src), " (y/n)"))
    response <- stringr::str_to_lower(stringr::str_trim(readline("> ")))
    if (!response %in% c("y", "n")) {
      cli::cli_alert_warning("Invalid response. Try again.")
    } else if (response == "n") {
      cli::cli_alert("Upload cancelled.")
    } else if (response == "y") {
      break
    }
  }

  cli::cli_process_start("Uploading parquet folder to EDAV")
  start <- Sys.time()
  AzureStor::multiupload_adls_file(container, paste0(src, "/*"), dest,
                                   recursive = TRUE)
  cli::cli_process_done()
  cli::cli_alert_success(c("Uploaded in: ",
                           round(difftime(Sys.time(), start, "mins"), 2),
                           " mins"))
}

# Private functions ----

#' Gets the column used to partition a column
#'
#' @param name `str` Name of the column
#'
#' @returns `chr` A character vector of columns to partition with.
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' get_partition_cols("afp")
#' }
get_partition_cols <- function(name) {
  switch(name,
         "afp" = "yronset",
         "afp.dupe" = "yronset",
         "afp.epi" = "yronset",
         "para.case" = "yronset",
         "es" = "collect.yr",
         "es.dupe" = "collect.yr",
         "sia" = "yr.sia",
         "sia.dupe" = "yr.sia",
         "pos" = "yronset",
         "pos.dupe" = "yronset",
         "other" = "yronset",
         "other.dupe" = "yronset",
         "dist.pop" = "year",
         "prov.pop" = "year",
         "ctry.pop" = "year",
         "global.ctry" = "WHO_REGION",
         "global.prov" = "WHO_REGION",
         "global.dist" = "WHO_REGION",
         "ctry.coverage" = "year",
         "prov.coverage" = "year",
         "dist.coverage" = "year",
         "roads" = "continent",
         "cities" = "POP_CLASS",
         "metadata" = "download_time"
         )
}

#' Build raw_data using local parquet files
#'
#' @param path `str` A path to the parquet directory
#'
#' @returns `list` A list containing connections to the folders associated with
#' individual datasets in the original output of [get_all_polio_data()].
#' @keywords internal
#'
build_parquet_raw_data_local <- function(path = NULL) {

  if (!dir.exists(path)) {
    cli::cli_abort("Not a valid directory.")
  }

  valid_values <- c("afp", "afp.dupe", "afp.epi", "para.case", "es", "es.dupe",
                    "sia", "sia.dupe", "pos", "pos.dupe", "other", "other.dupe",
                    "dist.pop", "prov.pop", "ctry.pop", "global.ctry",
                    "global.prov", "global.dist", 
                    "ctry.coverage", "prov.coverage", "dist.coverage",
                    "roads" , "cities", "metadata"
                    )
  data <- list.files(path)
  data <- intersect(data, valid_values)

  raw_data <- list()
  for (i in data) {
    raw_data[[i]] <- arrow::open_dataset(file.path(path, i))
  }

  return(raw_data)

}

#' Build raw_data using EDAV files
#'
#' @param path `str` Path to EDAV folder containing parquet files. This must
#' be the absolute file path from the Blob endpoint of the container.
#' @param container `azcontainer` An instance of an Azure container to connect
#' to. Pass [get_azure_storage_connection()] using defaults if not accessing
#' using a service principal.
#'
#' @returns `list` A list containing connections to the folders associated with
#' individual datasets in the original output of [get_all_polio_data()].
#' @keywords internal
#'
build_parquet_raw_data_edav <- function(path = NULL, container = NULL, ...) {

  if (is.null(container)) {
    container <- get_azure_storage_connection()
  }

  exist <- edav_io("exists.dir", default_dir = "",
                   file_loc = path, azcontainer = container)
  if (!exist) {
    cli::cli_abort("The directory does not exist on EDAV.")
  } else {
    rm(exist)
  }

  cli::cli_process_start("Building raw_data from EDAV parquet files")
  start <- Sys.time()

  raw_data <- NULL
  # Download files locally in the temp directory first
  withr::with_tempdir({
    local_pq <- file.path(getwd(), basename(path))
    AzureStor::storage_multidownload(container,
                                      src = paste0(path, "/*"),
                                      dest = local_pq,
                                      recursive = TRUE,
                                      overwrite = TRUE
                                      )

    raw_data <- build_parquet_raw_data_local(local_pq)
    cli::cli_process_done()
  })
  
  cli::cli_process_start(paste0("Built in ", difftime(Sys.time(), start, "mins"), " mins."))

  return(raw_data)

}

#' Drop Shape column and convert to binary
#'
#' @param x `sf` or `data.frame` Geodata.
#' 
#' @details
#' This function was written using the CDC EDAV Chatbot using the model GPT-5.2.
#' @returns `tibble` dData without any Shape column.
#'
#' @keywords internal
#' 
to_wkb_drop_sf <- function(sf_data) {

  if ("Shape" %in% names(sf_data)) {
    geom_col <- "Shape"
  } else if ("geometry" %in% names(sf_data)) {
    geom_col <- "geometry"
  } else {
    cli::cli_abort("Not an sf dataset.")
  }

  # Works whether x is sf or a plain data.frame with an sfc column
  geom <- if (inherits(sf_data, "sf")) {
    sf::st_geometry(sf_data)
  } else {
    sf_data[[geom_col]]
  } 

  # Convert to WKB (list of raw vectors), then drop the "WKB" class
  wkb <- sf::st_as_binary(geom)
  wkb <- unclass(wkb)   # <- key line: makes it a plain list Arrow can infer

  sf_data[[geom_col]] <- wkb
  if (inherits(sf_data, "sf")) {
     sf_data <- sf::st_drop_geometry(sf_data)
  }
  return(sf_data)
}

#' Convert WKB back to sf column
#'
#' @param sf_data `arrow connection` Geodata arrow connection.
#'
#' @returns `tibble` Geodata with `sf`.
#'
#' @export
from_wkb_to_sf <- function(sf_data) {


  # Ensure that global shapefiles have Shape and city/roads as geometry. 
  # Otherwise, need to modify this function.
  if ("Shape" %in% names(sf_data)) {
    wkb_col <- "Shape"
  } else if ("geometry" %in% names(sf_data)) {
    wkb_col <- "geometry"
  } else {
    cli::cli_abort("Not an sf dataset.")
  }

  sf_data |>
    dplyr::mutate(dplyr::across(dplyr::any_of(wkb_col), \(x) {
      sf::st_as_sf(x, EWKB = TRUE, crs = 4326)
    }))
  
  return(sf_data)

}