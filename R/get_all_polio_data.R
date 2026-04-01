#' Retrieve all pre-processed polio data
#'
#' @description Download POLIS data from the CDC pre-processed endpoint. By default
#' this function will return a "small" or recent dataset. This is primarily for data
#' that is from the past six years. You can specify a "medium" sized dataset for data
#' that is from 2016 onwards. Finally the "large" sized dataset will provide information
#' from 2000 onwards. Regular pulls form the data will recreate the "small" dataset
#' when new information is available and the Data Management Team can force the
#' creation of the "medium" and "large" static datasets as necessary.
#'
#' @param size `str` Size of data to download. Defaults to `"small"`.
#' - `"small"`: Data from the last six years.
#' - `"medium"`: Data from 2016-present.
#' - `"large"`: Data from 2000-present.
#' @param data_folder `str` Location of the data folder containing pre-processed POLIS data,
#' spatial files, coverage data, and population data. Defaults to `"GID/PEB/SIR/Data"`.
#' @param polis_folder `str` Location of the POLIS folder. Defaults to `"GID/PEB/SIR/POLIS"`.
#' @param core_ready_folder `str` Which core ready folder to use. Defaults to `"Core_Ready_Files"`.
#' @param force.new.run `logical` Default `FALSE`, if `TRUE` will run recent data and cache.
#' @param recreate.static.files `logical` Default `FALSE`, if `TRUE` will run all data and cache.
#' @param attach.spatial.data `logical` Default `TRUE`, adds spatial data to downloaded object.
#' @param use_edav `logical` Build raw data list using EDAV files. Defaults to `TRUE`.
#' @param archive Logical. Whether to archive previous output directories
#'    before overwriting. Default is `TRUE`.
#' @param keep_n_archives Numeric. Number of archive folders to retain.
#'   Defaults to `Inf`, which keeps all archives. Set to a finite number
#'   (e.g., 3) to automatically delete older archives beyond the N most recent.
#' @param output_format str: output_format to save files as.
#' Available formats include 'rds' and 'qs2'. Defaults is 'rds'.
#' @param local_caching `logical` Enable local caching so data is stored locally and
#' only downloaded when there is updated data from EDAV.
#' @param use_archived_data `logical` Allows the ability to recreate the raw data file using previous
#' preprocessed data. If
#' @returns Named `list` containing polio data that is relevant to CDC.
#' @examples
#' \dontrun{
#' raw.data <- get_all_polio_data() # downloads data for last 6 years, including spatial files
#' raw.data <- get_all_polio_data(size = "small", attach.spatial.data = FALSE) # exclude spatial data
#' }
#'
#' @export
get_all_polio_data <- function(
    size = "small",
    data_folder = "GID/PEB/SIR/Data",
    polis_folder = "GID/PEB/SIR/POLIS",
    core_ready_folder = "Core_Ready_Files",
    force.new.run = FALSE,
    recreate.static.files = FALSE,
    attach.spatial.data = TRUE,
    use_edav = TRUE,
    use_archived_data = FALSE,
    archive = TRUE,
    keep_n_archives = Inf,
    output_format = "rds",
    local_caching = TRUE) {

  # check to see that size parameter is appropriate
  if (!size %in% c("small", "medium", "large")) {
    stop("The parameter 'size' must be either 'small', 'medium', or 'large'")
  }

  # Check output format
  if (!output_format %in% c("rds", "qs2")) {
    stop("Only rds and qs2 is supported at this time.")
  }

# normalize and validate both output formats
output_format <- normalize_format(output_format)

# Fail safe in instances where EDAV connection fails
if (use_edav) {
  verify_edav <- tryCatch(
    {
      invisible(capture.output(test_EDAV_connection()))
      cli::cli_alert_success("Connect to EDAV successful.")
      TRUE
    },
    error = \(e) {
      cli::cli_alert_info("Connection to EDAV unsuccessful.")
      FALSE
    }
  )

  if (!verify_edav) {
    cli::cli_alert_info("Unable to obtain data from EDAV. Loading from local cache instead.")
    cli::cli_alert_info("NOTE: Data may be stale. Please review the global polio dataset metadata for information on when the data was last processed.")
    raw.data <- force_load_polio_data_cache(attach.spatial.data, output_format)
    return(raw.data)
  }
}

# Constant variables
# Each file comes out of these folders
analytic_folder <- file.path(data_folder, "analytic")
polis_data_folder <- file.path(data_folder, "polis")
spatial_folder <- file.path(data_folder, "spatial")
coverage_folder <- file.path(data_folder, "coverage")
pop_folder <- file.path(data_folder, "pop")

# Year cutoffs for the different datasets
current_year <- lubridate::year(Sys.Date())
small_year <- current_year - 5
med_year <- 2016 #hardcode to 2016 because it's an important point in time

# Required files
raw_data_recent_name <- paste0("raw.data.recent", output_format)
raw_data_medium_name <- paste0("raw.data.", med_year, ".", small_year - 1, output_format)
raw_data_2000_name <- paste0("raw.data.2000.", med_year - 1, output_format)
spatial_data_name <- paste0("spatial.data", output_format)
global_ctry_sf_name <- "global.ctry.rds"
global_prov_sf_name <- "global.prov.rds"
global_dist_sf_name <- "global.dist.rds"

# Perform check to build using the archived polis folder
if (use_archived_data) {
  cli::cli_alert_info("Using archived data")
  cli::cli_alert_info("NOTE: the metadata will be for the most recent pull")
  polis_data_folder <- get_archived_polis_data(
    data_folder,
    use_edav,
    keep_n_archives
  )
  recreate.static.files <- TRUE
}

# look to see if the recent raw data rds is in the analytic folder
prev_table <- sirfunctions_io("list", NULL, analytic_folder,
  edav = use_edav
)

if (nrow(prev_table) > 0) {
  prev_table <- prev_table |>
    dplyr::filter(grepl(raw_data_recent_name, name)) |>
    dplyr::select("file" = "name", "size", "ctime" = "lastModified")
} else {
  # if empty, make sure to recreate tibble to the right format
  prev_table <- tibble(
    "file" = NA,
    "size" = NA,
    "ctime" = NA
  ) |>
    dplyr::mutate(file = as.character(file),
                  size = as.double(size),
                  ctime = as_datetime(ctime)) |>
    dplyr::filter(!is.na(file))
}

if (recreate.static.files | force.new.run) {
  force.new.run <- T
  create.cache <- T
}


if (!force.new.run) {

  # Check if using the local cache is sufficient
  if (use_edav & size == "small" & local_caching) {
    if (!recache_raw_data(analytic_folder, use_edav, output_format)) {

      raw.data <- sirfunctions_io("read", NULL, file.path(rappdirs::user_data_dir("sirfunctions"),
                                                          paste0("raw_data", output_format)),
                                  edav = FALSE)

      cli::cli_process_start("Checking for duplicates in datasets.")
      raw.data <- duplicate_check(raw.data)
      cli::cli_process_done()
      if (attach.spatial.data) {
        if (!recache_spatial_data(analytic_folder, spatial_folder,
                                  use_edav, output_format)) {
          spatial.data <- sirfunctions_io("read", NULL, file.path(rappdirs::user_data_dir("sirfunctions"),
                                                                  paste0("spatial_data", output_format)),
                                          edav = FALSE)
          raw.data$global.ctry <- spatial.data$global.ctry
          raw.data$global.prov <- spatial.data$global.prov
          raw.data$global.dist <- spatial.data$global.dist
          raw.data$roads <- spatial.data$roads
          raw.data$cities <- spatial.data$cities

          return(raw.data)
        } else {
          spatial.data <- sirfunctions_io("read", NULL, file.path(analytic_folder, spatial_data_name),
                                          edav = use_edav)
          sirfunctions_io("write", NULL, file.path(rappdirs::user_data_dir("sirfunctions"),
                                                                  paste0("spatial_data", output_format)),
                                          obj = spatial.data,
                                          edav = FALSE)
          edav_spatial_timestamp <- sirfunctions_io(
            "read",
            NULL,
            file.path(analytic_folder, paste0("spatial_timestamp", output_format)),
            edav = use_edav
          )
          sirfunctions_io("write", NULL, file.path(rappdirs::user_data_dir("sirfunctions"),
                                                   paste0("spatial_timestamp", output_format)),
                          obj = edav_spatial_timestamp,
                          edav = FALSE)

          raw.data$global.ctry <- spatial.data$global.ctry
          raw.data$global.prov <- spatial.data$global.prov
          raw.data$global.dist <- spatial.data$global.dist
          raw.data$roads <- spatial.data$roads
          raw.data$cities <- spatial.data$cities

          return(raw.data)
        }
      } else {
        return(raw.data)
      }
    }
  }

  if (use_edav) {
    cli::cli_alert_info(paste0("Downloading most recent active polio data from ", small_year," onwards"))
  } else {
    cli::cli_alert_info(paste0("Loading most recent active polio data from ", small_year," onwards"))
  }

  raw.data.small.pull <- sirfunctions_io("read", NULL, prev_table$file, edav = use_edav)

  if (size == "small") {
    raw.data <- raw.data.small.pull
  }

  if (size == "medium") {
    prev_table <- sirfunctions_io("list", NULL, analytic_folder, edav = use_edav) |>
      dplyr::filter(grepl(raw_data_medium_name, name)) |>
      dplyr::select("file" = "name", "size", "ctime" = "lastModified")

    if (use_edav) {
      cli::cli_alert_info(paste0("Downloading static polio data from ", med_year, "-", small_year))
    } else {
      cli::cli_alert_info(paste0("Loading static polio data from ", med_year, "-", small_year))
    }

    raw.data.medium.pull <- sirfunctions_io("read", NULL, prev_table$file, edav = use_edav)

    raw.data <- split_concat_raw_data(
      action = "concat",
      raw.data.small.pull = raw.data.small.pull,
      raw.data.medium.pull = raw.data.medium.pull
    )
  }

  if (size == "large") {
    prev_table <- sirfunctions_io("list", NULL, analytic_folder,
                                  edav = use_edav, full_names = TRUE
    ) |>
      dplyr::filter(grepl(raw_data_medium_name, name)) |>
      dplyr::select("file" = "name", "size", "ctime" = "lastModified")

    if (use_edav) {
      cli::cli_alert_info(paste0("Downloading static polio data from ", med_year, "-", small_year))
    } else {
      cli::cli_alert_info(paste0("Loading static polio data from ", med_year, "-", small_year))
    }

    raw.data.medium.pull <- sirfunctions_io("read", NULL, prev_table$file, edav = use_edav)

    prev_table <- sirfunctions_io("list", NULL, analytic_folder, edav = use_edav) |>
      dplyr::filter(grepl(raw_data_2000_name, name)) |>
      dplyr::select("file" = "name", "size", "ctime" = "lastModified")

    if (use_edav) {
      cli::cli_alert_info(paste0("Downloading static polio data from 2001-", med_year))
    } else {
      cli::cli_alert_info(paste0("Loading static polio data from 2001-", med_year))
    }

    raw.data.large.pull <- sirfunctions_io("read", NULL, prev_table$file, edav = use_edav)

    raw.data <- split_concat_raw_data(
      action = "concat",
      raw.data.small.pull = raw.data.small.pull,
      raw.data.medium.pull = raw.data.medium.pull,
      raw.data.large.pull = raw.data.large.pull
    )
  }

  # Only cache the small dataset, which we use in 90% of the case
  if (use_edav & local_caching) {
    raw_data_timestamp_exists <- invisible(sirfunctions_io(
      "exists.file",
      NULL,
      file.path(analytic_folder, paste0("raw_data_timestamp", output_format)),
      edav = use_edav
    ))

  } else {
    raw_data_timestamp_exists <- FALSE
  }
  if (size == "small" & raw_data_timestamp_exists & local_caching) {
    cli::cli_process_start("Caching global polio data locally")

    if (!dir.exists(rappdirs::user_data_dir("sirfunctions"))) {
      dir.create(rappdirs::user_data_dir("sirfunctions"), recursive = TRUE)
    }

    sirfunctions_io("write", NULL,
                    file.path(rappdirs::user_data_dir("sirfunctions"), paste0("raw_data", output_format)),
                    obj = raw.data,
                    edav = FALSE)
    # Add edav tag file to local cache dir
    edav_raw_data_timestamp <- sirfunctions_io(
      "read",
      NULL,
      file.path(analytic_folder, paste0("raw_data_timestamp", output_format)),
      edav = use_edav
    )

    sirfunctions_io("write", NULL,
                    file.path(rappdirs::user_data_dir("sirfunctions"), paste0("raw_data_timestamp", output_format)),
                    obj = edav_raw_data_timestamp,
                    edav = FALSE)

    cli::cli_process_done()
  }

  cli::cli_process_done()

  cli::cli_process_start("Checking for duplicates in datasets.")
  raw.data <- duplicate_check(raw.data)
  cli::cli_process_done()

  if (attach.spatial.data) {

    # Don't recache spatial if up to date
    if (!recache_spatial_data(analytic_folder, spatial_folder,
                              use_edav, output_format) & local_caching) {
      spatial.data <- sirfunctions_io("read", NULL, file.path(rappdirs::user_data_dir("sirfunctions"),
                                                              paste0("spatial_data", output_format)),
                                      edav = FALSE)
      raw.data$global.ctry <- spatial.data$global.ctry
      raw.data$global.prov <- spatial.data$global.prov
      raw.data$global.dist <- spatial.data$global.dist
      raw.data$roads <- spatial.data$roads
      raw.data$cities <- spatial.data$cities

      return(raw.data)
    }

    if (use_edav) {
      cli::cli_process_start("Downloading and attaching spatial data")
    } else {
      cli::cli_process_start("Loading and attaching spatial data")
    }

    spatial.data <- sirfunctions_io("read", NULL,
                                      file.path(analytic_folder, spatial_data_name),
                                      edav = use_edav
      )

    raw.data$global.ctry <- spatial.data$global.ctry
    raw.data$global.prov <- spatial.data$global.prov
    raw.data$global.dist <- spatial.data$global.dist
    raw.data$roads <- spatial.data$roads
    raw.data$cities <- spatial.data$cities

    cli::cli_process_done()

    if (use_edav & local_caching) {
      spatial_timestamp_exists <- sirfunctions_io(
        "exists.file",
        NULL,
        file.path(analytic_folder, paste0("spatial_timestamp", output_format)),
        edav = use_edav
      )
    } else {
      spatial_timestamp_exists <- FALSE
    }

    if (recache_spatial_data(analytic_folder, spatial_folder,
                             use_edav, output_format) & spatial_timestamp_exists & local_caching) {
      sirfunctions_io("write",
                      NULL,
                      file.path(rappdirs::user_data_dir("sirfunctions"),
                                paste0("spatial_data",
                                output_format)),
                      obj = spatial.data,
                      edav = FALSE)

      spatial_processed_tag <- sirfunctions_io("read",
                                               NULL,
                                               file.path(analytic_folder,
                                                         paste0("spatial_timestamp", output_format)),
                                               edav = use_edav)
      sirfunctions_io("write",
                      NULL,
                      file.path(rappdirs::user_data_dir("sirfunctions"),
                                paste0("spatial_timestamp", output_format)),
                      obj = spatial_processed_tag,
                      edav = FALSE)
    }
  }

  return(raw.data)

} else {

  # Check that the required folders have data
  for (folder in c(analytic_folder, polis_data_folder, spatial_folder,
                   coverage_folder, pop_folder)) {

    # get_all_polio_data will recreate the analytic folder if it's missing
    switch(basename(folder),
           "analytic" = {
             if (!sirfunctions_io("exists.dir", NULL, folder, edav = use_edav)) {
               cli::cli_alert_info("No analytics folder found. Will create a new one.")
               sirfunctions_io("create.dir", NULL, folder, edav = use_edav)
             }
           },
           "polis" = {
             if (!sirfunctions_io("exists.dir", NULL, folder, edav = use_edav)) {
               cli::cli_alert_info("Creating polis folder in the data folder")
               sirfunctions_io("create.dir", NULL, folder, edav = use_edav)
             } else {
               cli::cli_alert_info("Moving updated polis data to the data folder")
             }


             create_polis_data_folder(
              data_folder,
              polis_folder,
              core_ready_folder,
              use_edav,
              archive,
              keep_n_archives
            )

           },
           "spatial" = {
             if (!sirfunctions_io("exists.dir", NULL, folder, edav = use_edav)) {
               cli::cli_abort(paste0("No spatial data found in the data folder.",
                                     " Ensure that the output folder when running ",
                                     " tidypolis::process_spatial() is ",
                                     spatial_folder),
               )
             }
           },
           "coverage" = {
             if (!sirfunctions_io("exists.dir", NULL, folder, edav = use_edav)) {
               cli::cli_abort(paste0("Coverage data not found.",
                                     "Please create and add coverage data in: ",
                                     folder))
             }
           },
           "pop" = {
             if (!sirfunctions_io("exists.dir", NULL, folder, edav = use_edav)) {
               cli::cli_abort(paste0("Population data not found. ",
                                     "Preprocessing of population files may be required. ",
                                     "Please create a pop data folder and add data in: ",
                                     folder))
             }
           }
    )
  }

  if (use_edav) {
    cli::cli_h1("Testing download times")
    download_metrics <- test_EDAV_connection(return_list = T)
  }

  # use the truncated AFP file
  afp.trunc <- T

  if (recreate.static.files) {
    afp.trunc <- F
  }

  dl_table <- dplyr::bind_rows(
    sirfunctions_io("list", NULL, polis_data_folder, edav = use_edav),
    sirfunctions_io("list", NULL, spatial_folder, edav = use_edav),
    sirfunctions_io("list", NULL, coverage_folder, edav = use_edav),
    sirfunctions_io("list", NULL, pop_folder, edav = use_edav),
    sirfunctions_io("list", NULL, polis_folder, edav = use_edav) |>
      dplyr::filter(grepl("cache", name))
  ) |>
    dplyr::filter(!is.na(size)) |>
    dplyr::select("file" = "name", "size")

  if (use_edav) {
    dl_table <- dl_table |>
      dplyr::mutate(
        "dl_time_sec" = size / download_metrics$size * download_metrics$d
      )
  }

  if (afp.trunc) {
    dl_table <- dl_table |>
      dplyr::filter(!grepl("afp_linelist_2001", file))
  } else {
    dl_table <- dl_table |>
      dplyr::filter(!grepl("afp_linelist_2019", file))
  }

  file_size <- dl_table$size |> sum()

  if (use_edav) {
    download_time <- dl_table$dl_time_sec |> sum()
  }

  if (use_edav) {
    cli::cli_h1("Downloading POLIS Data")
  } else {
    cli::cli_h1("Loading POLIS Data")
  }

  raw.data <- list()
  spatial.data <- list()

  # Check if spatial data needs to be redownloaded from the analytics folder
  spatial_timestamp_exists <- sirfunctions_io(
    "exists.file",
    NULL,
    file.path(analytic_folder, paste0("spatial_timestamp", output_format)),
    edav = use_edav
  )

  if (spatial_timestamp_exists) {
    # Check if it's recent or needs updating
    edav_spatial_timestamp <- sirfunctions_io(
      "read",
      NULL,
      file.path(analytic_folder, paste0("spatial_timestamp", output_format)),
      edav = use_edav
    ) |>
      dplyr::select(name, lastModifiedEDAV = lastModified)

    edav_spatial_folder_info <- sirfunctions_io(
      "list",
      NULL,
      file.path(spatial_folder),
      edav = use_edav
    ) |>
      dplyr::select(name, lastModified)

    spatial_timestamp_comparison <- dplyr::left_join(edav_spatial_timestamp,
                                                     edav_spatial_folder_info) |>
      dplyr::mutate(updated = ifelse(lastModifiedEDAV == lastModified, TRUE, FALSE)) |>
      dplyr::pull(updated) |> sum(na.rm = TRUE)
  } else {

    spatial_timestamp_comparison <- 0

  }

  if (spatial_timestamp_comparison == 3) {
    cli::cli_alert_success("Spatial data in the analytic folder is up to date. Loading from cache...")
    spatial.data <- sirfunctions_io(
      "read",
      NULL,
      file.path(analytic_folder, spatial_data_name),
      edav = use_edav
    )
  } else {
    if (spatial_timestamp_exists) {
      cli::cli_alert_warning("Spatial data in the analytic folder is outdated. Recreating from the spatial folder")
    } else {
      cli::cli_alert_warning("No spatial timestamp exists. Recreating from the spatial folder")
    }

    cli::cli_process_start("1) Loading country shape files")
    spatial.data$global.ctry <- load_clean_ctry_sp(
      fp = file.path(spatial_folder, global_ctry_sf_name),
      edav = use_edav
    )
    cli::cli_process_done()

    cli::cli_process_start("2) Loading province shape files")
    spatial.data$global.prov <- load_clean_prov_sp(
      fp = file.path(spatial_folder, global_prov_sf_name),
      edav = use_edav
    )
    cli::cli_process_done()

    cli::cli_process_start("3) Loading district shape files")
    spatial.data$global.dist <- load_clean_dist_sp(
      fp = file.path(spatial_folder, global_dist_sf_name),
      edav = use_edav
    )
    cli::cli_process_done()
  }

  cli::cli_process_start("4) Loading AFP line list data (This file is almost 3GB and can take a while)")
  raw.data$afp <-
    sirfunctions_io("read", NULL, file_loc = dplyr::filter(
      dl_table,
      grepl("afp", file)
    ) |>
      dplyr::pull(file), edav = use_edav) |>
    dplyr::filter(surveillancetypename == "AFP") |>
    dplyr::mutate(
      cdc.classification.all2 = dplyr::case_when(
        final.cell.culture.result == "Not received in lab" &
          cdc.classification.all == "PENDING" ~ "LAB PENDING",
        TRUE ~ cdc.classification.all
      ),
      hot.case = ifelse(
        paralysis.asymmetric == "Yes" &
          paralysis.onset.fever == "Yes" &
          paralysis.rapid.progress == "Yes",
        1,
        0
      ),
      hot.case = ifelse(is.na(hot.case), 99, hot.case)
    )

  cli::cli_process_done()

  cli::cli_process_start("Processing AFP data for analysis")

  raw.data$afp.epi <- raw.data$afp |>
    dplyr::mutate(epi.week = lubridate::epiweek(dateonset)) |>
    dplyr::group_by(place.admin.0, epi.week, yronset, cdc.classification.all2) |>
    dplyr::summarize(afp.cases = dplyr::n(),
                     .groups = "drop") |>
    dplyr::mutate(epiweek.year = paste(yronset, epi.week, sep = "-")) |>
    # manual fix of epi week
    dplyr::mutate(epi.week = ifelse(epi.week == 52 &
      yronset == 2022, 1, epi.week))

  # factoring cdc classification to have an order we like in stacked bar chart
  raw.data$afp.epi$cdc.classification.all2 <-
    factor(
      raw.data$afp.epi$cdc.classification.all2,
      levels = c(
        "WILD 1",
        "cVDPV 2",
        "VDPV 2",
        "cVDPV 1",
        "VDPV 1",
        "COMPATIBLE",
        "PENDING",
        "LAB PENDING",
        "NPAFP",
        "NOT-AFP",
        "UNKNOWN",
        "aVDPV 1",
        "aVDPV 3",
        "cVDPV1andcVDPV2",
        "CombinationWild1-cVDPV 2",
        "aVDPV 2",
        "VDPV 3",
        "iVDPV 2",
        "VDPV1andcVDPV2",
        "VAPP",
        "cVDPV 3",
        "iVDPV 3",
        "WILD 3",
        "WILD1andWILD3",
        "iVDPV 1",
        "cVDPV2andcVDPV3"
      ),
      labels = c(
        "WILD 1",
        "cVDPV 2",
        "VDPV 2",
        "cVDPV 1",
        "VDPV 1",
        "COMPATIBLE",
        "PENDING",
        "LAB PENDING",
        "NPAFP",
        "NOT-AFP",
        "UNKNOWN",
        "aVDPV 1",
        "aVDPV 3",
        "cVDPV1andcVDPV2",
        "CombinationWild1-cVDPV 2",
        "aVDPV 2",
        "VDPV 3",
        "iVDPV 2",
        "VDPV1andcVDPV2",
        "VAPP",
        "cVDPV 3",
        "iVDPV 3",
        "WILD 3",
        "WILD1andWILD3",
        "iVDPV 1",
        "cVDPV2andcVDPV3"
      )
    )

  raw.data$para.case <- raw.data$afp |>
    dplyr::filter(
      stringr::str_detect(cdc.classification.all2, "VDPV|WILD|COMPATIBLE")
    ) |>
    dplyr::mutate(yronset = ifelse(is.na(yronset) == T, 2022, yronset)) # this fix was for the manually added MOZ case
  cli::cli_process_done()


  cli::cli_process_start("5) Loading population data")
  raw.data$dist.pop <-
    sirfunctions_io("read", NULL,
      dplyr::filter(dl_table, grepl("dist.pop", file)) |>
        dplyr::pull(file),
      edav = use_edav
    ) |>
    dplyr::ungroup()

  raw.data$prov.pop <-
    sirfunctions_io("read", NULL,
      file_loc = dplyr::filter(dl_table, grepl("prov.pop", file)) |>
        dplyr::pull(file), edav = use_edav
    ) |>
    dplyr::ungroup()

  raw.data$ctry.pop <-
    sirfunctions_io("read", NULL,
      dplyr::filter(dl_table, grepl("ctry.pop", file)) |>
        dplyr::pull(file),
      edav = use_edav
    ) |>
    dplyr::ungroup()
  cli::cli_process_done()


  cli::cli_process_start("6) Loading coverage data")
  raw.data$ctry.coverage <- sirfunctions_io("read", NULL,
                                            file_loc = dplyr::filter(dl_table, grepl("ctry_cov", file)) |>
                                              dplyr::pull(file), edav = use_edav
  )

  raw.data$prov.coverage <- sirfunctions_io("read", NULL,
                                            file_loc = dplyr::filter(dl_table, grepl("prov_cov", file)) |>
                                              dplyr::pull(file), edav = use_edav
  )

  raw.data$dist.coverage <- sirfunctions_io("read", NULL,
                                            file_loc = dplyr::filter(dl_table, grepl("dist_cov", file)) |>
                                              dplyr::pull(file), edav = use_edav
  )

  cli::cli_process_done()

  cli::cli_process_start("7) Loading ES data")

  raw.data$es <-
    sirfunctions_io("read", NULL,
      file_loc = dplyr::filter(dl_table, grepl("/es_2001", file)) |>
        dplyr::pull(file), edav = use_edav
    )
  cli::cli_process_done()

  cli::cli_process_start("8) Loading SIA data")
  raw.data$sia <-
    sirfunctions_io("read", NULL,
      file_loc = dplyr::filter(dl_table, grepl("sia", file)) |>
        dplyr::pull(file), edav = use_edav
    )

  cli::cli_process_done()

  cli::cli_process_start("9) Loading all positives")
  raw.data$pos <-
    sirfunctions_io("read", NULL,
      file_loc = dplyr::filter(dl_table, grepl("/pos", file)) |>
        dplyr::pull(file), edav = use_edav
    )

  cli::cli_process_done()

  cli::cli_process_start("10) Loading other surveillance linelist")
  raw.data$other <-
    sirfunctions_io("read", NULL,
      file_loc = dplyr::filter(dl_table, grepl("/other", file)) |>
        dplyr::pull(file), edav = use_edav
    )

  cli::cli_process_done()

  cli::cli_process_start("11) Loading road network data")
  spatial.data$roads <- sirfunctions_io("read", NULL,
    file_loc = dplyr::filter(dl_table, grepl("roads.rds", file)) |>
      dplyr::pull(file), edav = use_edav
  )
  cli::cli_process_done()

  cli::cli_process_start("12) Loading city spatial data")
  spatial.data$cities <- sirfunctions_io("read", NULL,
    file_loc = dplyr::filter(dl_table, grepl("cities.rds", file)) |>
      dplyr::pull(file), edav = use_edav
  )
  cli::cli_process_done()

  cli::cli_process_start("13) Creating Metadata object")

  polis.cache <- sirfunctions_io("read", NULL,
    file_loc = dplyr::filter(dl_table, grepl("cache.rds", file)) |>
      dplyr::pull(file), edav = use_edav
  ) |>
    dplyr::mutate(last_sync = as.Date(last_sync))

  raw.data$metadata$download_time <- max(polis.cache$last_sync, na.rm = TRUE)

  raw.data$metadata$processed_time <- sirfunctions_io("list", NULL,
    file.path(polis_folder, "data", core_ready_folder),
    edav = use_edav
  ) |>
    dplyr::filter(grepl("positives_2001-01-01", name)) |>
    dplyr::select("ctime" = "lastModified") |>
    dplyr::mutate(ctime = as.Date(ctime)) |>
    dplyr::pull(ctime)

  raw.data$metadata$user <- polis.cache |>
    dplyr::filter(table == "virus") |>
    dplyr::pull(last_user)

  raw.data$metadata$most_recent_pos <- max(raw.data$pos$dateonset, na.rm = TRUE)
  raw.data$metadata$most_recent_pos_loc <- raw.data$pos |>
    dplyr::arrange(dplyr::desc(dateonset)) |>
    dplyr::slice(1) |>
    dplyr::pull(place.admin.0)


  raw.data$metadata$most_recent_afp <- max(raw.data$afp$dateonset, na.rm = TRUE)
  raw.data$metadata$most_recent_afp_loc <- raw.data$afp |>
    dplyr::arrange(dplyr::desc(dateonset)) |>
    dplyr::slice(1) |>
    dplyr::pull(place.admin.0)


  raw.data$metadata$most_recent_env <- max(raw.data$es$collect.date, na.rm = TRUE)
  raw.data$metadata$most_recent_env_loc <- raw.data$es |>
    dplyr::arrange(dplyr::desc(collect.date)) |>
    dplyr::slice(1) |>
    dplyr::pull(ADM0_NAME)


  raw.data$metadata$most_recent_sia <- max(raw.data$sia$sub.activity.start.date)
  raw.data$metadata$most_recent_sia_code <- raw.data$sia |>
    dplyr::arrange(dplyr::desc(sub.activity.start.date)) |>
    dplyr::slice(1) |>
    dplyr::pull(sia.code)
  raw.data$metadata$most_recent_sia_location <- raw.data$sia |>
    dplyr::arrange(dplyr::desc(sub.activity.start.date)) |>
    dplyr::slice(1) |>
    dplyr::pull(place.admin.0)
  raw.data$metadata$most_recent_sia_vax <- raw.data$sia |>
    dplyr::arrange(dplyr::desc(sub.activity.start.date)) |>
    dplyr::slice(1) |>
    dplyr::pull(vaccine.type)

  raw.data$metadata$most_recent_vdpv_class_change_date <- raw.data$pos$vdpvclassificationchangedate |>
    lubridate::as_date() |>
    max(na.rm = T)

  rm(polis.cache)

  cli::cli_process_done()

  cli::cli_process_start("14) Clearing out unused memory")
  gc()
  cli::cli_process_done()
}

if (create.cache) {
  cli::cli_process_start("15) Caching processed data")

  out <- split_concat_raw_data(action = "split", split.years = c(2000, med_year, small_year), raw.data.all = raw.data)

  out_files <- out$split.years |>
    dplyr::mutate(
      file_name = ifelse(grepl(current_year, tag), "recent", stringr::str_replace_all(tag, "-", ".")),
      file_name = paste0("raw.data.", file_name, output_format)
    )

  if (!recreate.static.files) {
    out_files <- out_files |> dplyr::filter(grepl("recent", file_name))
  }

  if (!use_archived_data) {
    for (i in 1:nrow(out_files)) {
      sirfunctions_io("write", NULL,
                      file_loc = file.path(analytic_folder, dplyr::pull(out_files[i, ], file_name)),
                      obj = out[[dplyr::pull(out_files[i, ], tag)]],
                      edav = use_edav
      )}
    }

# set up path for spatial df
  sp_file_path <- file.path(analytic_folder, paste0("spatial.data", output_format))

  sirfunctions_io("write", NULL,
    file_loc = sp_file_path,
    obj = spatial.data, edav = use_edav
  )

  # Create tags only if not using "archived" version
  if (use_edav & !use_archived_data) {
    # Create raw data file tag for future comparisons
    sirfunctions_io("write", NULL,
                    file_loc = file.path(analytic_folder, paste0("raw_data_timestamp", output_format)),
                    obj = Sys.time())

    # Create spatial data file tag for future comparisons
    spatial_files <- sirfunctions_io("list",
                                     NULL,
                                     spatial_folder,
                                     edav = use_edav,
                                     full_names = TRUE)

    edav_spatial_timestamp <- spatial_files |>
      dplyr::filter(stringr::str_detect(name, "global."),
                    stringr::str_ends(name, output_format)) |>
      dplyr::select(name, lastModified)

    sirfunctions_io(
      "write",
      NULL,
      file.path(analytic_folder, paste0("spatial_timestamp", output_format)),
      obj = edav_spatial_timestamp,
      edav = use_edav
    )
  }

  cli::cli_process_done()
}

raw_data_cut_size <- switch(size,
                            "small" = small_year,
                            "medium" = med_year,
                            "large" = 2000)

raw.data <- split_concat_raw_data(action = "split",
                                  split.years = raw_data_cut_size,
                                  raw.data.all = raw.data)[[1]]

cli::cli_process_start("Checking for duplicates in datasets.")
raw.data <- duplicate_check(raw.data)
cli::cli_process_done()

if (attach.spatial.data) {
  raw.data$global.ctry <- spatial.data$global.ctry
  raw.data$global.prov <- spatial.data$global.prov
  raw.data$global.dist <- spatial.data$global.dist
  raw.data$roads <- spatial.data$roads
  raw.data$cities <- spatial.data$cities
}

if (use_archived_data) {
  cli::cli_alert_success(paste0("Successfully recreated global polio data from ",
                                basename(polis_data_folder)))
}

return(raw.data)

}