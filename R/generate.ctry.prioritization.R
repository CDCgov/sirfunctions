# Classify the virus measurements used by country prioritization.
# WPV is represented by WILD 1 in the POLIS positives data. Only cVDPV
# serotypes 1-3 contribute to the cVDPV counts.
classify_GSAP_positive_measurement <- function(x) {
  x <- stringr::str_squish(as.character(x))
  dplyr::case_when(
    x == "WILD 1" ~ "WPV",
    x %in% c("cVDPV 1", "cVDPV 2", "cVDPV 3") ~ "cVDPV",
    TRUE ~ NA_character_
  )
}

# Return a rolling-window start date using the validated Date end date.
# Keeping this in one helper avoids relying on lubridate::months(), which is
# not exported in all installed lubridate versions.
get_GSAP_window_start <- function(end_date, months_back) {
  end_date <- suppressWarnings(lubridate::as_date(end_date))
  if (length(end_date) != 1 || is.na(end_date)) {
    cli::cli_abort("end_date must be one valid date.")
  }
  if (length(months_back) != 1 || is.na(months_back) ||
      !is.numeric(months_back) || months_back < 0 ||
      months_back != floor(months_back)) {
    cli::cli_abort("months_back must be one non-negative whole number.")
  }

  end_year <- as.integer(format(end_date, "%Y"))
  end_month <- as.integer(format(end_date, "%m"))
  end_day <- as.integer(format(end_date, "%d"))
  target_index <- end_year * 12 + end_month - 1 - as.integer(months_back)
  target_year <- target_index %/% 12
  target_month <- target_index %% 12 + 1

  next_index <- target_index + 1
  next_year <- next_index %/% 12
  next_month <- next_index %% 12 + 1
  next_month_start <- as.Date(sprintf(
    "%04d-%02d-01", next_year, next_month
  ))
  target_month_end <- next_month_start - 1
  target_day <- min(
    end_day,
    as.integer(format(target_month_end, "%d"))
  )

  as.Date(sprintf(
    "%04d-%02d-%02d", target_year, target_month, target_day
  ))
}

# Score immunity gaps in the direction of risk: larger gaps receive higher
# scores. This is separate from score_0_5_10(), where higher indicator values
# are treated as better performance.
score_GSAP_immunity_0_5_10 <- function(x, low = 6, high = 20) {
  dplyr::case_when(
    is.na(x) ~ NA_real_,
    x >= high ~ 10,
    x >= low ~ 5,
    TRUE ~ 0
  )
}

#' Generate country-prioritization diagnostic checks
#'
#' Creates the diagnostic tables used to review missing NPAFP age data and
#' district population/NPAFP eligibility. The checks are separate from the
#' country-prioritization report calculations.
#'
#' @param raw_data `list` Output of [get_all_polio_data()].
#' @param start_date `Date` or date-like string. Start of the analysis period.
#' @param end_date `Date` or date-like string. End of the analysis period.
#' @param output_path Optional Excel output path. If `NULL`, no workbook is
#'   written.
#' @param missing_agemonths `logical` Whether district NPAFP eligibility checks
#'   include cases with missing `age.months`. Defaults to `TRUE`, matching the
#'   country-prioritization calculation.
#'
#' @returns A list containing `npafp_age_check` and `dist_pop_check_updated`.
#' @export
#'
generate_GSAP_ctry_prioritization_checks <- function(
    raw_data,
    start_date,
    end_date,
    output_path = NULL,
    missing_agemonths = TRUE) {
  required_raw <- c("afp", "dist.pop")
  missing_raw <- setdiff(required_raw, names(raw_data))
  if (length(missing_raw) > 0) {
    cli::cli_abort(paste0(
      "raw_data is missing: ", paste(missing_raw, collapse = ", ")
    ))
  }

  start_date <- suppressWarnings(lubridate::as_date(start_date))
  end_date <- suppressWarnings(lubridate::as_date(end_date))
  if (length(start_date) != 1 || length(end_date) != 1 ||
      is.na(start_date) || is.na(end_date) || start_date > end_date) {
    cli::cli_abort("Please provide valid start_date and end_date values.")
  }

  countries_check <- raw_data$afp |>
    dplyr::transmute(ctry = .data$place.admin.0) |>
    dplyr::mutate(
      ctry = normalize_GSAP_country_names(.data$ctry),
      ctry = dplyr::if_else(
        stringr::str_detect(.data$ctry, "TANZANIA"),
        "UNITED REPUBLIC OF TANZANIA",
        .data$ctry
      )
    ) |>
    dplyr::filter(!is.na(.data$ctry), .data$ctry != "") |>
    dplyr::distinct(.data$ctry) |>
    dplyr::arrange(.data$ctry) |>
    dplyr::pull(.data$ctry)

  npafp_age_check <- raw_data$afp |>
    dplyr::transmute(
      ctry = normalize_GSAP_country_names(.data$place.admin.0),
      date = lubridate::as_date(.data$dateonset),
      age.months = .data$age.months,
      is_npafp_case = .data$cdc.classification.all2 %in% c(
        "NPAFP", "PENDING", "LAB PENDING"
      )
    ) |>
    dplyr::filter(
      .data$ctry %in% countries_check,
      dplyr::between(.data$date, start_date, end_date),
      .data$is_npafp_case
    ) |>
    dplyr::group_by(.data$ctry) |>
    dplyr::summarise(
      total_npafp_cases = dplyr::n(),
      missing_age_cases = sum(is.na(.data$age.months)),
      missing_age_percent = round(
        .data$missing_age_cases / .data$total_npafp_cases * 100, 1
      ),
      .groups = "drop"
    ) |>
    dplyr::right_join(
      tibble::tibble(ctry = as.character(countries_check)),
      by = "ctry"
    ) |>
    dplyr::mutate(
      total_npafp_cases = tidyr::replace_na(.data$total_npafp_cases, 0),
      missing_age_cases = tidyr::replace_na(.data$missing_age_cases, 0),
      missing_age_percent = tidyr::replace_na(.data$missing_age_percent, 0)
    ) |>
    dplyr::arrange(.data$ctry)

  get_col <- function(data, choices) {
    found <- intersect(choices, names(data))
    if (length(found) == 0) {
      cli::cli_abort(paste0(
        "None of these columns were found: ", paste(choices, collapse = ", ")
      ))
    }
    found[[1]]
  }

  dist_pop <- raw_data$dist.pop
  dist_pop_check <- dist_pop |>
    dplyr::transmute(
      ctry = .data[[get_col(dist_pop, c("ctry", "ADM0_NAME"))]],
      adm2guid = .data[[get_col(dist_pop, c("adm2guid", "ADM2_GUID"))]],
      year = suppressWarnings(as.integer(
        .data[[get_col(dist_pop, "year")]]
      )),
      u15pop = suppressWarnings(as.numeric(.data[[get_col(
        dist_pop, c("u15pop", "u15pop.prov")
      )]]))
    ) |>
    dplyr::mutate(
      ctry = normalize_GSAP_country_names(.data$ctry),
      ctry = dplyr::if_else(
        stringr::str_detect(.data$ctry, "TANZANIA"),
        "UNITED REPUBLIC OF TANZANIA",
        .data$ctry
      )
    ) |>
    dplyr::filter(
      .data$ctry %in% countries_check,
      dplyr::between(
        .data$year,
        lubridate::year(start_date),
        lubridate::year(end_date)
      )
    ) |>
    dplyr::group_by(.data$ctry) |>
    dplyr::summarise(
      total_districts = dplyr::n_distinct(.data$adm2guid),
      districts_missing_population = dplyr::n_distinct(
        .data$adm2guid[is.na(.data$u15pop)]
      ),
      .groups = "drop"
    ) |>
    dplyr::right_join(
      tibble::tibble(ctry = as.character(countries_check)),
      by = "ctry"
    ) |>
    dplyr::mutate(
      total_districts = tidyr::replace_na(.data$total_districts, 0),
      districts_missing_population = tidyr::replace_na(
        .data$districts_missing_population, 0
      )
    ) |>
    dplyr::arrange(.data$ctry)

  district_npafp <- f.npafp.rate.01(
    afp.data = raw_data$afp,
    pop.data = raw_data$dist.pop,
    start.date = start_date,
    end.date = end_date,
    spatial.scale = "dist",
    rolling = TRUE,
    sp_continuity_validation = FALSE,
    missing_agemonths = missing_agemonths
  ) |>
    dplyr::mutate(
      ctry = normalize_GSAP_country_names(.data$ctry),
      ctry = dplyr::if_else(
        stringr::str_detect(.data$ctry, "TANZANIA"),
        "UNITED REPUBLIC OF TANZANIA",
        .data$ctry
      )
    ) |>
    dplyr::filter(.data$ctry %in% countries_check)

  district_analysis_counts <- district_npafp |>
    dplyr::group_by(.data$ctry) |>
    dplyr::summarise(
      districts_population_eligible = dplyr::n_distinct(
        .data$adm2guid[.data$par >= 100000]
      ),
      districts_more_than_5_npafp_cases = dplyr::n_distinct(
        .data$adm2guid[.data$n_npafp > 5]
      ),
      .groups = "drop"
    )

  dist_pop_check_updated <- dist_pop_check |>
    dplyr::left_join(district_analysis_counts, by = "ctry") |>
    dplyr::mutate(
      districts_population_eligible = tidyr::replace_na(
        .data$districts_population_eligible, 0
      ),
      districts_more_than_5_npafp_cases = tidyr::replace_na(
        .data$districts_more_than_5_npafp_cases, 0
      )
    ) |>
    dplyr::arrange(.data$ctry)

  checks <- list(
    District_Population_Check = dist_pop_check_updated,
    NPAFP_Age_Check = npafp_age_check
  )

  if (!is.null(output_path)) {
    if (!requireNamespace("writexl", quietly = TRUE)) {
      cli::cli_abort("Package 'writexl' is required to write the checks workbook.")
    }
    writexl::write_xlsx(checks, path = output_path)
  }

  checks
}

#' Prepare country-prioritization source data
#'
#' Pulls the existing sirfunctions KPI calculations needed for the first
#' country-prioritization stage. This function does not download POLIS data;
#' the caller supplies the in-memory result of [get_all_polio_data()]. It also
#' keeps the positives data available for the later virus-risk step and reads
#' the long-format WUENIC workbook supplied outside POLIS.
#'
#' @param raw_data `list` Output of [get_all_polio_data()].
#' @param start_date `Date` or date-like string. Start of the analysis period.
#' @param end_date `Date` or date-like string. End of the analysis period.
#' @param immunity_data `tibble` Optional already-read WUENIC data.
#' @param immunity_file `str` Optional WUENIC workbook path. Used when
#'   `immunity_data` is `NULL`.
#' @param wuenic_year `integer` Optional WUENIC year to use when
#'   `immunity_data` is read from `immunity_file`. If `NULL`, the reader uses
#'   its default year-selection behavior.
#' @param risk_table `tibble` Optional current country-risk table. Defaults to
#'   the EDAV `CTRY_RISK_CAT` table.
#' @param lab_locs `tibble` Optional laboratory-location table. Defaults to
#'   the EDAV laboratory-location data.
#' @param ctry_sf Optional country spatial layer. Defaults to
#'   `raw_data$global.ctry` when present.
#' @param lab_data `tibble` Optional cleaned laboratory data containing
#'   `DateStoolReceivedinLab`. When supplied, this date is used for the C2
#'   onset-to-laboratory timeliness indicator.
#'
#' @returns A list containing the source inputs, existing KPI tables, and
#'   `surveillance_indicators` table with the indicators needed by the later
#'   scoring step.
#' @export
#'
prepare_GSAP_ctry_prioritization_data <- function(
    raw_data,
    start_date,
    end_date,
    immunity_data = NULL,
    immunity_file = NULL,
    wuenic_year = NULL,
    risk_table = NULL,
    lab_locs = NULL,
    ctry_sf = NULL,
    lab_data = NULL) {
  required_raw <- c("afp", "es", "pos", "ctry.pop")
  missing_raw <- setdiff(required_raw, names(raw_data))
  if (length(missing_raw) > 0) {
    cli::cli_abort(paste0(
      "raw_data is missing: ", paste(missing_raw, collapse = ", ")
    ))
  }

  start_date <- suppressWarnings(lubridate::as_date(start_date))
  end_date <- suppressWarnings(lubridate::as_date(end_date))
  if (is.na(start_date) || is.na(end_date) || start_date > end_date) {
    cli::cli_abort("Please provide valid start_date and end_date values.")
  }

  if (is.null(immunity_data)) {
    if (is.null(immunity_file)) {
      cli::cli_abort(
        "Provide either immunity_data or the path to the WUENIC immunity_file."
      )
    }
    immunity_data <- read_GSAP_immunity_data(
      immunity_file,
      year = wuenic_year
    )
  }
  if (!is.data.frame(immunity_data)) {
    cli::cli_abort("immunity_data must be a data frame or tibble.")
  }
  if (is.null(risk_table)) {
    risk_table <- suppressMessages(
      edav_io("read", file_loc = get_constant("CTRY_RISK_CAT"))
    )
  }
  if (!is.data.frame(risk_table)) {
    cli::cli_abort("risk_table must be a data frame or tibble.")
  }
  if (!is.null(lab_data) && !is.data.frame(lab_data)) {
    cli::cli_abort("lab_data must be a data frame or tibble.")
  }
  if (is.null(lab_locs)) {
    lab_locs <- get_lab_locs()
  }
  if (is.null(ctry_sf) && "global.ctry" %in% names(raw_data)) {
    ctry_sf <- raw_data$global.ctry
  }

  latest_period <- function(data, country_col) {
    if (!"analysis_year_end" %in% names(data)) {
      return(data |>
        dplyr::distinct(.data[[country_col]], .keep_all = TRUE))
    }
    valid_dates <- !is.na(data$analysis_year_end)
    if (!any(valid_dates)) {
      return(data |>
        dplyr::distinct(.data[[country_col]], .keep_all = TRUE))
    }
    latest <- max(data$analysis_year_end[valid_dates])
    data |>
      dplyr::filter(.data$analysis_year_end == latest) |>
      dplyr::distinct(.data[[country_col]], .keep_all = TRUE)
  }

  c1 <- generate_c1_table(
    raw_data, start_date, end_date,
    risk_table = risk_table, lab_locs = lab_locs,
    missing_agemonths = TRUE,
    stool_na_if_no_gt5_npafp = TRUE
  )
  c2 <- generate_c2_table(
    raw_data$afp, raw_data$ctry.pop, start_date, end_date,
    spatial_scale = "ctry", lab_locs = lab_locs, risk_table = risk_table,
    lab_data = lab_data
  )
  c1_latest <- latest_period(c1, "ctry")
  c2_latest <- latest_period(c2, "ctry")
  surveillance_indicators <- dplyr::full_join(
    c2_latest |>
      dplyr::transmute(
        Country = normalize_GSAP_country_names(.data$ctry),
        `NPAFP (National)` = .data$npafp_rate,
        `Stool adequacy (National)` = .data$per.stool.ad,
        `Onset to lab within 14/18d, %` =
          .data$timely_opt_field_shipment
      ),
    c1_latest |>
      dplyr::transmute(
        Country = normalize_GSAP_country_names(.data$ctry),
        `NPAFP (Subnational), %` = .data$prop_met_npafp,
        `Stool adequacy (Subnational), %` = .data$prop_met_stool,
        `ES sites >=50% EV` = .data$prop_met_ev,
        `Detection within 46/35d, %` =
          .data$prop_timely_wild_vdpv
      ),
    by = "Country"
  )

  surveillance_indicators <- surveillance_indicators |>
    dplyr::arrange(.data$Country)

  list(
    start_date = start_date,
    end_date = end_date,
    raw_data = raw_data,
    positives = raw_data$pos,
    immunity_data = immunity_data,
    risk_table = risk_table,
    lab_locs = lab_locs,
    lab_data = lab_data,
    ctry_sf = ctry_sf,
    c1 = c1,
    c2 = c2,
    surveillance_indicators = surveillance_indicators
  )
}

#' Analyze country-prioritization immunity and virus data
#'
#' Applies the legacy country-prioritization calculations to the prepared
#' inputs. This includes immunity complements, six- and twelve-month WPV and
#' cVDPV counts, and the 200-km virus-proximity flag and detail field.
#'
#' @param prepared_data Output of [prepare_GSAP_ctry_prioritization_data()].
#' @param end_date Optional analysis end date. Defaults to the date stored in
#'   `prepared_data`.
#' @param positive_end_date Date used as the end of the six- and twelve-month
#'   positive-detection and proximity windows. Defaults to `Sys.Date()`.
#'
#' @returns `prepared_data` with `immunity_indicators`, `positive_indicators`,
#'   `proximity_indicators`, and `country_indicators` added.
#' @export
#'
analyze_GSAP_ctry_prioritization_data <- function(prepared_data,
                                                   end_date = NULL,
                                                   positive_end_date = Sys.Date()) {
  required <- c(
    "raw_data", "positives", "immunity_data", "ctry_sf",
    "surveillance_indicators"
  )
  missing <- setdiff(required, names(prepared_data))
  if (length(missing) > 0) {
    cli::cli_abort(paste0(
      "prepared_data is missing: ", paste(missing, collapse = ", ")
    ))
  }

  if (is.null(end_date)) {
    end_date <- prepared_data$end_date
  }
  end_date <- suppressWarnings(lubridate::as_date(end_date))
  if (is.na(end_date)) {
    cli::cli_abort("Please provide a valid end_date.")
  }
  positive_end_date <- suppressWarnings(
    lubridate::as_date(positive_end_date)
  )
  if (length(positive_end_date) != 1 || is.na(positive_end_date)) {
    cli::cli_abort("Please provide a valid positive_end_date.")
  }

  immunity <- prepared_data$immunity_data
  if (!"Country" %in% names(immunity) && "country" %in% names(immunity)) {
    immunity <- dplyr::rename(immunity, Country = country)
  }
  if (!"Country" %in% names(immunity)) {
    cli::cli_abort("immunity_data must contain a Country column.")
  }

  coverage_cols <- c("dtp1.pct", "dtp3.pct", "ipv1.pct")
  complement_cols <- c("zero.dose.pct", "under.immun.pct", "no.ipv1.pct")
  if (all(coverage_cols %in% names(immunity))) {
    immunity <- immunity |>
      dplyr::mutate(
        zero.dose.pct = 100 - .data$dtp1.pct,
        under.immun.pct = 100 - .data$dtp3.pct,
        no.ipv1.pct = 100 - .data$ipv1.pct
      )
  } else if (!all(complement_cols %in% names(immunity))) {
    cli::cli_abort(paste0(
      "immunity_data must contain dtp1.pct, dtp3.pct, and ipv1.pct, or ",
      "zero.dose.pct, under.immun.pct, and no.ipv1.pct."
    ))
  }

  immunity_indicators <- immunity |>
    dplyr::transmute(
      Country = normalize_GSAP_country_names(.data$Country),
      zero.dose.pct = as.numeric(.data$zero.dose.pct),
      under.immun.pct = as.numeric(.data$under.immun.pct),
      no.ipv1.pct = as.numeric(.data$no.ipv1.pct)
    ) |>
    dplyr::distinct(.data$Country, .keep_all = TRUE)

  pos <- prepared_data$positives
  required_pos <- c("place.admin.0", "dateonset", "measurement", "source")
  missing_pos <- setdiff(required_pos, names(pos))
  if (length(missing_pos) > 0) {
    cli::cli_abort(paste0(
      "positives is missing: ", paste(missing_pos, collapse = ", ")
    ))
  }

  pos <- pos |>
    dplyr::mutate(
      Country = normalize_GSAP_country_names(.data$place.admin.0),
      dateonset = lubridate::as_date(.data$dateonset),
      virus_group = classify_GSAP_positive_measurement(.data$measurement)
    )

  count_window <- function(months_back, suffix) {
    window_start <- get_GSAP_window_start(positive_end_date, months_back)
    pos |>
      dplyr::filter(
        .data$source %in% c("ENV", "AFP"),
        .data$dateonset >= window_start,
        .data$dateonset <= positive_end_date
      ) |>
      dplyr::group_by(.data$Country) |>
      dplyr::summarise(
        !!paste0("wpv.count.", suffix) := sum(
          .data$virus_group == "WPV", na.rm = TRUE
        ),
        !!paste0("cvdpv.count.", suffix) := sum(
          .data$virus_group == "cVDPV", na.rm = TRUE
        ),
        .groups = "drop"
      )
  }

  positive_indicators <- count_window(6, "6m") |>
    dplyr::full_join(count_window(12, "12m"), by = "Country") |>
    dplyr::mutate(dplyr::across(
      dplyr::starts_with(c("wpv.count", "cvdpv.count")),
      function(x) dplyr::coalesce(x, 0)
    )) |>
    dplyr::rename(
      `WPV AFP/ES (last 6m)` = "wpv.count.6m",
      `WPV AFP/ES (last 12m)` = "wpv.count.12m",
      `cVDPV AFP/ES (last 6m)` = "cvdpv.count.6m",
      `cVDPV AFP/ES (last 12m)` = "cvdpv.count.12m"
    )

  shapes <- prepared_data$ctry_sf
  if (is.null(shapes) || !inherits(shapes, "sf")) {
    cli::cli_abort(
      "Country spatial data are required for the 200-km virus-proximity analysis."
    )
  }
  if (!"ADM0_NAME" %in% names(shapes)) {
    cli::cli_abort("Country spatial data must contain an ADM0_NAME column.")
  }

  if ("yr.end" %in% names(shapes)) {
    valid_shape_years <- !is.na(shapes$yr.end)
    if (any(valid_shape_years)) {
      latest_shape_year <- max(shapes$yr.end[valid_shape_years])
      shapes <- shapes |>
        dplyr::filter(.data$yr.end == latest_shape_year)
    }
  }

  if (any(!sf::st_is_valid(shapes), na.rm = TRUE)) {
    shapes <- sf::st_make_valid(shapes)
  }
  shapes <- shapes[!sf::st_is_empty(shapes), ]

  required_coords <- c("latitude", "longitude")
  missing_coords <- setdiff(required_coords, names(pos))
  if (length(missing_coords) > 0) {
    cli::cli_abort(paste0(
      "positives is missing: ", paste(missing_coords, collapse = ", "),
      "; these are required for the proximity analysis."
    ))
  }

  points <- pos |>
    dplyr::filter(
      .data$dateonset >= get_GSAP_window_start(positive_end_date, 6),
      .data$dateonset <= positive_end_date,
      !is.na(.data$latitude), !is.na(.data$longitude),
      !is.na(.data$virus_group)
    ) |>
    sf::st_as_sf(
      coords = c("longitude", "latitude"),
      crs = 4326,
      remove = FALSE
    ) |>
    sf::st_transform(3857) |>
    dplyr::mutate(source_country = .data$Country)

  shape_names <- normalize_GSAP_country_names(shapes$ADM0_NAME)
  buffers <- shapes |>
    dplyr::select(buffer_country = ADM0_NAME) |>
    dplyr::mutate(
      buffer_country = normalize_GSAP_country_names(.data$buffer_country)
    ) |>
    sf::st_transform(3857) |>
    sf::st_buffer(dist = 200000)

  if (nrow(points) == 0) {
    proximity_indicators <- dplyr::tibble(
      Country = shape_names,
      `Virus within 200km (6m)` = "No",
      `Virus within 200km details (6m)` = NA_character_
    )
  } else {
    hits <- suppressWarnings(sf::st_join(
      points, buffers, join = sf::st_intersects, left = FALSE
    )) |>
      dplyr::filter(.data$source_country != .data$buffer_country) |>
      dplyr::group_by(
        .data$buffer_country, .data$source_country, .data$measurement
      ) |>
      dplyr::summarise(n = dplyr::n(), .groups = "drop")

    hit_summary <- hits |>
      dplyr::mutate(detail = paste0(
        stringr::str_remove_all(.data$measurement, " "), "-",
        stringr::str_to_title(.data$source_country), ": ", .data$n
      )) |>
      dplyr::group_by(.data$buffer_country) |>
      dplyr::summarise(
        `Virus within 200km (6m)` = "Yes",
        `Virus within 200km details (6m)` = paste(
          .data$detail, collapse = ", "
        ),
        .groups = "drop"
      )

    proximity_indicators <- dplyr::tibble(Country = shape_names) |>
      dplyr::left_join(
        dplyr::rename(hit_summary, Country = buffer_country),
        by = "Country"
      ) |>
      dplyr::mutate(
        `Virus within 200km (6m)` = dplyr::coalesce(
          .data$`Virus within 200km (6m)`, "No"
        )
      )
  }

  country_indicators <- prepared_data$surveillance_indicators |>
    dplyr::mutate(
      Country = normalize_GSAP_country_names(.data$Country)
    ) |>
    dplyr::full_join(positive_indicators, by = "Country") |>
    dplyr::full_join(proximity_indicators, by = "Country") |>
    dplyr::full_join(immunity_indicators, by = "Country") |>
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of(c(
          "WPV AFP/ES (last 6m)", "WPV AFP/ES (last 12m)",
          "cVDPV AFP/ES (last 6m)", "cVDPV AFP/ES (last 12m)"
        )),
        function(x) dplyr::coalesce(x, 0)
      ),
      `Virus within 200km (6m)` = dplyr::coalesce(
        .data$`Virus within 200km (6m)`, "No"
      )
    ) |>
    dplyr::arrange(.data$Country)

  prepared_data$immunity_indicators <- immunity_indicators
  prepared_data$positive_indicators <- positive_indicators
  prepared_data$proximity_indicators <- proximity_indicators
  prepared_data$country_indicators <- country_indicators
  prepared_data$positive_end_date <- positive_end_date
  prepared_data
}

#' Calculate final country-prioritization scores and output table
#'
#' Applies the legacy country-prioritization scoring thresholds and weights to
#' the analyzed data. The result contains the final output columns used by the
#' country-prioritization workbook.
#'
#' @param analyzed_data Output of [analyze_GSAP_ctry_prioritization_data()].
#' @param previous_risk_table Optional table containing the previous GPSAP
#'   country categories. Defaults to the risk table carried in `analyzed_data`.
#' @param min_surv_ind Minimum number of the seven surveillance indicators
#'   required to retain a country. Defaults to `4`.
#'
#' @returns A list with `results` and `analysis_notes`.
#' @export
#'
calculate_GSAP_ctry_prioritization <- function(
    analyzed_data,
    previous_risk_table = NULL,
    min_surv_ind = 4) {
  if (!is.list(analyzed_data) ||
      !is.data.frame(analyzed_data$country_indicators)) {
    cli::cli_abort(
      "analyzed_data must be the result of analyze_GSAP_ctry_prioritization_data()."
    )
  }

  first_column <- function(data, choices, label) {
    found <- choices[choices %in% names(data)]
    if (length(found) == 0) {
      cli::cli_abort(paste0(
        "The previous risk table is missing the required ", label, " column."
      ))
    }
    found[[1]]
  }

  risk_table <- previous_risk_table
  if (is.null(risk_table)) {
    risk_table <- analyzed_data$risk_table
  }
  if (!is.data.frame(risk_table)) {
    cli::cli_abort("previous_risk_table must be a data frame or tibble.")
  }

  risk_country <- first_column(risk_table, c("Country", "country"), "country")
  risk_category <- first_column(
    risk_table,
    c("SG Priority Level", "risk_category", "risk.category"),
    "risk category"
  )
  risk_region <- intersect(c("Region", "who_region", "WHO Region"), names(risk_table))
  risk_region <- if (length(risk_region) > 0) risk_region[[1]] else NULL

  risk <- dplyr::tibble(
    Country = normalize_GSAP_country_names(risk_table[[risk_country]]),
    `Previous GPSAP risk cat` = as.character(
      risk_table[[risk_category]]
    ),
    `WHO Region` = if (is.null(risk_region)) {
      NA_character_
    } else {
      as.character(risk_table[[risk_region]])
    }
  ) |>
    dplyr::distinct(.data$Country, .keep_all = TRUE)

  indicators <- analyzed_data$country_indicators |>
    dplyr::mutate(
      Country = normalize_GSAP_country_names(.data$Country)
    ) |>
    dplyr::full_join(risk, by = "Country") |>
    dplyr::mutate(
      `WHO Region` = dplyr::coalesce(
        as.character(.data$`WHO Region`),
        as.character(get_region(.data$Country))
      ),
      `Previous GPSAP risk cat` = dplyr::coalesce(
        as.character(.data$`Previous GPSAP risk cat`),
        "LOW"
      ),
      previous_risk_override = dplyr::case_when(
        gsub(
          "\\s+", " ",
          trimws(toupper(as.character(.data$`Previous GPSAP risk cat`)))
        ) == "LOW WATCHLIST" ~ "LOW (WATCHLIST)",
        TRUE ~ gsub(
          "\\s+", " ",
          trimws(toupper(as.character(.data$`Previous GPSAP risk cat`)))
        )
      )
    )

  score_0_5_10 <- function(x, low, high) {
    dplyr::case_when(
      is.na(x) ~ NA_real_,
      x >= high ~ 0,
      x >= low ~ 5,
      TRUE ~ 10
    )
  }
  surveillance_fields <- c(
    "NPAFP (National)", "Stool adequacy (National)",
    "NPAFP (Subnational), %", "Stool adequacy (Subnational), %",
    "ES sites >=50% EV", "Detection within 46/35d, %",
    "Onset to lab within 14/18d, %"
  )

  indicators <- indicators |>
    dplyr::mutate(
      num.surv.ind = rowSums(!is.na(dplyr::pick(
        dplyr::all_of(surveillance_fields)
      ))),
      polio_recent = dplyr::coalesce(
        .data$`WPV AFP/ES (last 12m)`, 0
      ) > 0 | dplyr::coalesce(
        .data$`cVDPV AFP/ES (last 12m)`, 0
      ) > 0,
      endemic = .data$Country %in% c("AFGHANISTAN", "PAKISTAN"),
      polio_risk_category = dplyr::case_when(
        .data$endemic ~ "25, Endemic",
        .data$polio_recent ~ "25, Recent virus",
        .data$`Virus within 200km (6m)` == "Yes" ~
          "12, Proximity to virus",
        TRUE ~ "0"
      ),
      polio_risk_score = dplyr::case_when(
        .data$endemic | .data$polio_recent ~ 10,
        .data$`Virus within 200km (6m)` == "Yes" ~ 5,
        TRUE ~ 0
      ),
      zero_dose_score = score_GSAP_immunity_0_5_10(.data$zero.dose.pct),
      underimm_score = score_GSAP_immunity_0_5_10(.data$under.immun.pct),
      no_ipv_score = score_GSAP_immunity_0_5_10(.data$no.ipv1.pct),
      num.immun.ind = rowSums(!is.na(dplyr::pick(dplyr::all_of(c(
        "zero.dose.pct", "under.immun.pct", "no.ipv1.pct"
      ))))),
      score_ctry_npafp = score_0_5_10(.data$`NPAFP (National)`, 1, 2),
      score_nat_stool = score_0_5_10(.data$`Stool adequacy (National)`, 60, 80),
      score_subnat_npafp = score_0_5_10(.data$`NPAFP (Subnational), %`, 60, 80),
      score_subnat_stool = score_0_5_10(.data$`Stool adequacy (Subnational), %`, 60, 80),
      score_ev = score_0_5_10(.data$`ES sites >=50% EV`, 60, 80),
      score_detection = score_0_5_10(.data$`Detection within 46/35d, %`, 60, 80),
      score_onset_lab = score_0_5_10(.data$`Onset to lab within 14/18d, %`, 60, 80),
      total.immun.score = rowSums(dplyr::pick(dplyr::all_of(c(
        "zero_dose_score", "underimm_score", "no_ipv_score"
      ))), na.rm = TRUE),
      total.surv.score = rowSums(dplyr::pick(dplyr::all_of(c(
        "score_ctry_npafp", "score_nat_stool", "score_subnat_npafp",
        "score_subnat_stool", "score_ev", "score_detection",
        "score_onset_lab"
      ))), na.rm = TRUE),
      surv.score.w = dplyr::if_else(
        .data$num.surv.ind >= min_surv_ind,
        round(.data$total.surv.score / (.data$num.surv.ind * 10) * 50, 2),
        NA_real_
      ),
      immun.score.w = dplyr::if_else(
        .data$num.immun.ind > 0,
        round(.data$total.immun.score / 30 * 25, 2),
        NA_real_
      ),
      polio.score.w = round(.data$polio_risk_score / 10 * 25, 2),
      total.risk.score = dplyr::if_else(
        .data$num.surv.ind >= min_surv_ind,
        round(rowSums(dplyr::pick(dplyr::all_of(c(
          "surv.score.w", "immun.score.w", "polio.score.w"
        ))), na.rm = TRUE), 2),
        NA_real_
      )
    ) |>
    dplyr::filter(
      .data$num.surv.ind >= min_surv_ind |
        .data$previous_risk_override %in% c(
          "HIGH", "MEDIUM", "LOW (WATCHLIST)"
        )
    )

  display_score <- function(x, insufficient = FALSE) {
    insufficient <- rep_len(insufficient, length(x))
    dplyr::if_else(
      insufficient,
      "insufficient data",
      dplyr::if_else(
        is.na(x), "", format(round(x, 0), trim = TRUE, scientific = FALSE)
      )
    )
  }

  results <- indicators |>
    dplyr::transmute(
      `WHO Region`, Country,
      `Previous GPSAP risk cat`,
      `Total risk score (0-100)` = display_score(
        .data$total.risk.score, .data$num.surv.ind < min_surv_ind
      ),
      `cVDPV/WPV risk score (0-25)` = display_score(.data$polio.score.w),
      `Surveillance risk score (0-50)` = display_score(
        .data$surv.score.w, .data$num.surv.ind < min_surv_ind
      ),
      `Immunity risk score (0-25)` = display_score(.data$immun.score.w),
      `NPAFP (National)`, `Stool adequacy (National)`,
      `NPAFP (Subnational), %`, `Stool adequacy (Subnational), %`,
      `Detection within 46/35d, %`, `Onset to lab within 14/18d, %`,
      `ES sites >=50% EV`,
      `WPV AFP/ES (last 6m)`, `WPV AFP/ES (last 12m)`,
      `cVDPV AFP/ES (last 6m)`, `cVDPV AFP/ES (last 12m)`,
      `Virus within 200km (6m)`, `Virus within 200km details (6m)`,
      `Zero dose, %` = .data$zero.dose.pct,
      `Underimmunized, %` = .data$under.immun.pct,
      `No IPV1, %` = .data$no.ipv1.pct
    ) |>
    dplyr::arrange(.data$`WHO Region`, dplyr::desc(.data$`Total risk score (0-100)`))

  notes <- dplyr::tribble(
    ~Field, ~Data_source, ~Definition_or_notes,
    "Total risk score (0-100)", "Legacy country prioritization", "Surveillance weighted to 50, immunity weighted to 25, and cVDPV/WPV risk weighted to 25.",
    "cVDPV/WPV risk score (0-25)", "POLIS and country classification", "Endemic/recent virus scores 25; proximity to virus scores 12.5 before rounding.",
    "Surveillance risk score (0-50)", "sirfunctions KPI outputs", "Seven indicators scored 0/5/10 and normalized to the number available.",
    "ES sites >=50% EV", "C1 ES EV detection rate", "Proportion of active ES sites meeting the >=50% EV detection target. (Active Sites include sites in operation for ≥12 months and with ≥10 samples in the 12-month period)",
    "Immunity risk score (0-25)", "WUENIC workbook", "DTP1, DTP3, and IPV1 complements scored 0/5/10 and weighted to 25.",
    "Previous GPSAP risk cat", "Supplied risk table", "The category is taken from the supplied risk table; missing categories default to LOW.",
    "Country inclusion", "Legacy country prioritization", paste0("Countries are retained when at least ", min_surv_ind, " of 7 surveillance indicators are available, or when listed as HIGH, MEDIUM, or LOW (WATCHLIST) in the previous GPSAP risk table.")
  )

  list(
    results = results,
    analysis_notes = notes,
    analysis_start_date = analyzed_data$start_date,
    analysis_end_date = analyzed_data$end_date,
    score_details = indicators
  )
}

#' Generate a country prioritization workbook
#'
#' Calculate the GPSAP country-prioritization indicators and weighted scores
#' using the package KPI calculations for AFP, ES, and detection timeliness.
#' Population-immunity data are supplied explicitly because they are not part
#' of the POLIS download.
#'
#' @param raw_data `list` Output of [get_all_polio_data()]. The data must be
#'   supplied by the calling template; this function does not download or save
#'   a separate POLIS R data file.
#' @param start_date `Date` or date-like string. Start of the analysis period.
#' @param end_date `Date` or date-like string. End of the analysis period.
#' @param immunity_data `tibble` Country-level immunity data. It must contain
#'   `Country` (or `country`) and either `zero.dose.pct`, `under.immun.pct`,
#'   and `no.ipv1.pct`, or `dtp1.pct`, `dtp3.pct`, and `ipv1.pct`.
#' @param risk_table `tibble` Previous country-priority table. It must contain
#'   `Country` and `SG Priority Level`. Defaults to the country-risk table
#'   retrieved from EDAV using `CTRY_RISK_CAT`.
#' @param lab_locs `tibble` Laboratory-location data. Defaults to the package
#'   data source when `NULL`.
#' @param regional_classification `tibble` Optional table with `Country` and a
#'   column named `Regional classification`.
#' @param proposed_category `tibble` Optional table with `Country` and either
#'   `Proposed GPSAP 2025-26 prioritization` or `SG Priority Level`.
#' @param ctry_sf `sf` Optional country spatial data used for proximity to
#'   virus detections. If omitted, `raw_data$global.ctry` is used when present.
#' @param category_breaks `numeric` Optional named thresholds for assigning a
#'   proposed category from the total score. Names must include `HIGH`,
#'   `MEDIUM`, and `LOW (WATCHLIST)`.
#' @param min_surv_ind `integer` Minimum number of available surveillance
#'   indicators required to retain a country. Defaults to `4`.
#' @param output_path `str` Optional path for an Excel output. If `NULL`, no
#'   file is written.
#' @param positive_end_date `Date` Date used as the end of the six- and
#'   twelve-month positive-detection and proximity windows. Defaults to
#'   `Sys.Date()`.
#' @param lab_data `tibble` Optional cleaned laboratory data containing
#'   `DateStoolReceivedinLab`. When supplied, this date is used for the C2
#'   onset-to-laboratory timeliness indicator.
#'
#' @returns A list with `results`, `analysis_notes`, and `output_path`.
#' @export
#'
generate_GSAP_ctry_prioritization <- function(
    raw_data,
    start_date,
    end_date,
    immunity_data,
    risk_table = NULL,
    lab_locs = NULL,
    regional_classification = NULL,
    proposed_category = NULL,
    ctry_sf = NULL,
    category_breaks = NULL,
    min_surv_ind = 4,
    output_path = NULL,
    positive_end_date = Sys.Date(),
    lab_data = NULL) {

  required_raw <- c("afp", "es", "pos", "ctry.pop")
  missing_raw <- setdiff(required_raw, names(raw_data))
  if (length(missing_raw) > 0) {
    cli::cli_abort(paste0(
      "raw_data is missing: ", paste(missing_raw, collapse = ", ")
    ))
  }

  start_date <- lubridate::as_date(start_date)
  end_date <- lubridate::as_date(end_date)
  if (is.na(start_date) || is.na(end_date) || start_date > end_date) {
    cli::cli_abort("Please provide a valid start_date and end_date.")
  }
  positive_end_date <- suppressWarnings(
    lubridate::as_date(positive_end_date)
  )
  if (length(positive_end_date) != 1 || is.na(positive_end_date)) {
    cli::cli_abort("Please provide a valid positive_end_date.")
  }
  if (!is.data.frame(immunity_data)) {
    cli::cli_abort("immunity_data must be a data frame or tibble.")
  }
  if (!is.null(lab_data) && !is.data.frame(lab_data)) {
    cli::cli_abort("lab_data must be a data frame or tibble.")
  }
  if (is.null(risk_table)) {
    risk_table <- suppressMessages(
      edav_io("read", file_loc = get_constant("CTRY_RISK_CAT"))
    )
  }
  if (!is.data.frame(risk_table)) {
    cli::cli_abort("risk_table must be a data frame or tibble.")
  }

  first_column <- function(data, choices, label) {
    found <- choices[choices %in% names(data)]
    if (length(found) == 0) {
      cli::cli_abort(paste0(
        "The input is missing the required ", label, " column."
      ))
    }
    found[[1]]
  }

  risk_country <- first_column(risk_table, c("Country", "country"), "country")
  risk_priority <- first_column(
    risk_table, c("SG Priority Level", "risk_category"), "priority"
  )
  risk_table <- risk_table |>
    dplyr::rename(
      Country = dplyr::all_of(risk_country),
      `SG Priority Level` = dplyr::all_of(risk_priority)
    ) |>
    dplyr::mutate(
      Country = normalize_GSAP_country_names(Country),
      `SG Priority Level` = as.character(`SG Priority Level`)
    ) |>
    dplyr::distinct(Country, .keep_all = TRUE)
  if (!"Region" %in% names(risk_table)) {
    risk_table$Region <- NA_character_
  }

  immunity_country <- first_column(
    immunity_data, c("Country", "country"), "country"
  )
  immunity_data <- immunity_data |>
    dplyr::rename(Country = dplyr::all_of(immunity_country)) |>
    dplyr::mutate(Country = normalize_GSAP_country_names(Country))

  complement_cols <- c("zero.dose.pct", "under.immun.pct", "no.ipv1.pct")
  coverage_cols <- c("dtp1.pct", "dtp3.pct", "ipv1.pct")
  if (!all(complement_cols %in% names(immunity_data))) {
    if (!all(coverage_cols %in% names(immunity_data))) {
      cli::cli_abort(paste0(
        "immunity_data must contain either zero.dose.pct, under.immun.pct, ",
        "no.ipv1.pct or dtp1.pct, dtp3.pct, ipv1.pct."
      ))
    }
    immunity_data <- immunity_data |>
      dplyr::mutate(
        zero.dose.pct = 100 - .data$dtp1.pct,
        under.immun.pct = 100 - .data$dtp3.pct,
        no.ipv1.pct = 100 - .data$ipv1.pct
      )
  }
  immunity_data <- immunity_data |>
    dplyr::select(Country, dplyr::all_of(complement_cols)) |>
    dplyr::distinct(Country, .keep_all = TRUE)

  c1 <- generate_c1_table(
    raw_data, start_date, end_date,
    risk_table = risk_table, lab_locs = lab_locs,
    missing_agemonths = TRUE,
    stool_na_if_no_gt5_npafp = TRUE
  )
  c2 <- generate_c2_table(
    raw_data$afp, raw_data$ctry.pop, start_date, end_date,
    spatial_scale = "ctry", lab_locs = lab_locs, risk_table = risk_table,
    lab_data = lab_data
  )
  latest_period <- function(data, country_col) {
    if (!"analysis_year_end" %in% names(data)) {
      return(data)
    }
    latest <- max(data$analysis_year_end, na.rm = TRUE)
    data |>
      dplyr::filter(.data$analysis_year_end == latest) |>
      dplyr::distinct(.data[[country_col]], .keep_all = TRUE)
  }

  c1 <- latest_period(c1, "ctry") |>
    dplyr::select(
      Country = ctry,
      dplyr::any_of(c("prop_met_npafp", "prop_met_stool",
                      "prop_met_ev", "prop_timely_wild_vdpv"))
    ) |>
    dplyr::mutate(Country = normalize_GSAP_country_names(.data$Country))
  c2 <- latest_period(c2, "ctry") |>
    dplyr::select(
      Country = ctry,
      dplyr::any_of(c("npafp_rate", "per.stool.ad",
                      "timely_opt_field_shipment"))
    ) |>
    dplyr::mutate(Country = normalize_GSAP_country_names(.data$Country))
  count_positives <- function(pos, end_date) {
    needed <- c("place.admin.0", "dateonset", "measurement", "source")
    if (!all(needed %in% names(pos))) {
      return(dplyr::tibble(
        Country = character(),
        `WPV AFP/ES (last 6m)` = numeric(),
        `WPV AFP/ES (last 12m)` = numeric(),
        `cVDPV AFP/ES (last 6m)` = numeric(),
        `cVDPV AFP/ES (last 12m)` = numeric()
      ))
    }
    window_6m <- get_GSAP_window_start(end_date, 6)
    window_12m <- get_GSAP_window_start(end_date, 12)

    pos |>
      dplyr::mutate(
        dateonset = lubridate::as_date(.data$dateonset),
        virus_group = classify_GSAP_positive_measurement(.data$measurement)
      ) |>
      dplyr::filter(
        .data$source %in% c("ENV", "AFP"),
        .data$dateonset >= window_12m,
        .data$dateonset <= end_date
      ) |>
      dplyr::mutate(
        Country = normalize_GSAP_country_names(.data$place.admin.0),
        target = !is.na(.data$virus_group)
      ) |>
      dplyr::filter(.data$target) |>
      dplyr::group_by(Country) |>
      dplyr::summarise(
        `WPV AFP/ES (last 6m)` = sum(
          .data$dateonset >= window_6m &
            .data$virus_group == "WPV", na.rm = TRUE
        ),
        `WPV AFP/ES (last 12m)` = sum(
          .data$dateonset >= window_12m &
            .data$virus_group == "WPV", na.rm = TRUE
        ),
        `cVDPV AFP/ES (last 6m)` = sum(
          .data$dateonset >= window_6m &
            .data$virus_group == "cVDPV", na.rm = TRUE
        ),
        `cVDPV AFP/ES (last 12m)` = sum(
          .data$dateonset >= window_12m &
            .data$virus_group == "cVDPV", na.rm = TRUE
        ),
        .groups = "drop"
      )
  }

  proximity <- function(pos, shapes, end_date) {
    needed_pos <- c("place.admin.0", "dateonset", "measurement",
                    "latitude", "longitude")
    empty <- dplyr::tibble(
      Country = character(),
      `Virus within 200km (6m)` = character(),
      `Virus within 200km details (6m)` = character()
    )
    if (is.null(shapes) || !inherits(shapes, "sf") ||
        !all(needed_pos %in% names(pos)) ||
        !"ADM0_NAME" %in% names(shapes)) {
      return(empty)
    }

    if ("yr.end" %in% names(shapes) && any(!is.na(shapes$yr.end))) {
      latest_shape_year <- max(shapes$yr.end, na.rm = TRUE)
      shapes <- shapes |>
        dplyr::filter(.data$yr.end == latest_shape_year)
    }

    if (any(!sf::st_is_valid(shapes), na.rm = TRUE)) {
      shapes <- sf::st_make_valid(shapes)
    }
    shapes <- shapes[!sf::st_is_empty(shapes), ]

    points <- pos |>
      dplyr::mutate(
        dateonset = lubridate::as_date(.data$dateonset),
        virus_group = classify_GSAP_positive_measurement(.data$measurement)
      ) |>
      dplyr::filter(
        .data$dateonset >= get_GSAP_window_start(end_date, 6),
        .data$dateonset <= end_date,
        !is.na(.data$latitude), !is.na(.data$longitude),
        !is.na(.data$virus_group)
      ) |>
      sf::st_as_sf(coords = c("longitude", "latitude"),
                   crs = 4326, remove = FALSE) |>
      sf::st_transform(3857) |>
      dplyr::mutate(
        source_country = normalize_GSAP_country_names(.data$place.admin.0)
      )

    if (nrow(points) == 0) {
      return(dplyr::tibble(
        Country = normalize_GSAP_country_names(shapes$ADM0_NAME),
        `Virus within 200km (6m)` = "No",
        `Virus within 200km details (6m)` = NA_character_
      ))
    }

    buffers <- shapes |>
      dplyr::select(buffer_country = ADM0_NAME) |>
      dplyr::mutate(
        buffer_country = normalize_GSAP_country_names(.data$buffer_country)
      ) |>
      sf::st_transform(3857) |>
      sf::st_buffer(dist = 200000)

    hits <- suppressWarnings(sf::st_join(
      points, buffers, join = sf::st_intersects, left = FALSE
    )) |>
      dplyr::filter(.data$source_country != .data$buffer_country) |>
      dplyr::group_by(
        .data$buffer_country, .data$source_country, .data$measurement
      ) |>
      dplyr::summarise(n = dplyr::n(), .groups = "drop")

    result <- hits |>
      dplyr::mutate(detail = paste0(
        .data$measurement, "-", stringr::str_to_title(.data$source_country),
        ": ", .data$n
      )) |>
      dplyr::group_by(.data$buffer_country) |>
      dplyr::summarise(
        `Virus within 200km (6m)` = "Yes",
        `Virus within 200km details (6m)` = paste(.data$detail, collapse = ", "),
        .groups = "drop"
      )

    dplyr::tibble(
      Country = normalize_GSAP_country_names(shapes$ADM0_NAME)
    ) |>
      dplyr::left_join(
        dplyr::rename(result, Country = buffer_country),
        by = "Country"
      ) |>
      dplyr::mutate(`Virus within 200km (6m)` = dplyr::coalesce(
        .data$`Virus within 200km (6m)`, "No"
      ))
  }

  positives <- count_positives(raw_data$pos, positive_end_date)
  if (is.null(ctry_sf) && "global.ctry" %in% names(raw_data)) {
    ctry_sf <- raw_data$global.ctry
  }
  proximity_data <- proximity(raw_data$pos, ctry_sf, positive_end_date)

  indicators <- risk_table |>
    dplyr::select(
      Country, Region,
       `Previous GPSAP risk cat` = `SG Priority Level`
    ) |>
    dplyr::rename(`WHO Region` = Region) |>
    dplyr::mutate(`WHO Region` = dplyr::coalesce(
      as.character(.data$`WHO Region`),
      as.character(get_region(.data$Country))
    )) |>
    dplyr::full_join(c1, by = "Country") |>
    dplyr::full_join(c2, by = "Country")

  indicators <- indicators |>
    dplyr::full_join(positives, by = "Country") |>
    dplyr::full_join(proximity_data, by = "Country") |>
    dplyr::full_join(immunity_data, by = "Country") |>
    dplyr::mutate(
      `NPAFP (National)` = .data$npafp_rate,
       `Stool adequacy (National)` = .data$per.stool.ad,
      `NPAFP (Subnational), %` = .data$prop_met_npafp,
      `Stool adequacy (Subnational), %` = .data$prop_met_stool,
      `ES sites >=50% EV` = .data$prop_met_ev,
      `Detection within 46/35d, %` = .data$prop_timely_wild_vdpv,
      `Onset to lab within 14/18d, %` = .data$timely_opt_field_shipment,
      `Previous GPSAP risk cat` = dplyr::coalesce(
        as.character(.data$`Previous GPSAP risk cat`),
        "LOW"
      ),
      previous_risk_override = dplyr::case_when(
        gsub(
          "\\s+", " ",
          trimws(toupper(as.character(.data$`Previous GPSAP risk cat`)))
        ) == "LOW WATCHLIST" ~ "LOW (WATCHLIST)",
        TRUE ~ gsub(
          "\\s+", " ",
          trimws(toupper(as.character(.data$`Previous GPSAP risk cat`)))
        )
      ),
      `Virus within 200km (6m)` = dplyr::coalesce(
        .data$`Virus within 200km (6m)`, "No"
      )
    )

  if (!is.null(regional_classification)) {
    regional_country <- first_column(
      regional_classification, c("Country", "country"), "country"
    )
    regional_classification <- regional_classification |>
      dplyr::rename(Country = dplyr::all_of(regional_country)) |>
      dplyr::mutate(Country = normalize_GSAP_country_names(Country))
    indicators <- indicators |>
      dplyr::left_join(regional_classification, by = "Country")
  }

  if (!is.null(proposed_category)) {
    proposed_country <- first_column(
      proposed_category, c("Country", "country"), "country"
    )
    proposed_col <- first_column(
      proposed_category,
      c("Proposed GPSAP 2025-26 prioritization", "SG Priority Level"),
      "proposed category"
    )
    proposed_category <- proposed_category |>
      dplyr::rename(
        Country = dplyr::all_of(proposed_country),
        `Proposed GPSAP 2025-26 prioritization` = dplyr::all_of(proposed_col)
      ) |>
      dplyr::mutate(
        Country = normalize_GSAP_country_names(Country),
        `Proposed GPSAP 2025-26 prioritization` = as.character(
          `Proposed GPSAP 2025-26 prioritization`
        )
      ) |>
      dplyr::select(Country, `Proposed GPSAP 2025-26 prioritization`)
    indicators <- indicators |>
      dplyr::left_join(proposed_category, by = "Country")
  }

  score_0_5_10 <- function(x, low, high) {
    dplyr::case_when(
      is.na(x) ~ NA_real_,
      x >= high ~ 0,
      x >= low ~ 5,
      TRUE ~ 10
    )
  }
  indicators <- indicators |>
    dplyr::mutate(
      num.surv.ind = rowSums(!is.na(dplyr::pick(dplyr::all_of(c(
        "NPAFP (National)", "Stool adequacy (National)",
        "NPAFP (Subnational), %", "Stool adequacy (Subnational), %",
        "ES sites >=50% EV", "Detection within 46/35d, %",
        "Onset to lab within 14/18d, %"
      ))))),
      polio_recent = dplyr::coalesce(`WPV AFP/ES (last 12m)`, 0) > 0 |
        dplyr::coalesce(`cVDPV AFP/ES (last 12m)`, 0) > 0,
      endemic = Country %in% c("AFGHANISTAN", "PAKISTAN"),
      polio_risk_cat = dplyr::case_when(
        endemic ~ "25, Endemic",
        polio_recent ~ "25, Recent virus",
        `Virus within 200km (6m)` == "Yes" ~ "12, Proximity to virus",
        TRUE ~ "0"
      ),
      polio_risk_score = dplyr::case_when(
        endemic | polio_recent ~ 10,
        `Virus within 200km (6m)` == "Yes" ~ 5,
        TRUE ~ 0
      ),
      zero_dose_score = score_GSAP_immunity_0_5_10(zero.dose.pct),
      underimm_score = score_GSAP_immunity_0_5_10(under.immun.pct),
      no_ipv_score = score_GSAP_immunity_0_5_10(no.ipv1.pct),
      num.immun.ind = rowSums(!is.na(dplyr::pick(dplyr::all_of(c(
        "zero.dose.pct", "under.immun.pct", "no.ipv1.pct"
      ))))),
      score_ctry_npafp = score_0_5_10(`NPAFP (National)`, 1, 2),
      score_nat_stool = score_0_5_10(`Stool adequacy (National)`, 60, 80),
      score_subnat_npafp = score_0_5_10(`NPAFP (Subnational), %`, 60, 80),
      score_subnat_stool = score_0_5_10(`Stool adequacy (Subnational), %`, 60, 80),
      score_ev = score_0_5_10(`ES sites >=50% EV`, 60, 80),
      score_detection = score_0_5_10(`Detection within 46/35d, %`, 60, 80),
      score_onset_lab = score_0_5_10(`Onset to lab within 14/18d, %`, 60, 80),
      total.immun.score = rowSums(dplyr::pick(dplyr::all_of(c(
        "zero_dose_score", "underimm_score", "no_ipv_score"
      ))), na.rm = TRUE),
      total.surv.score = rowSums(dplyr::pick(dplyr::all_of(c(
        "score_ctry_npafp", "score_nat_stool", "score_subnat_npafp",
        "score_subnat_stool", "score_ev", "score_detection",
        "score_onset_lab"
      ))), na.rm = TRUE),
      surv.score.w = dplyr::if_else(
        num.surv.ind >= min_surv_ind,
        round(total.surv.score / (num.surv.ind * 10) * 50, 2),
        NA_real_
      ),
      immun.score.w = dplyr::if_else(
        num.immun.ind > 0,
        round(total.immun.score / 30 * 25, 2),
        NA_real_
      ),
      polio.score.w = round(polio_risk_score / 10 * 25, 2),
      total.risk.score = dplyr::if_else(
        num.surv.ind >= min_surv_ind,
        round(surv.score.w + immun.score.w + polio.score.w, 2),
        NA_real_
      )
    ) |>
    dplyr::filter(
      num.surv.ind >= min_surv_ind |
        previous_risk_override %in% c("HIGH", "MEDIUM", "LOW (WATCHLIST)")
    )

  if (!is.null(category_breaks)) {
    required_breaks <- c("HIGH", "MEDIUM", "LOW (WATCHLIST)")
    if (!all(required_breaks %in% names(category_breaks))) {
      cli::cli_abort(
        "category_breaks must name HIGH, MEDIUM, and LOW (WATCHLIST)."
      )
    }
    indicators <- indicators |>
      dplyr::mutate(
        `Proposed GPSAP 2025-26 prioritization` = dplyr::case_when(
          total.risk.score >= category_breaks[["HIGH"]] ~ "HIGH",
          total.risk.score >= category_breaks[["MEDIUM"]] ~ "MEDIUM",
          total.risk.score >= category_breaks[["LOW (WATCHLIST)"]] ~
            "LOW (WATCHLIST)",
          TRUE ~ "LOW"
        )
      )
  }
  if (!"Proposed GPSAP 2025-26 prioritization" %in% names(indicators)) {
    indicators <- indicators |>
      dplyr::mutate(`Proposed GPSAP 2025-26 prioritization` = NA_character_)
  }

  display_score <- function(x, insufficient = FALSE) {
    insufficient <- rep_len(insufficient, length(x))
    dplyr::if_else(
      insufficient,
      "insufficient data",
      dplyr::if_else(
        is.na(x), "", format(round(x, 0), trim = TRUE, scientific = FALSE)
      )
    )
  }

  results <- indicators |>
    dplyr::transmute(
      `WHO Region`, Country,
      `Previous GPSAP risk cat`,
      `Total risk score (0-100)` = display_score(
        total.risk.score, num.surv.ind < min_surv_ind
      ),
      `Proposed GPSAP 2025-26 prioritization`,
      `cVDPV/WPV risk score (0-25)` = display_score(polio.score.w),
      `Surveillance risk score (0-50)` = display_score(
        surv.score.w, num.surv.ind < min_surv_ind
      ),
      `Immunity risk score (0-25)` = display_score(immun.score.w),
      dplyr::any_of("Regional classification"),
      `NPAFP (National)`, `Stool adequacy (National)`,
      `NPAFP (Subnational), %`, `Stool adequacy (Subnational), %`,
      `Detection within 46/35d, %`, `Onset to lab within 14/18d, %`,
      `ES sites >=50% EV`,
      `WPV AFP/ES (last 6m)`,
      `WPV AFP/ES (last 12m)`, `cVDPV AFP/ES (last 6m)`,
      `cVDPV AFP/ES (last 12m)`, `Virus within 200km (6m)`,
      `Virus within 200km details (6m)`,
      `Zero dose, %` = zero.dose.pct,
      `Underimmunized, %` = under.immun.pct,
      `No IPV1, %` = no.ipv1.pct
    ) |>
    dplyr::arrange(`WHO Region`, dplyr::desc(`Total risk score (0-100)`))

  notes <- dplyr::tribble(
    ~Field, ~Data_source, ~Definition_or_notes,
    "Total risk score (0-100)", "--", "Sum of the three weighted component scores.",
    "Previous GPSAP risk cat", "GPSAP 2025-2026", "Category from the supplied risk table; missing categories default to LOW.",
    "cVDPV/WPV risk score (0-25)", "--", "Endemic/recent virus scores 25; proximity to virus scores 12.5 before rounding.",
    "Surveillance risk score (0-50)", "--", "Surveillance indicators scored 0/5/10 and weighted to 50.",
    "Immunity risk score (0-25)", "--", "DTP1, DTP3, and IPV1 complements scored 0/5/10 and weighted to 25.",
    "Country inclusion", "GPSAP 2025-2026", paste0("Retained when at least ", min_surv_ind, " of 7 surveillance indicators are available, or when listed as HIGH, MEDIUM, or LOW (WATCHLIST) in the previous GPSAP risk table."),
    "Detection within 46/35d, %", "sirfunctions", "Existing KPI timeliness-of-detection indicator; the label follows the requested final table.",
    "Proposed category", "Policy input", "Not assigned unless proposed_category or category_breaks is supplied."
  )

  if (!is.null(output_path)) {
    export_GSAP_ctry_prioritization(
      list(
        results = results,
        analysis_notes = notes
      ),
      output_path
    )
  }

  return(list(
    results = results,
    analysis_notes = notes,
    analysis_start_date = start_date,
    analysis_end_date = end_date,
    positive_end_date = positive_end_date,
    output_path = output_path
  ))
}
