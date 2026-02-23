#' Correct GUIDs in the AFP linelist based on the population dataset
#'
#' @description
#' The function corrects the GUIDs in the AFP linelist to match the GUID associated
#' with a particular district or province for each year. In certain instances, this is
#' required when the population/spatial data sets are outdated, and new GUIDs are present in the
#' AFP linelist.
#'
#'
#' @param afp_data`tibble` AFP linelist.
#' @param prov_pop `tibble` Province population file.
#' @param dist_pop `tibble` District population file.
#'
#' @returns `tibble` AFP linelist with corrected GUIDs
#' @export
#'
#' @examples
#' \dontrun{
#' raw_data <- get_all_polio_data()
#' afp_fixed <- match_afp_guid_to_sf(raw_data$afp, raw_data$prov.pop, raw_data$dist.pop)
#' }
match_afp_guid_to_sf <- function(afp_data, prov_pop, dist_pop) {

  nrow_original <- afp_data |> nrow()

  # Ensure that column names don't change depending on whether passing the global
  # or country only
  if ("place.admin.0" %in% names(afp_data)) {
    cli::cli_alert_info("Correcting global polio data")
    global_afp <- TRUE
  } else {
    cli::cli_alert_info("Correcting country polio data")
    global_afp <- FALSE
  }

  afp_data <- dplyr::rename_with(afp_data, recode,
                                 place.admin.0 = "ctry",
                                 place.admin.1 = "prov",
                                 place.admin.2 = "dist",
                                 dateonset = "date",
                                 yronset = "year")
  prov_pop <- dplyr::rename_with(prov_pop, recode,
                                 ADM0_NAME = "ctry",
                                 ADM1_NAME = "prov",
                                 ADM0_GUID = "adm0guid")

  dist_pop <- dplyr::rename_with(dist_pop, recode,
                                 ADM0_NAME = "ctry",
                                 ADM1_NAME = "prov",
                                 ADM2_NAME = "dist",
                                 ADM0_GUID = "adm0guid")

  prov_lookup <- prov_pop |>
    dplyr::select(year, ctry, prov, adm0guid, adm1guid_pop = adm1guid)
  # Forward to current year if missing
  if (!lubridate::year(Sys.Date()) %in% unique(prov_lookup$year)) {
    curr_year <- prov_lookup |>
      filter(year == max(year, na.rm = T)) |>
      mutate(year = lubridate::year(Sys.Date()))

    prov_lookup <- dplyr::bind_rows(prov_lookup, curr_year)
  }
  dist_lookup <- dist_pop |>
    dplyr::select(year, ctry, prov, dist, adm0guid, adm1guid, adm2guid_pop = adm2guid)

  if (!lubridate::year(Sys.Date()) %in% unique(dist_lookup$year)) {
    curr_year <- dist_lookup |>
      filter(year == max(year, na.rm = T)) |>
      mutate(year = lubridate::year(Sys.Date()))

    dist_lookup <- dplyr::bind_rows(dist_lookup, curr_year)
  }

  # Manually fix NAROK WEST and BURURI
  dist_lookup <- dist_lookup |>
    filter(!(dist == "BURURI" & adm2guid_pop == "{4A72EFCA-4E8C-4439-98B9-84BA7ECBDB7F}" & year >= 2023)) |>
    filter(!(dist == "BURURI" & adm2guid_pop == "{44AB3985-6B4A-4A97-A3B7-82E03420F9C3}" & year == 2020)) |>
    filter(!(dist == "NAROK WEST" & adm2guid_pop == "{723D75B4-76BD-4C66-9786-474AD09C72A7}" & year >= 2024))

  # Overwrite to reflect what's on the pop files
  afp_data_fixed <- afp_data |>
    dplyr::left_join(prov_lookup) |>
    dplyr::mutate(fixed_prov = adm1guid != adm1guid_pop,
                  adm1guid = adm1guid_pop)

  afp_data_fixed <- afp_data_fixed |>
    dplyr::left_join(dist_lookup) |>
    dplyr::mutate(fixed_dist = adm2guid != adm2guid_pop,
                  adm2guid = adm2guid_pop) |>
    dplyr::select(-adm2guid_pop)

  # Info on fixes
  cli::cli_alert_info(paste0(sum(afp_data_fixed$fixed_prov, na.rm = T), " provinces fixed"))
  cli::cli_alert_info(paste0(sum(afp_data_fixed$fixed_dist, na.rm = T), " districts fixed"))

  # Rename column names to original if cleaning global polio data
  if (global_afp) {
    afp_data_fixed <- afp_data_fixed |>
      dplyr::rename(place.admin.0 = ctry,
                    place.admin.1 = prov,
                    place.admin.2 = dist,
                    dateonset = date,
                    yronset = year)
  }

  # Double check that no additional records added or deleted from cleaning
  if (nrow_original != nrow(afp_data_fixed)) {
    cli::cli_alert_danger("The number of rows in the cleaned data is not the same as the original")
  } else {
    cli::cli_alert_success("No records added/lost from the original linelist after cleaning")
  }

  return(afp_data_fixed)

}
