# Helper functions

#' Checks for required subfolders in the data folder
#'
#' @param data_folder `str` Path to the data folder.
#' @param polis_folder `str` POLIS folder with preprocessed data.
#' @param core_ready_folder `str` Name of the core ready folder. Need to be specified if preprocessing specific regions, which have their own core ready folder.
#' @param use_edav `logical` Whether to use EDAV or not.
#' @param cache `logical` Whether to cache the preprocessed data to data/polis subfolder.
#'
#' @returns `list` List of paths to the specific subfolders.
#'
#' @keywords internal
check_data_folder <- function(data_folder, polis_folder, core_ready_folder, use_edav, cache) {

  analytic_folder <- file.path(data_folder, "analytic")
  polis_data_folder <- file.path(data_folder, "polis")
  spatial_folder <- file.path(data_folder, "spatial")
  coverage_folder <- file.path(data_folder, "coverage")
  pop_folder <- file.path(data_folder, "pop")

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
              cache,
              Inf
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

  return(list(analytic_folder = analytic_folder, 
              polis_data_folder = polis_data_folder, 
              spatial_folder = spatial_folder,
              coverage_folder = coverage_folder, 
              pop_folder = pop_folder))

}

#' Creates the "download table", with paths to files required for recreating static files
#'
#' @param data_folders_paths `list` Output of [check_data_folder()].
#' @param polis_folder `str` POLIS folder containing preprocessed data. NOT the subfolder under the data folder.
#' @param use_edav `logical` Whether to use EDAV or not.
#'
#' @returns `tibble` Dataset containing paths to required files.
#'
#' @keywords internal
list_required_files_for_processing <- function(data_folders_paths, polis_folder, use_edav) {
  dl_table <- dplyr::bind_rows(
    sirfunctions_io(
      "list",
      NULL,
      data_folders_paths$polis_data_folder,
      edav = use_edav
    ),
    sirfunctions_io(
      "list",
      NULL,
      data_folders_paths$spatial_folder,
      edav = use_edav
    ),
    sirfunctions_io(
      "list",
      NULL,
      data_folders_paths$coverage_folder,
      edav = use_edav
    ),
    sirfunctions_io(
      "list",
      NULL,
      data_folders_paths$pop_folder,
      edav = use_edav
    ),
    sirfunctions_io(
      "list",
      NULL,
      polis_folder,
      edav = use_edav
    ) |>
      dplyr::filter(grepl("cache", name))
  ) |>
    dplyr::filter(!is.na(size), !grepl("afp_linelist_2019", name)) |>
    dplyr::select("file" = "name", "size")

  return(dl_table)
}

#' Create the spatial data for processing
#'
#' @param data_folder `str` Path to the data folder.
#' @param use_edav `logical` Use EDAV or not.
#'
#' @returns `list` Contains spatial datasets.
#'
#' @keywords internal
check_spatial_data_for_processing <- function(data_folder, use_edav) {
  spatial_folder <- file.path(data_folder, "spatial")
  analytic_folder <- file.path(data_folder, "analytic")
  global_ctry_sf_name <- "global.ctry.rds"
  global_prov_sf_name <- "global.prov.rds"
  global_dist_sf_name <- "global.dist.rds"
  spatial_data <- list()

  # Check if spatial data needs to be redownloaded from the analytics folder
  spatial_timestamp_exists <- sirfunctions_io(
    "exists.file",
    NULL,
    file.path(analytic_folder, "spatial_timestamp.parquet"),
    edav = use_edav
  )

  if (spatial_timestamp_exists) {
    # Check if it's recent or needs updating
    edav_spatial_timestamp <- sirfunctions_io(
      "read",
      NULL,
      file.path(analytic_folder, "spatial_timestamp.parquet"),
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

    spatial_timestamp_comparison <- dplyr::left_join(
      edav_spatial_timestamp,
      edav_spatial_folder_info
    ) |>
      dplyr::mutate(
        updated = ifelse(lastModifiedEDAV == lastModified, TRUE, FALSE)
      ) |>
      dplyr::pull(updated) |>
      sum(na.rm = TRUE)
  } else {
    spatial_timestamp_comparison <- 0
  }

  if (spatial_timestamp_comparison == 3) {
    cli::cli_alert_success(
      "Spatial data in the analytic folder is up to date. Loading from cache..."
    )
    spatial_data <- build_parquet_raw_data(
      file.path(data_folder, "analytic"),
      dataset = c("global.ctry", "global.prov", "global.dist"),
      from_edav = use_edav
    )
  } else {
    if (spatial_timestamp_exists) {
      cli::cli_alert_warning(
        "Spatial data in the analytic folder is outdated. Recreating from the spatial folder"
      )
    } else {
      cli::cli_alert_warning(
        "No spatial timestamp exists. Recreating from the spatial folder"
      )
    }

    cli::cli_process_start("1) Loading country shape files")
    spatial_data$global.ctry <- load_clean_ctry_sp(
      fp = file.path(spatial_folder, global_ctry_sf_name),
      edav = use_edav
    )
    cli::cli_process_done()

    cli::cli_process_start("2) Loading province shape files")
    spatial_data$global.prov <- load_clean_prov_sp(
      fp = file.path(spatial_folder, global_prov_sf_name),
      edav = use_edav
    )
    cli::cli_process_done()

    cli::cli_process_start("3) Loading district shape files")
    spatial_data$global.dist <- load_clean_dist_sp(
      fp = file.path(spatial_folder, global_dist_sf_name),
      edav = use_edav
    )
    cli::cli_process_done()
  }

  return(spatial_data)

}

#' Creates the AFP dataset of raw_data
#'
#' @param dl_table `tibble` Output of [list_required_files_for_processing()].
#' @param use_edav `logical` Whether to use EDAV or not.
#'
#' @returns `tibble` AFP dataset.
#'
#' @keywords internal
process_afp_raw_data <- function(dl_table, use_edav) {

  afp <- sirfunctions_io("read", NULL, file_loc = dplyr::filter(
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
  
  return(afp)

}

#' Creates afp.epi dataset
#'
#' @param afp `tibble` Output of [process_afp_raw_data()].
#'
#' @returns `tibble` Summary of AFP cases by year/epi-week per country.
#'
#' @keywords internal
process_afp_epi_raw_data <- function(afp) {

  afp.epi <- afp |>
    dplyr::mutate(epi.week = lubridate::epiweek(dateonset)) |>
    dplyr::group_by(place.admin.0, epi.week, yronset, cdc.classification.all2) |>
    dplyr::summarize(afp.cases = dplyr::n(),
                     .groups = "drop") |>
    dplyr::mutate(epiweek.year = paste(yronset, epi.week, sep = "-")) |>
    # manual fix of epi week
    dplyr::mutate(epi.week = ifelse(epi.week == 52 &
      yronset == 2022, 1, epi.week))

  # factoring cdc classification to have an order we like in stacked bar chart
  afp.epi$cdc.classification.all2 <-
    factor(
      afp.epi$cdc.classification.all2,
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
  
  return(afp.epi)
}

#' Creates paralytics cases dataset
#'
#' @inheritParams process_afp_epi_raw_data
#'
#' @returns `tibble` Dataset with paralytic cases only.
#'
#' @keywords internal
process_paralytic_raw_data <- function(afp) {
  para.case <- afp |>
    dplyr::filter(
      stringr::str_detect(cdc.classification.all2, "VDPV|WILD|COMPATIBLE")
    ) |>
    dplyr::mutate(yronset = ifelse(is.na(yronset) == T, 2022, yronset)) # this fix was for the manually added MOZ case

  return(para.case)
}

#' Pull data listed in the download table
#'
#' @param dl_table `tibble` Output of [list_required_files_for_processing()].
#' @param grepl_pattern `str` Pattern to use to filter the `dl_table`.
#' @param use_edav `logical` Whether to use EDAV or not.
#'
#' @returns `tibble` One of the datasets listed in `dl_table`.
#'
#' @keywords internal
pull_data_from_dl_table <- function(dl_table, grepl_pattern, use_edav) {
  pulled_data <- sirfunctions_io(
    "read",
    NULL,
    file_loc = dplyr::filter(dl_table, grepl(grepl_pattern, file)) |>
      dplyr::pull(file),
    edav = use_edav
  ) |>
    dplyr::ungroup()

  return(pulled_data)

}

#' Creates metadata tag
#'
#' @param dl_table `tibble` Output of [list_required_files_for_processing()].
#' @param raw_data `list` Processed data combining all polio data.
#' @param polis_folder `str` Path to POLIS folder.
#' @param core_ready_folder `str` Name of the core ready folder.
#' @param use_edav `logical` Whether to use EDAV or not.
#'
#' @returns `tibble` Metadata tibble.
#'
#' @keywords internal
process_metadata_raw_data <- function(dl_table, raw_data, polis_folder, core_ready_folder, use_edav) {
  metadata <- list()
  polis.cache <- sirfunctions_io("read", NULL,
    file_loc = dplyr::filter(dl_table, grepl("cache.rds", file)) |>
      dplyr::pull(file), edav = use_edav
  ) |>
    dplyr::mutate(last_sync = as.Date(last_sync))

  metadata$download_time <- max(polis.cache$last_sync, na.rm = TRUE)

  metadata$processed_time <- sirfunctions_io("list", NULL,
    file.path(polis_folder, "data", core_ready_folder),
    edav = use_edav
  ) |>
    dplyr::filter(grepl("positives_2001-01-01", name)) |>
    dplyr::select("ctime" = "lastModified") |>
    dplyr::mutate(ctime = as.Date(ctime)) |>
    dplyr::pull(ctime)

  metadata$user <- polis.cache |>
    dplyr::filter(table == "virus") |>
    dplyr::pull(last_user)

  metadata$most_recent_pos <- max(raw_data$pos$dateonset, na.rm = TRUE)
  metadata$most_recent_pos_loc <- raw_data$pos |>
    dplyr::arrange(dplyr::desc(dateonset)) |>
    dplyr::slice(1) |>
    dplyr::pull(place.admin.0)


  metadata$most_recent_afp <- max(raw_data$afp$dateonset, na.rm = TRUE)
  metadata$most_recent_afp_loc <- raw_data$afp |>
    dplyr::arrange(dplyr::desc(dateonset)) |>
    dplyr::slice(1) |>
    dplyr::pull(place.admin.0)


  metadata$most_recent_env <- max(raw_data$es$collect.date, na.rm = TRUE)
  metadata$most_recent_env_loc <- raw_data$es |>
    dplyr::arrange(dplyr::desc(collect.date)) |>
    dplyr::slice(1) |>
    dplyr::pull(ADM0_NAME)


  metadata$most_recent_sia <- max(raw_data$sia$sub.activity.start.date)
  metadata$most_recent_sia_code <- raw_data$sia |>
    dplyr::arrange(dplyr::desc(sub.activity.start.date)) |>
    dplyr::slice(1) |>
    dplyr::pull(sia.code)
  metadata$most_recent_sia_location <- raw_data$sia |>
    dplyr::arrange(dplyr::desc(sub.activity.start.date)) |>
    dplyr::slice(1) |>
    dplyr::pull(place.admin.0)
  metadata$most_recent_sia_vax <- raw_data$sia |>
    dplyr::arrange(dplyr::desc(sub.activity.start.date)) |>
    dplyr::slice(1) |>
    dplyr::pull(vaccine.type)

  metadata$most_recent_vdpv_class_change_date <- raw_data$pos$vdpvclassificationchangedate |>
    lubridate::as_date() |>
    max(na.rm = T)

  return(metadata)

}

#' Cache the raw data
#'
#' @param raw_data `list` Processed list of all polio data.
#' @param analytic_folder_path `str` Path to analytic folder.
#' @param use_edav `logical` Whether to use EDAV or not.
#'
#' @returns `NULL`, invisibly.
#'
#' @keywords internal
cache_raw_data <- function(raw_data, analytic_folder_path, use_edav) {

    if (use_edav) {
      withr::with_tempdir({
      
      create_raw_data_parquet(raw_data, getwd())
      upload_parquet_to_edav(getwd(), analytic_folder_path, get_azure_storage_connection())
      
      })
    } else {
      create_raw_data_parquet(raw_data, analytic_folder_path)
    }

  invisible()
}

#' Create timestamps for raw data and spatial data
#'
#' @param data_folders_paths `list` Output of [check_data_folder()].
#' @param use_edav `logical` Whether to use EDAV or not.
#'
#' @returns `NULL`, invisibly.
#'
#' @keywords internal
create_raw_data_tags <- function(data_folders_paths, use_edav) {

  # Create tags only if not using "archived" version
  if (use_edav) {
    # Create raw data file tag for future comparisons
    sirfunctions_io("write", NULL,
                    file_loc = file.path(data_folders_paths$analytic_folder, paste0("raw_data_timestamp.rds")),
                    obj = Sys.time())

    # Create spatial data file tag for future comparisons
    spatial_files <- sirfunctions_io("list",
                                     NULL,
                                     data_folders_paths$spatial_folder,
                                     edav = use_edav,
                                     full_names = TRUE)

    edav_spatial_timestamp <- spatial_files |>
      dplyr::filter(stringr::str_detect(name, "global."),
                    stringr::str_ends(name, "parquet")) |>
      dplyr::select(name, lastModified)

    sirfunctions_io(
      "write",
      NULL,
      file.path(data_folder_paths$analytic_folder, paste0("spatial_timestamp.rds")),
      obj = edav_spatial_timestamp,
      edav = use_edav
    )
  }

}

#' Reprocess the global polio dataset
#'
#' @param data_folder `str` Path to the data folder.
#' @param polis_folder `str` Path to the POLIS folder.
#' @param core_ready_folder `str` Name of the core ready folder.
#' @param use_edav `logical` Whether to use EDAV or not.
#' @param cache `logical` Whether to cache the preprocessed data to the data/polis subfolder.
#'
#' @returns `list` Processed raw data.
#'
#' @keywords internal
reprocess_polio_data <- function(data_folder, polis_folder, core_ready_folder, use_edav, cache) {

  raw_data <- list()
  # NOTE: we will need to add mechanism for retrieving and loading archived parquet folders
  data_folders_paths <- check_data_folder(data_folder, polis_folder, core_ready_folder, use_edav, cache)

  # List files required for processing
  dl_table <- list_required_files_for_processing(data_folders_paths, polis_folder, use_edav)

  # Obtain spatial data information
  spatial_data <- check_spatial_data_for_processing(data_folder, use_edav)

  # Process raw.data
  raw_data$afp <- process_afp_raw_data(dl_table, use_edav)
  raw_data$afp.epi <- process_afp_epi_raw_data(raw_data$afp)
  raw_data$para.case <- process_paralytic_raw_data(raw_data$afp)
  raw_data$ctry.pop <- pull_data_from_dl_table(dl_table, "ctry.pop", use_edav)
  raw_data$prov.pop <- pull_data_from_dl_table(dl_table, "prov.pop", use_edav)
  raw_data$dist.pop <- pull_data_from_dl_table(dl_table, "dist.pop", use_edav)
  raw_data$ctry.coverage <- pull_data_from_dl_table(dl_table, "ctry_cov", use_edav)
  raw_data$prov.coverage <- pull_data_from_dl_table(dl_table, "prov_cov", use_edav)
  raw_data$dist.coverage <- pull_data_from_dl_table(dl_table, "dist_cov", use_edav)
  raw_data$es <- pull_data_from_dl_table(dl_table, "/es_2001", use_edav)
  raw_data$sia <- pull_data_from_dl_table(dl_table, "sia", use_edav)
  raw_data$pos <- pull_data_from_dl_table(dl_table, "/pos", use_edav)
  raw_data$other <- pull_data_from_dl_table(dl_table, "/other", use_edav)

  # Add spatial data to raw_data
  raw_data$global.ctry <- spatial_data$global.ctry
  raw_data$global.prov <- spatial_data$global.prov
  raw_data$global.dist <- spatial_data$global.dist
  raw_data$roads <- pull_data_from_dl_table(dl_table, "roads.rds", use_edav)
  raw_data$cities <- pull_data_from_dl_table(dl_table, "cities.rds", use_edav)

  # Create metadata
  raw_data$metadata <- process_metadata_raw_data(dl_table, raw_data, polis_folder, core_ready_folder, use_edav)

  # Check for duplicates
  raw_data <- duplicate_check(raw_data)

  # Cache processed data only if we aren't using the archived version
  cache_raw_data(raw_data,data_folders_paths$analytic_folder, use_edav)

  # Create data tags only if we aren't using the archived version
  create_raw_data_tags(data_folders_paths, use_edav)

  return(raw_data)

}

# Main function

#' Pull global polio dataset
#'
#' @param dataset `str` Name of the dataset. Defaults to 'all'.
#' @param data_folder `str` Path to data folder.
#' @param polis_folder `str` Path to the POLIS folder.
#' @param core_ready_folder `str` Name of the core ready folder.
#' @param recreate.static.files `logical` Whether to reprocess global polio data.
#' @param use_edav `logical` Whether to use EDAV or not.
#' @param azcontainer `azcontainer` Azure container object.
#' @param cache `logical` Whether to cache the preprocessed datasets in the `data/polis` folder.
#'
#' @returns `list` Global polio datasets.
#'
#' @export
#' @examples
#' \dontrun{
#' raw_data <- get_all_polio_data_2()
#' }
get_all_polio_data_2 <- function(dataset = "all",
    data_folder = "GID/PEB/SIR/Data",
    polis_folder = "GID/PEB/SIR/POLIS",
    core_ready_folder = "Core_Ready_Files",
    recreate.static.files = FALSE,
    use_edav = TRUE,
    azcontainer = get_azure_storage_connection(),
  cache = TRUE) {
  
  if (recreate.static.files) {
    raw_data <- reprocess_polio_data(data_folder, polis_folder, core_ready_folder, use_edav, cache)
  } else {
    raw_data <- build_parquet_raw_data(file.path(data_folder, "analytic"), dataset, use_edav, azcontainer)
  }

  return(raw_data)

}

