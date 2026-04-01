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
create_raw_data_parquet <- function(raw_data, path) {
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
        raw_data[[i]] |>
          to_wkb_drop_sf() |>
          arrow::write_dataset(
            path = file.path(path, i),
            partitioning = get_partition_cols(i)
          )
      } else if (i %in% c("cities", "roads")) {
        raw_data[[i]] |>
          to_wkb_drop_sf() |>
          arrow::write_dataset(
            path = file.path(path, i),
            partitioning = get_partition_cols(i)
          )
      } else if (i == "metadata") {
        raw_data[[i]] |>
          dplyr::as_tibble() |>
          arrow::write_dataset(
            path = file.path(path, i),
            partitioning = get_partition_cols(i)
          )
      } else {
        raw_data[[i]] |>
          arrow::write_dataset(
            path = file.path(path, i),
            partitioning = get_partition_cols(i)
          )
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
#' @param path `str` Absolute path to the parquet folder.
#' @param from_edav `bool` Build using local files or files in EDAV? Defaults to TRUE.
#' @param container `azcontainer` An instance of an Azure container to connect.
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
build_parquet_raw_data <- function(
  path = "GID/PEB/SIR/Data/analytic",
  dataset = "all",
  from_edav = TRUE,
  container = get_azure_storage_connection()
) {
  if (from_edav) {
    # Default values
    if (is.null(path)) {
      cli::cli_abort("Please pass a file path to the parquet folder")
    }

    raw_data <- build_parquet_raw_data_edav(path, dataset, container)
  } else {
    raw_data <- build_parquet_raw_data_local(path, dataset)
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
upload_parquet_to_edav <- function(src, dest, container = get_azure_storage_connection()) {

  dir_exists <- edav_io("exists.dir", NULL, dest)
  if (!dir_exists) {
    cli::cli_abort("Folder doesn't exist on EDAV. Unable to upload")
  }

  cli::cli_process_start("Uploading parquet folder to EDAV")
  AzureStor::multiupload_adls_file(
    container,
    paste0(src, "/*"),
    file.path(dest, "raw_data_parquet"),
    recursive = TRUE
  )
  cli::cli_process_done()
}

#' Convert WKB back to sf column
#'
#' @param sf_data `arrow connection` Geodata arrow connection.
#'
#' @returns `tibble` Geodata with `sf`.
#'
#' @export
#' @examples
#' \dontrun{
#' raw_data <- build_parquet_raw_data()
#' kenya_ctry_sf <- raw_data$global.ctry |> 
#'     dplyr::filter(ctry == "KENYA") |> 
#'     dplyr::collect() |> 
#'     from_wkb_to_sf()
#' }
from_wkb_to_sf <- function(sf_data) {
  # Ensure that global shapefiles have Shape and city/roads as geometry.
  # Otherwise, need to modify this function.

  if (inherits(sf_data, "ArrowObject")) {
    cli::cli_abort("Please run dplyr::collect() first prior to passing to the function.")
  }

  if ("Shape" %in% names(sf_data)) {
    sf_data <- sf_data |>
      dplyr::mutate(Shape = sf::st_as_sfc(Shape, EWKB = TRUE, crs = 4326)) |>
      sf::st_as_sf()
  } else if ("geometry" %in% names(sf_data)) {
    sf_data <- sf_data |>
      dplyr::mutate(geometry = sf::st_as_sfc(geometry, EWKB = TRUE, crs = 4326)) |>
      sf::st_as_sf()
  } else {
    cli::cli_abort("Not an sf dataset.")
  }

  return(sf_data)
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
  switch(
    name,
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
#' @param dataset `str` A specific dataset. Defaults to `"all"`. Otherwise, can specify any dataset in the list returned by [get_all_polio_data()].
#'
#' @returns `list` A list containing connections to the folders associated with
#' individual datasets in the original output of [get_all_polio_data()].
#' @keywords internal
#'
build_parquet_raw_data_local <- function(path = NULL, dataset = "all") {
  if (!dir.exists(path)) {
    cli::cli_abort("Not a valid directory.")
  }

  valid_values <- c(
    "afp",
    "afp.dupe",
    "afp.epi",
    "para.case",
    "es",
    "es.dupe",
    "sia",
    "sia.dupe",
    "pos",
    "pos.dupe",
    "other",
    "other.dupe",
    "dist.pop",
    "prov.pop",
    "ctry.pop",
    "global.ctry",
    "global.prov",
    "global.dist",
    "ctry.coverage",
    "prov.coverage",
    "dist.coverage",
    "roads",
    "cities",
    "metadata"
  )
  data <- list.files(path)

  if (length(dataset) == 1 && dataset == "all") {
    raw_data <- list()

    for (i in valid_values) {
      
      tryCatch({
        raw_data[[i]] <- arrow::open_dataset(file.path(path, i))
      }, error = \(e) {
        cli::cli_alert_info(paste0("Dataset not found and won't be added: ", i))
        raw_data[[i]] <- NULL
      })
      
    }
  } else if (length(dataset) > 1) {
    invalid <- setdiff(dataset, valid_values)

    if (length(invalid) > 0) {
      cli::cli_alert_info("The following type passed are invalid and won't be loaded: ")
      cli::cli_li(invalid)
    }

    valid <- dataset[!dataset %in% invalid]

    if (length(valid) == 0) {
      cli::cli_abort("All the dataset passed are invalid.")
    }

    has_all <- sum(stringr::str_detect(valid, "all"))

    if (has_all >= 1) {
      cli::cli_abort("Please pass only 'all'.")
    }

    raw_data <- list()
    
    for (i in valid) {
      tryCatch({
        raw_data[[i]] <- arrow::open_dataset(file.path(path, i))
      }, error = \(e) {
        cli::cli_alert_info(paste0("Dataset not found and won't be added: ", i))
        raw_data[[i]] <- NULL
      })
    }
  } else if (length(dataset) == 1 && dataset %in% valid_values) {
    raw_data <- arrow::open_dataset(file.path(path, dataset))
  }

  return(raw_data)
}

#' Build raw_data using EDAV files
#'
#' @param path `str` Path to EDAV folder containing parquet files. This must
#' be the absolute file path from the Blob endpoint of the container.
#' @param dataset `str` A specific dataset. Defaults to `"all"`. Otherwise, can specify any dataset in the list returned by [get_all_polio_data()]. 
#' @param container `azcontainer` An instance of an Azure container to connect
#' to. Pass [get_azure_storage_connection()] using defaults if not accessing
#' using a service principal.
#'
#' @returns `list` A list containing connections to the folders associated with
#' individual datasets in the original output of [get_all_polio_data()].
#' @keywords internal
#'
build_parquet_raw_data_edav <- function(path = NULL, dataset = "all", container = get_azure_storage_connection()) {

  valid_values <- c(
    "afp",
    "afp.dupe",
    "afp.epi",
    "para.case",
    "es",
    "es.dupe",
    "sia",
    "sia.dupe",
    "pos",
    "pos.dupe",
    "other",
    "other.dupe",
    "dist.pop",
    "prov.pop",
    "ctry.pop",
    "global.ctry",
    "global.prov",
    "global.dist",
    "ctry.coverage",
    "prov.coverage",
    "dist.coverage",
    "roads",
    "cities",
    "metadata"
  )

  exist <- edav_io("exists.dir", NULL, file_loc = path, azcontainer = container)

  if (!exist) {
    cli::cli_abort("The directory does not exist on EDAV.")
  } else {
    rm(exist)
  }

  cli::cli_process_start("Building raw_data from EDAV parquet files")

  raw_data <- NULL

  if (length(dataset) == 1 && dataset == "all") {
    source_path <- file.path(path, "raw_data_parquet/*")
    local_pq <- file.path(rappdirs::user_data_dir("sirfunctions"), "raw_data_parquet")
  } else if (length(dataset) > 1) {

    invalid <- setdiff(dataset, valid_values)

    if (length(invalid) > 0) {
      cli::cli_alert_info(
        "The following type passed are invalid and won't be loaded: "
      )
      cli::cli_li(invalid)
    }

    valid <- dataset[!dataset %in% invalid]

    if (length(valid) == 0) {
      cli::cli_abort("All the dataset passed are invalid.")
    }

    has_all <- sum(stringr::str_detect(valid, "all"))

    if (has_all >= 1) {
      cli::cli_abort("Please pass only 'all'.")
    }

    source_path <- paste0(file.path(path, "raw_data_parquet"), "/", valid, "/*")
    local_pq <- paste0(file.path(rappdirs::user_data_dir("sirfunctions"), "raw_data_parquet"), "/", valid)
  } else if (length(dataset) == 1 && dataset %in% valid_values) {
    source_path <- paste0(file.path(path, "raw_data_parquet", dataset), "/*")
    local_pq <- paste0(file.path(rappdirs::user_data_dir("sirfunctions"), "raw_data_parquet"), "/", dataset)
  }

  for (i in local_pq) {


      unlink(i, recursive = TRUE, force = TRUE)
      dir.create(i, recursive = TRUE)
  
    
  }

  if (length(source_path) > 1) {
    for (i in length(source_path)) {

    AzureStor::storage_multidownload(
    container,
    src = source_path[i],
    dest = local_pq[i],
    recursive = TRUE,
    overwrite = TRUE
  )
    }
  } else {
    AzureStor::storage_multidownload(
    container,
    src = source_path,
    dest = local_pq,
    recursive = TRUE,
    overwrite = TRUE
  )
  }

  raw_data <- build_parquet_raw_data_local(file.path(rappdirs::user_data_dir("sirfunctions"), "raw_data_parquet"), dataset)
  cli::cli_process_done()

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
  wkb <- unclass(wkb) # <- key line: makes it a plain list Arrow can infer

  sf_data[[geom_col]] <- wkb

  return(sf_data)
}