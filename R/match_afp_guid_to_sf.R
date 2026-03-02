#' Correct GUIDs in the AFP linelist based on the population dataset
#'
#' @description
#' The function corrects the GUIDs in the AFP linelist to match the GUID associated
#' with a particular district or province for each year. In certain instances, this is
#' required when the population/spatial data sets are outdated, and new GUIDs are present in the
#' AFP linelist.
#'
#' @param afp_data `tibble` AFP linelist.
#' @param prov_sf_long `tibble` Province shape file in long format (shapes for each year).
#' @param dist_sf_long `tibble` District shape file in long format (shapes for each year).
#'
#' @returns `tibble` AFP linelist with corrected GUIDs
#' @export
#'
#' @examples
#' \dontrun{
#' raw_data <- get_all_polio_data()
#' afp_fixed <- match_afp_guid_to_sf(raw_data$afp, raw_data$prov.pop, raw_data$dist.pop)
#' }
match_afp_guid_to_sf <- function(afp_data, prov_sf_long, dist_sf_long) {

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

  prov_lookup_sf <- prov_sf_long |>
    dplyr::tibble() |>
    dplyr::select(year = active.year.01,
                  ctry = ADM0_NAME,
                  prov = ADM1_NAME,
                  adm0guid = ADM0_GUID,
                  adm1guid_sf = GUID)

  # Forward to current year if missing
  if (!lubridate::year(Sys.Date()) %in% unique(prov_lookup_sf$year)) {
    curr_year_sf <- prov_lookup_sf |>
      filter(year == max(year, na.rm = T)) |>
      mutate(year = lubridate::year(Sys.Date()))
    prov_lookup_sf <- dplyr::bind_rows(prov_lookup_sf, curr_year_sf)
  }

  dist_lookup_sf <- dist_sf_long |>
    dplyr::tibble() |>
    dplyr::select(year = active.year.01,
                  ctry = ADM0_NAME,
                  prov = ADM1_NAME,
                  dist = ADM2_NAME,
                  adm0guid = ADM0_GUID,
                  adm1guid = ADM1_GUID,
                  adm2guid_sf = GUID)

  if (!lubridate::year(Sys.Date()) %in% unique(dist_lookup_sf$year)) {
    curr_year_sf <- dist_lookup_sf |>
      filter(year == max(year, na.rm = T)) |>
      mutate(year = lubridate::year(Sys.Date()))

    dist_lookup_sf <- dplyr::bind_rows(dist_lookup_sf, curr_year_sf)
  }

  # Manually fix NAROK WEST and BURURI
  dist_lookup_sf <- dist_lookup_sf |>
    filter(!(dist == "BURURI" & adm2guid_sf == "{4A72EFCA-4E8C-4439-98B9-84BA7ECBDB7F}" & year >= 2023)) |>
    filter(!(dist == "BURURI" & adm2guid_sf == "{44AB3985-6B4A-4A97-A3B7-82E03420F9C3}" & year == 2020)) |>
    filter(!(dist == "NAROK WEST" & adm2guid_sf == "{723D75B4-76BD-4C66-9786-474AD09C72A7}" & year >= 2024))

  # Overwrite to reflect what's on the shapefiles
  afp_data_fixed <- afp_data |>
    dplyr::left_join(prov_lookup_sf) |>
    dplyr::mutate(fixed_prov_sf = adm1guid != adm1guid_sf,
                  adm1guid = adm1guid_sf) |>
    dplyr::select(-adm1guid_sf)

  afp_data_fixed <- afp_data_fixed |>
    dplyr::left_join(dist_lookup_sf) |>
    dplyr::mutate(fixed_dist_sf = adm2guid != adm2guid_sf,
                  adm2guid = adm2guid_sf) |>
    dplyr::select(-adm2guid_sf)

  # Info on fixes
  cli::cli_alert_info(paste0(sum(afp_data_fixed$fixed_prov_sf, na.rm = T), " provinces fixed"))
  cli::cli_alert_info(paste0(sum(afp_data_fixed$fixed_dist_sf, na.rm = T), " districts fixed"))

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
