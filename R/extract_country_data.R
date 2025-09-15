
#' Extract country specific information from raw polio data
#'
#' @description Filters country specific data from the CDC generated `raw.data` object from [get_all_polio_data()].
#'
#' @param .raw.data `list` Output of [get_all_polio_data()].
#' @param .country `str` A string or a vector of strings containing country name(s) of interest. Case insensitive.
#' @returns Named `list` with country specific datasets.
#' @examples
#' \dontrun{
#' raw.data <- get_all_polio_data(attach.spatial.data = FALSE)
#' ctry.data <- extract_country_data(c("nigeria", "eritrea"), raw.data)
#' }
#'
#' @export
extract_country_data <- function(.country, .raw.data = raw.data) {

  # Format .country
  .country <- stringr::str_to_upper(stringr::str_trim(.country))
  # Check to make sure that all country passed in .country exists
  ctry_check <- setdiff(.country, .raw.data$ctry.pop$ADM0_NAME)

  if (length(ctry_check) > 0) {
    cli::cli_alert_warning("The following countries do not exist in global polio dataset: ")
    cli::cli_li(ctry_check)
    cli::cli_abort("Please pass only valid country names and try again.")
  }

  results <- purrr::map(.country,
                        \(c) {
                          ctry_data <- extract_country_data_single(c, .raw.data)
                          ctry_data_tibble <- dplyr::tibble(names = names(ctry_data),
                                                            values = NA) |>
                            tidyr::pivot_wider(names_from = names, values_from = values)
                          for (i in names(ctry_data)) {
                            ctry_data_tibble[[i]] = list(ctry_data[[i]])
                          }

                          return(ctry_data_tibble)
                          })

  # Make the lists into tibbles
  results_binded <- dplyr::bind_rows(results)

  # Drop the names and metadata
  results_binded <- results_binded |>
    dplyr::select(-c("vis.name", "name", "ctry.code", "metadata"))

  # Combine each dataframes/lists into one
  results_binded_02 <-  results_binded |>
    dplyr::summarize(dplyr::across(dplyr::everything(),
                                   \(x) list(dplyr::bind_rows(x))))

  # Create a big list
  data_list <- list()
  for (i in names(results_binded_02)) {
    data_list[i] = results_binded_02[[i]]
  }

  # Add metadata
  data_list["metadata"] <- .raw.data$metadata

  # Add vis.name, name, and ctry.code (depends if global ctry sf is present)
  if (!is.null(.raw.data$global.ctry)) {
    data_list["name"] <- data_list$ctry.pop$ctry |>
      unique() |>
      list()
    data_list["vis.name"] <- data_list$ctry.pop$ctry |>
      unique() |>
      stringr::str_to_title() |> list()
    data_list["ctry.code"] <- data_list$ctry$WHO_CODE |>
      unique() |>
      list()
  }

  return(data_list)
}



#' Extract country specific information from raw polio data
#'
#' @description Filters country specific data from the CDC generated `raw.data` object from [get_all_polio_data()].
#'
#' @inheritParams extract_country_data
#' @returns Named `list` with country specific datasets.
#' @keywords internal
extract_country_data_single <- function(
    .country,
    .raw.data = raw.data) {
  .country <- stringr::str_to_upper(stringr::str_trim(.country))
  if (!(.country %in% unique(.raw.data$ctry.pop$ADM0_NAME))) {
    stop("Invalid country name. Please try again.")
  }

  cli::cli_h1(paste0("--Processing country data for: ", stringr::str_to_title(.country), "--"))
  # Error checking for overlapping ADM0 Names
  ctry.matches <- .raw.data$ctry.pop |>
    dplyr::filter(stringr::str_detect(ADM0_NAME, .country))
  ctrys <- sort(unique(ctry.matches$ADM0_NAME)) |>
    stringr::str_to_title()
  if (length(ctrys) > 1) {
    message("Multiple countries match that name")

    response <- T
    attempts <- 5
    chosen.country <- 0
    while (response) {
      if (attempts == 0) {
        response <- F
        message("Exiting...")
        return()
      } else {
        ctry.options <- paste0(paste0("\n", paste0(1:length(ctrys), ") "), ctrys), collapse = "")
        message("Please choose one by designating a number or type 'q' to quit: ")
        message(ctry.options)

        chosen.country <- readline("Enter only the number to designate a country: \n")
      }

      if (chosen.country == "q") {
        response <- F
        message("Exiting...")
        return()
      }

      chosen.country <- suppressWarnings(as.integer(stringr::str_trim(chosen.country)))
      if (is.na(chosen.country) | !(chosen.country %in% 1:length(ctrys))) {
        message("Invalid choice, please try again.")
        attempts <- attempts - 1
        if (attempts == 1) {
          message(attempts, " attempt remaining\n")
        } else {
          message(attempts, " attempts remaining\n")
        }
        next
      } else {
        chosen.country <- ctrys[chosen.country]
        response <- F
      }
    }
  } else {
    chosen.country <- ctrys[1]
  }

  .country <- chosen.country |> stringr::str_to_upper()
  ctry.data <- list()
  steps <- 1

  if (!is.null(.raw.data$global.ctry)) {
    cli::cli_process_start(paste0(steps, ") Subsetting country spatial data\n"))
    ctry.data$ctry <- .raw.data$global.ctry |>
      dplyr::filter(stringr::str_detect(ADM0_NAME, .country))
    ctry.data$ctry <- dplyr::filter(
      ctry.data$ctry,
      stringr::str_to_upper(ADM0_SOVRN) == stringr::str_to_upper(chosen.country)
    )
    .country <- unique(ctry.data$ctry$ADM0_NAME)

    ctry.data$prov <- .raw.data$global.prov |>
      dplyr::filter(ADM0_NAME == .country)

    ctry.data$dist <- .raw.data$global.dist |>
      dplyr::filter(ADM0_NAME == .country)

    ctry.data$name <- ctry.data$ctry$ADM0_NAME
    ctry.data$vis.name <- ctry.data$ctry$ADM0_VIZ_NAME
    ctry.data$ctry.code <- ctry.data$ctry$WHO_CODE

    cli::cli_process_done()

    steps <- steps + 1
    cli::cli_process_start(paste0(steps, ") Extracting bordering geometries for reference"))

    error1 <- F
    tryCatch(
      {
        a <- sf::st_touches(ctry.data$ctry, .raw.data$global.dist, sparse = F)
        ctry.data$proximal.dist <- .raw.data$global.dist[a, ]
      },
      error = function(cond) {
        message("There was an error in extracting district borders.")
        error1 <<- T
      }
    )

    if (error1) {
      tryCatch(
        {
          message("Attempting fix by toggling sf::sf_use_s2(F).")
          sf::sf_use_s2(F)
          a <- sf::st_touches(ctry.data$ctry, .raw.data$global.dist, sparse = F)
          ctry.data$proximal.dist <- .raw.data$global.dist[a, ]
          sf::sf_use_s2(T)
        },
        error = function(cond) {
          message("Unable to fix spatial file errors for district borders.")
        }
      )
    }

    error2 <- F
    tryCatch(
      {
        a <- sf::st_touches(ctry.data$ctry, .raw.data$global.ctry, sparse = F)
        ctry.data$proximal.ctry <- .raw.data$global.ctry[a, ]
      },
      error = function(cond) {
        message("There was an error in extracting country borders.")
        error2 <<- T
      }
    )

    if (error2) {
      tryCatch(
        {
          message("Attempting fix by toggling sf::sf_use_s2(F).")
          sf::sf_use_s2(F)
          a <- sf::st_touches(ctry.data$ctry, .raw.data$global.ctry, sparse = F)
          ctry.data$proximal.ctry <- .raw.data$global.ctry[a, ]
          sf::sf_use_s2(T)
        },
        error = function(cond) {
          message("Unable to fix spatial file errors for district borders.")
        }
      )
    }

    cli::cli_process_done()
    steps <- steps + 1
    cli::cli_process_start(paste0(steps, ") Pulling data from OSM for Roads"))

    error3 <- F
    tryCatch(
      {
        ctry.data$roads <- .raw.data$roads |>
          sf::st_intersection(ctry.data$ctry)
      },
      error = function(cond) {
        message("Unable to pull data for Roads. Toggling sf::sf_use_s2(F).")
        error3 <<- T
      }
    )

    error4 <- F
    if (error3) {
      tryCatch(
        {
          sf::sf_use_s2(F)
          ctry.data$roads <- .raw.data$roads |>
            sf::st_intersection(ctry.data$ctry)
          sf::sf_use_s2(T)
        },
        error = function(cond) {
          message(paste0(
            "sf_use_s2(F) failed. Using st_make_valid() on ctry.data$ctry.\n",
            " This fix in some cases can cause inaccurate road maps.\n",
            " If so, it is recommended to fix the spatial files."
          ))
          error4 <<- T
        }
      )
    }

    if (error4) {
      tryCatch(
        {
          sf::sf_use_s2(F)
          ctry.data$roads <- raw.data$roads |>
            sf::st_intersection(sf::st_make_valid(ctry.data$ctry))
          sf::sf_use_s2(T)
        },
        error = function(cond) {
          message("Unable to fix spatial file errors in road maps.")
        }
      )
    }

    cli::cli_process_done()
    steps <- steps + 1
    cli::cli_process_start(paste0(steps, ") Pulling data from OSM for Cities"))

    error5 <- F
    tryCatch(
      {
        ctry.data$cities <- .raw.data$cities |>
          sf::st_intersection(ctry.data$ctry)
      },
      error = function(cond) {
        message("Unable to pull data for Cities. Toggling sf::sf_use_s2(F).")
        error5 <<- T
      }
    )

    error6 <- F
    if (error5) {
      tryCatch(
        {
          sf::sf_use_s2(F)
          ctry.data$cities <- .raw.data$cities |>
            sf::st_intersection(ctry.data$ctry)
          sf::sf_use_s2(T)
        },
        error = function(cond) {
          message(paste0(
            "sf_use_s2(F) failed. Using st_make_valid() on the ctry.data$ctry.\n",
            " This fix in some cases can cause inaccurate city maps.\n",
            " If so, it is recommended to fix the spatial files."
          ))
          error6 <<- T
        }
      )
    }

    if (error6) {
      tryCatch(
        {
          sf::sf_use_s2(F)
          ctry.data$cities <- raw.data$cities |>
            sf::st_intersection(sf::st_make_valid(ctry.data$ctry))
          sf::sf_use_s2(T)
        },
        error = function(cond) {
          message("Unable to fix spatial file errors in city maps.")
        }
      )
    }

    cli::cli_process_done()
    steps <- steps + 1
  }
  cli::cli_process_start(paste0(steps, ") Prepping AFP linelist data"))

  ctry.data$afp.all <- .raw.data$afp |>
    # filter(stringr::str_detect(place.admin.0, .country)) |>
    dplyr::filter(place.admin.0 == .country) |>
    dplyr::filter(!is.na(lon) & !is.na(lat)) |>
    sf::st_as_sf(
      coords = c(x = "lon", y = "lat"),
      crs = sf::st_crs(ctry.data$ctry)
    ) |>
    dplyr::rename(
      ctry = place.admin.0,
      prov = place.admin.1,
      dist = place.admin.2,
      sex = person.sex,
      date = dateonset,
      year = yronset,
      date.notify = datenotify,
      date.invest = dateinvest,
      cdc.class = cdc.classification.all
    )

  ctry.data$afp.all.2 <- .raw.data$afp |>
    # filter(stringr::str_detect(place.admin.0, .country)) |>
    dplyr::filter(place.admin.0 == .country) |>
    dplyr::rename(
      ctry = place.admin.0,
      prov = place.admin.1,
      dist = place.admin.2,
      sex = person.sex,
      date = dateonset,
      year = yronset,
      date.notify = datenotify,
      date.invest = dateinvest,
      cdc.class = cdc.classification.all
    )

  ctry.data$afp <- .raw.data$afp |>
    # filter(stringr::str_detect(place.admin.0, .country)) |>
    dplyr::filter(place.admin.0 == .country) |>
    dplyr::filter(!is.na(lon) & !is.na(lat)) |>
    dplyr::filter(!(
      cdc.classification.all %in% c("PENDING", "NPAFP", "COMPATIBLE", "UNKNOWN", "NOT-AFP")
    )) |>
    sf::st_as_sf(
      coords = c(x = "lon", y = "lat"),
      crs = sf::st_crs(ctry.data$ctry)
    ) |>
    dplyr::rename(
      ctry = place.admin.0,
      prov = place.admin.1,
      dist = place.admin.2,
      sex = person.sex,
      date = dateonset,
      year = yronset,
      date.notify = datenotify,
      date.invest = dateinvest,
      cdc.class = cdc.classification.all
    )

  ctry.data$afp.2 <- .raw.data$afp |>
    # filter(stringr::str_detect(place.admin.0, .country)) |>
    dplyr::filter(place.admin.0 == .country) |>
    dplyr::filter(!(
      cdc.classification.all %in% c("PENDING", "NPAFP", "COMPATIBLE", "UNKNOWN", "NOT-AFP")
    )) |>
    dplyr::rename(
      ctry = place.admin.0,
      prov = place.admin.1,
      dist = place.admin.2,
      sex = person.sex,
      date = dateonset,
      year = yronset,
      date.notify = datenotify,
      date.invest = dateinvest,
      cdc.class = cdc.classification.all
    )

  ctry.data$afp.epi <- .raw.data$afp.epi |>
    dplyr::filter(place.admin.0 == .country)
  # filter(stringr::str_detect(place.admin.0, .country))

  ctry.data$para.case <- ctry.data$afp.epi |>
    dplyr::filter(
      cdc.classification.all2 %in% c("cVDPV 2", "VDPV 1", "VDPV 2", "WILD 1", "cVDPV 1", "COMPATIBLE")
    ) |>
    dplyr::mutate(yronset = ifelse(is.na(yronset) == T, 2022, yronset)) # this fix was for the manually added MOZ case

  cli::cli_process_done()
  steps <- steps + 1
  cli::cli_process_start(paste0(steps, ") Prepping population data"))

  ctry.data$ctry.pop <- .raw.data$ctry.pop |>
    dplyr::filter(ADM0_NAME == .country) |>
    dplyr::select(year,
                  ctry = ADM0_NAME,
                  u15pop,
                  adm0guid,
                  datasource
    )

  ctry.data$prov.pop <- .raw.data$prov.pop |>
    dplyr::filter(ADM0_NAME == .country) |>
    dplyr::mutate(ADM0_NAME = .country) |>
    dplyr::select(year,
                  ctry = ADM0_NAME,
                  prov = ADM1_NAME,
                  u15pop = u15pop.prov,
                  adm0guid = ADM0_GUID,
                  adm1guid,
                  datasource
    )

  ctry.data$dist.pop <- .raw.data$dist.pop |>
    dplyr::filter(ADM0_NAME == .country) |>
    # filter(stringr::str_detect(ADM0_NAME, .country)) |>
    dplyr::mutate(ADM0_NAME = .country) |>
    dplyr::select(year,
                  ctry = ADM0_NAME,
                  prov = ADM1_NAME,
                  dist = ADM2_NAME,
                  u15pop,
                  adm0guid = ADM0_GUID,
                  adm1guid,
                  adm2guid,
                  datasource
    )

  cli::cli_process_done()
  steps <- steps + 1
  cli::cli_process_start(paste0(steps, ") Prepping positives data"))
  ctry.data$pos <- .raw.data$pos |>
    dplyr::filter(place.admin.0 == .country)
  # filter(stringr::str_detect(place.admin.0, .country)) |>
  cli::cli_process_done()
  steps <- steps + 1
  cli::cli_process_start(paste0(steps, ") Attaching ES data"))
  ctry.data$es <- .raw.data$es |>
    dplyr::filter(ADM0_NAME == .country)
  cli::cli_process_done()
  steps <- steps + 1
  cli::cli_process_start(paste0(steps, ") Attaching SIA data"))
  ctry.data$sia <- .raw.data$sia |>
    dplyr::filter(place.admin.0 == .country)
  cli::cli_process_done()

  cli::cli_process_start("Attaching metadata from get_all_polio_data()")
  ctry.data$metadata <- .raw.data$metadata
  cli::cli_process_done()

  gc()

  return(ctry.data)
}
