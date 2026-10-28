# Country prioritization workflow ----

#' Initialize a country-prioritization analysis
#'
#' Creates a run folder and writes an editable country-prioritization template.
#'
#' @param path `str` Parent folder for country-prioritization runs.
#' @param name `str` Name of the run folder. Defaults to today's date.
#' @param edav `logical` Retained for compatibility with earlier templates.
#'   Data are not downloaded or saved by this initializer; the generated
#'   template calls [get_all_polio_data()] directly.
#'
#' @returns Invisibly returns the run folder path.
#' @export
#'
init_country_prioritization <- function(path = getwd(), name = NULL,
                                        edav = TRUE) {
  if (!dir.exists(path)) {
    cli::cli_abort("Invalid folder path, please try again.")
  }

  if (is.null(name)) {
    name <- paste0("country_prioritization_", Sys.Date())
  }

  analysis_path <- file.path(path, name)
  dir.create(analysis_path, recursive = TRUE, showWarnings = FALSE)

  Sys.setenv(
    GSAP_CTRY_PRIORITIZATION_ROOT = analysis_path,
    GSAP_CTRY_PRIORITIZATION_PARENT = normalizePath(path, winslash = "/")
  )

  template_path <- file.path(analysis_path,
                             "country_prioritization_template.R")
  if (!file.exists(template_path)) {
    generate_country_prioritization_template(path, name, edav)
  }

  cli::cli_alert_success(paste0(
    "Country-prioritization template created: ", analysis_path
  ))
  cli::cli_text(paste0("Template: {.file ", template_path, "}"))

  invisible(analysis_path)
}

# Normalize country labels before country-prioritization joins. These aliases
# cover the different country keys used by WUENIC, POLIS, risk tables, and
# spatial data.
normalize_GSAP_country_names <- function(x) {
  x <- stringr::str_to_upper(stringr::str_squish(as.character(x)))
  dplyr::case_when(
    x %in% c(
      "T\u00dcRK\u0130YE", "T\u00dcRKIYE", "TURKIYE", "TURKEY"
    ) ~ "TURKEY",
    x %in% c("GUINEA-BISSAU", "GUINEA BISSAU") ~ "GUINEA BISSAU",
    x == "COTE D'IVOIRE" ~ "COTE D IVOIRE",
    x == "UNITED KINGDOM" ~ "THE UNITED KINGDOM",
    x == "UNITED STATES" ~ "UNITED STATES OF AMERICA",
    x == "NORTH MACEDONIA" ~ "REPUBLIC OF NORTH MACEDONIA",
    x == "STATE OF PALESTINE" ~
      "OCCUPIED PALESTINIAN TERRITORY, INCLUDING EAST JERUSALEM",
    TRUE ~ x
  )
}

# Backwards-compatible name for callers that only need to normalize WUENIC
# country labels.
normalize_GSAP_immunity_country_names <- function(x) {
  normalize_GSAP_country_names(x)
}

#' Read WUENIC coverage inputs for country prioritization
#'
#' Reads the long-format `country` sheet from a WUENIC workbook and returns
#' one country-level table. The default follows the population-immunity
#' analysis: filter by year and vaccine, reshape coverage to one row per
#' country, and calculate the DTP1, DTP3, and IPV1 complements. Country
#' labels are standardized here because the workbook is an external input;
#' other prioritization inputs are expected to already use the package country
#' key.
#'
#' @param path `str` Path to the WUENIC Excel workbook.
#' @param sheet `str` Workbook sheet containing the long-format country data.
#' @param year `integer` Optional WUENIC year. If omitted, the maximum year
#'   available after filtering to the requested vaccines is used. The year is
#'   selected before any `target_grp` filter is applied. All three requested
#'   vaccines must have data for that year and target group.
#' @param target_grp `str` Optional WUENIC target group. `NULL` (the default)
#'   ignores this field; provide a value only when an explicit target-group
#'   filter is needed.
#' @param include_coverage `logical` Include the source coverage columns in
#'   addition to the complement columns. Defaults to `FALSE`, matching the
#'   reference analysis.
#'
#' @returns A tibble with `Country`, `zero.dose.pct`, `under.immun.pct`, and
#'   `no.ipv1.pct`; coverage columns are included when requested.
#' @export
#'
read_GSAP_immunity_data <- function(
    path,
    sheet = "country",
    year = NULL,
    target_grp = NULL,
    include_coverage = FALSE) {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    cli::cli_abort("Package 'readxl' is required to read the WUENIC workbook.")
  }
  if (!file.exists(path)) {
    cli::cli_abort(paste0("WUENIC workbook was not found: ", path))
  }
  data <- readxl::read_excel(path, sheet = sheet)
  required_columns <- c("country", "vaccine", "year", "coverage")
  if (!is.null(target_grp)) required_columns <- c(required_columns, "target_grp")
  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    cli::cli_abort(paste0(
      "The WUENIC sheet is missing required columns: ",
      paste(missing_columns, collapse = ", "), "."
    ))
  }

  vaccine_map <- c(
    dtp1.pct = "dtp1",
    dtp3.pct = "dtp3",
    ipv1.pct = "ipv1"
  )
  if (length(target_grp) > 1) {
    cli::cli_abort("target_grp must be one value or NULL.")
  }

  data <- data |>
    dplyr::mutate(
      country = as.character(.data$country),
      vaccine = stringr::str_to_lower(stringr::str_squish(.data$vaccine)),
      year = suppressWarnings(as.integer(.data$year)),
      coverage = suppressWarnings(as.numeric(.data$coverage))
    )
  if ("target_grp" %in% names(data)) {
    data <- data |>
      dplyr::mutate(target_grp = stringr::str_to_lower(stringr::str_squish(.data$target_grp)))
  }
  data <- data |>
    dplyr::filter(
      .data$vaccine %in% unname(vaccine_map),
      !is.na(.data$year)
    )
  if (nrow(data) == 0) {
    cli::cli_abort(
      "No DTP1, DTP3, or IPV1 records matched the requested filters."
    )
  }

  if (is.null(year)) {
    year <- max(data$year, na.rm = TRUE)
  }

  year <- suppressWarnings(as.integer(year))
  if (length(year) != 1 || is.na(year)) {
    cli::cli_abort("year must be one non-missing year or NULL.")
  }

  data <- data |>
    dplyr::filter(.data$year == .env$year)

  if (!is.null(target_grp)) {
    target_group <- stringr::str_to_lower(stringr::str_squish(target_grp))
    data <- data |>
      dplyr::filter(.data$target_grp == target_group)
  }

  if (nrow(data) == 0) {
    cli::cli_abort(paste0(
      "No DTP1, DTP3, or IPV1 records matched WUENIC year ", year,
      " and target_grp '", target_grp, "'."
    ))
  }

  available_vaccines <- unique(data$vaccine)
  missing_vaccines <- setdiff(unname(vaccine_map), available_vaccines)
  if (length(missing_vaccines) > 0) {
    cli::cli_abort(paste0(
      "The selected WUENIC year ", year, " is missing: ",
      paste(missing_vaccines, collapse = ", "), "."
    ))
  }

  output <- data |>
    dplyr::transmute(
      Country = normalize_GSAP_country_names(.data$country),
      vaccine = .data$vaccine,
      vaccine_output = names(vaccine_map)[
        match(.data$vaccine, unname(vaccine_map))
      ],
      value = .data$coverage
    ) |>
    dplyr::group_by(.data$Country, .data$vaccine_output) |>
    dplyr::summarise(
      value = dplyr::first(.data$value[!is.na(.data$value)], default = NA_real_),
      .groups = "drop"
    ) |>
    tidyr::pivot_wider(
      names_from = vaccine_output,
      values_from = value
    )

  for (column in names(vaccine_map)) {
    if (!column %in% names(output)) output[[column]] <- NA_real_
  }

  output <- output |>
    dplyr::mutate(
      under.immun.pct = 100 - .data$dtp3.pct,
      no.ipv1.pct = 100 - .data$ipv1.pct,
      zero.dose.pct = 100 - .data$dtp1.pct
    )

  output <- if (isTRUE(include_coverage)) {
    output |>
      dplyr::select(
        .data$Country,
        dplyr::all_of(names(vaccine_map)),
        dplyr::all_of(c("zero.dose.pct", "under.immun.pct", "no.ipv1.pct"))
      )
  } else {
    output |>
      dplyr::select(
        .data$Country,
        dplyr::all_of(c("zero.dose.pct", "under.immun.pct", "no.ipv1.pct"))
      )
  }

  output |>
    dplyr::arrange(.data$Country)
}

# Build the formatted notes table used by the country-prioritization workbook.
build_GSAP_analysis_notes <- function(prioritization_output) {
  notes <- prioritization_output$analysis_notes
  if (!is.data.frame(notes)) {
    notes <- dplyr::tibble()
  }

  note_for <- function(field, fallback) {
    if (!all(c("Field", "Definition_or_notes") %in% names(notes))) {
      return(fallback)
    }
    match_row <- which(notes$Field == field)[1]
    if (is.na(match_row)) fallback else as.character(
      notes$Definition_or_notes[[match_row]]
    )
  }

  start_date <- prioritization_output$analysis_start_date
  end_date <- prioritization_output$analysis_end_date
  positive_end_date <- prioritization_output$positive_end_date
  if (length(start_date) == 1 && !is.na(start_date) &&
      length(end_date) == 1 && !is.na(end_date)) {
    period_note <- paste0(
      "Indicator analysis period: ", format(start_date, "%d-%b-%Y"),
      " to ", format(end_date, "%d-%b-%Y")
    )
  } else {
    period_note <- "Indicator analysis period: supplied in the country-prioritization template"
  }
  analysis_date <- if (length(positive_end_date) == 1 &&
                      !is.na(positive_end_date)) {
    positive_end_date
  } else {
    Sys.Date()
  }
  format_note_date <- function(date) {
    paste0(
      as.integer(format(date, "%m")), "/",
      as.integer(format(date, "%d")), "/",
      format(date, "%Y")
    )
  }
  virus_period_note <- paste0(
    "Virus analysis period aligns with 6 & 12 months prior to date of analysis; ",
    "12 months: ", format_note_date(get_GSAP_window_start(analysis_date, 12)),
    "; 6 months: ", format_note_date(get_GSAP_window_start(analysis_date, 6))
  )
  overall_note <- paste0(
    "Date of analysis: ", format(analysis_date, "%d-%b-%Y"), "\n",
    period_note, "\n",
    virus_period_note, "\n",
    "Countries are arranged by total risk score, highest to lowest; insufficient data are shown at the bottom"
  )

  notes_table <- data.frame(
    Field = c(
      "Country", "Previous GPSAP risk cat", "Total risk score (0-100)",
      "cVDPV/WPV risk score (0-25)", "Surveillance risk score (0-50)",
      "Immunity risk score (0-25)", "NPAFP (National)",
      "Stool adequacy (National)", "NPAFP (Subnational), %",
      "Stool adequacy (Subnational), %", "Detection within 46/35d, %",
      "Onset to lab within 14/18d, %", "ES sites >=50% EV",
      "WPV AFP/ES (last 6m)", "WPV AFP/ES (last 12m)",
      "cVDPV AFP/ES (last 6m)", "cVDPV AFP/ES (last 12m)",
      "Virus within 200km (6m)", "Virus within 200km details (6m)",
      "Zero dose, %", "Underimmunized, %", "IPV1 immunity gap, %"
    ),
    `Data source` = c(
      "POLIS", "GPSAP 2025-2026", "--", "--", "--", "--",
      rep("POLIS", 13),
      rep("WUENIC workbook", 3)
    ),
    `Definition or notes` = c(
      note_for(
        "Country inclusion",
        "Restricted to countries with data on at least 4/7 surveillance indicators available"
      ),
      "Category from the supplied risk table.",
      "Sum of the cVDPV/WPV, surveillance, and immunity weighted scores; countries without a calculable surveillance score are labelled insufficient data.",
      "25, Recent virus (or 25, Endemic); 12, Proximity to virus; 0 when neither condition applies.",
      "Sum of seven surveillance indicators, weighted to 50 and normalized to the number available.",
      "Sum of DTP1, DTP3, and IPV1 complement scores, weighted to 25.",
      "NPAFP cases per 100,000 population aged <15 years, summarized nationally (missing age cases were assumed <15 yrs, and were therefore included in analysis).",
      "Proportion of AFP cases meeting the two-stool adequacy definition, summarized nationally.",
      "Among districts with >=100K children under 15 years: proportion meeting the regional NPAFP target (missing age cases were assumed <15 yrs, and were therefore included in analysis).",
      "Among districts reporting >=5 AFP cases: proportion meeting the 80% stool-adequacy target (only includes districts with 5 or more NPAFP cases).",
      "Proportion of AFP/ES detections with final results within 35 or 46 days, as applicable.",
      "Proportion of AFP cases meeting the onset-to-laboratory field-shipment timeliness target.",
      "Proportion of active ES sites meeting the >=50% EV detection target. (Active Sites include sites in operation for ≥12 months and with ≥10 samples in the 12-month period)",
      "Count of WPV detections in the 6 months preceding the date of analysis.",
      "Count of WPV detections in the 12 months preceding the date of analysis.",
      "Count of cVDPV detections in the 6 months preceding the date of analysis.",
      "Count of cVDPV detections in the 12 months preceding the date of analysis.",
      "Country border is within 200 km of a qualifying detection in a neighboring country during the previous six months.",
      "Details of qualifying detections contributing to the 200-km indicator.",
      "100% - DTP1%.", "100% - DTP3%.", "100% - IPV1% (IPV1 immunity gap)."
    ),
    `Low (+0)` = c(
      "--", "--", "--", "--", "--", "--", ">=2", ">=80%",
      ">=80%", ">=80%", ">=80%", ">=80%", ">=80%", "0", "0", "0", "0",
      "No", "--", "<=5%", "<=5%", "<=5%"
    ),
    `Medium (+5)` = c(
      "--", "--", "--", "--", "--", "--", "1 to <2", "60-79%",
      "60-79%", "60-79%", "60-79%", "60-79%", "60-79%", "--", "--", "--",
      "--", "Yes and no WPV/cVDPV detected in country", "--", "6-20%", "6-20%", "6-20%"
    ),
    `High (+10)` = c(
      "--", "--", "--", "--", "--", "--", "<1", "<60%", "<60%", "<60%",
      "<60%", "<60%", "<60%", ">=1", NA, NA, NA, "--", "--", ">20%", ">20%", ">20%"
    ),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )

  list(overall_note = overall_note, table = notes_table)
}

#' Export a country-prioritization workbook
#'
#' @param prioritization_output A list containing `results` and optionally
#'   `analysis_notes`, as returned by
#'   [generate_GSAP_ctry_prioritization()].
#' @param output_path `str` File path for the Excel workbook.
#'
#' @returns Invisibly returns `output_path`.
#' @export
#'
export_GSAP_ctry_prioritization <- function(prioritization_output,
                                             output_path) {
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    cli::cli_abort("Package 'openxlsx' is required to write the workbook.")
  }
  if (!is.list(prioritization_output) ||
      !is.data.frame(prioritization_output$results)) {
    cli::cli_abort(
      "prioritization_output must be the result of generate_GSAP_ctry_prioritization()."
    )
  }
  if (missing(output_path) || length(output_path) != 1 || is.na(output_path)) {
    cli::cli_abort("Please provide one output_path for the Excel workbook.")
  }

  output_dir <- dirname(output_path)
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  }

  note_content <- build_GSAP_analysis_notes(prioritization_output)

  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "Results")
  openxlsx::addWorksheet(wb, "Analysis notes")
  results_for_export <- prioritization_output$results
  total_score_name <- "Total risk score (0-100)"
  if (total_score_name %in% names(results_for_export)) {
    total_score_text <- trimws(as.character(results_for_export[[total_score_name]]))
    total_score_numeric <- suppressWarnings(as.numeric(total_score_text))
    insufficient <- is.na(total_score_numeric) |
      tolower(total_score_text) == "insufficient data"
    results_for_export <- results_for_export[
      order(insufficient, -ifelse(is.na(total_score_numeric), -Inf,
                                  total_score_numeric),
            as.character(results_for_export$Country)),
      , drop = FALSE
    ]
  }
  header_style <- openxlsx::createStyle(
    textDecoration = "bold", halign = "center", border = "Bottom",
    wrapText = TRUE
  )
  result_names <- names(results_for_export)
  blank_if_num_error <- c(
    "NPAFP (National)",
    "Stool adequacy (National)",
    "NPAFP (Subnational), %",
    "Stool adequacy (Subnational), %",
    "Detection within 46/35d, %",
    "Onset to lab within 14/18d, %",
    "ES sites >=50% EV"
  )
  for (column_name in intersect(blank_if_num_error, result_names)) {
    column <- results_for_export[[column_name]]
    if (is.numeric(column)) {
      column[!is.finite(column)] <- NA_real_
    } else {
      column[trimws(as.character(column)) %in% c("#NUM!", "#NUM")] <- NA_character_
    }
    results_for_export[[column_name]] <- column
  }
  result_names <- names(results_for_export)
  openxlsx::writeData(
    wb, "Results", results_for_export,
    withFilter = TRUE, headerStyle = header_style
  )
  blank_header_columns <- match(
    c("Proposed NEW risk cat", "Comments"), result_names
  )
  blank_header_columns <- blank_header_columns[!is.na(blank_header_columns)]
  if (length(blank_header_columns) > 0) {
    openxlsx::addStyle(
      wb, "Results",
      openxlsx::createStyle(
        fgFill = "#FFF2CC", textDecoration = "bold", halign = "center",
        wrapText = TRUE, border = "Bottom"
      ),
      rows = 1, cols = blank_header_columns, gridExpand = TRUE,
      stack = TRUE
    )
  }
  kpi_columns <- match(c(
    "NPAFP (National)", "Stool adequacy (National)",
    "NPAFP (Subnational), %", "Stool adequacy (Subnational), %",
    "Detection within 46/35d, %", "Onset to lab within 14/18d, %",
    "ES sites >=50% EV"
  ), result_names)
  score_columns <- match(c(
    "Total risk score (0-100)", "cVDPV/WPV risk score (0-25)",
    "Surveillance risk score (0-50)", "Immunity risk score (0-25)"
  ), result_names)
  total_score_column <- match("Total risk score (0-100)", result_names)
  result_rows <- seq_len(nrow(results_for_export)) + 1L
  if (length(kpi_columns) > 0 && length(result_rows) > 0) {
    openxlsx::addStyle(
      wb, "Results", openxlsx::createStyle(numFmt = "0.00"),
      rows = result_rows, cols = kpi_columns, gridExpand = TRUE,
      stack = TRUE
    )
  }
  if (length(score_columns) > 0 && length(result_rows) > 0) {
    openxlsx::addStyle(
      wb, "Results", openxlsx::createStyle(numFmt = "0"),
      rows = result_rows, cols = score_columns, gridExpand = TRUE,
      stack = TRUE
    )
  }
  if (!is.na(total_score_column) && length(result_rows) > 0) {
    total_score_text <- trimws(as.character(
      results_for_export[["Total risk score (0-100)"]]
    ))
    total_score_numeric <- suppressWarnings(as.numeric(total_score_text))
    mix_hex <- function(low, high, proportion) {
      low_rgb <- grDevices::col2rgb(low)
      high_rgb <- grDevices::col2rgb(high)
      rgb_values <- round(low_rgb + (high_rgb - low_rgb) * proportion)
      grDevices::rgb(rgb_values[1], rgb_values[2], rgb_values[3],
                     maxColorValue = 255)
    }
    score_fill <- function(score) {
      if (is.na(score)) return(NULL)
      score <- max(0, min(100, score))
      if (score <= 50) {
        mix_hex("#5B9BD5", "#FFF2CC", score / 50)
      } else {
        mix_hex("#FFF2CC", "#C00000", (score - 50) / 50)
      }
    }
    for (i in which(!is.na(total_score_numeric))) {
      openxlsx::addStyle(
        wb, "Results",
        openxlsx::createStyle(fgFill = score_fill(total_score_numeric[i])),
        rows = i + 1L, cols = total_score_column, stack = TRUE
      )
    }
  }
  openxlsx::writeData(
    wb, "Analysis notes", "Overall notes",
    startRow = 1, startCol = 1, colNames = FALSE
  )
  openxlsx::writeData(
    wb, "Analysis notes", note_content$overall_note,
    startRow = 1, startCol = 2, colNames = FALSE
  )
  openxlsx::writeData(
    wb, "Analysis notes", "Indicator risk score",
    startRow = 3, startCol = 4, colNames = FALSE
  )
  openxlsx::writeData(
    wb, "Analysis notes", note_content$table,
    startRow = 4, startCol = 1, withFilter = FALSE
  )
  openxlsx::mergeCells(wb, "Analysis notes", cols = 2:3, rows = 1)
  openxlsx::mergeCells(wb, "Analysis notes", cols = 4:6, rows = 3)
  openxlsx::mergeCells(wb, "Analysis notes", cols = 6, rows = 18:21)

  note_header <- openxlsx::createStyle(
    textDecoration = "bold", fgFill = "#D9E2F3", halign = "center",
    valign = "center", wrapText = TRUE,
    border = c("top", "bottom", "left", "right"), borderStyle = "thin"
  )
  note_field <- openxlsx::createStyle(
    textDecoration = "bold", halign = "left", valign = "center",
    wrapText = TRUE, border = c("left", "right"), borderStyle = "thin"
  )
  note_text <- openxlsx::createStyle(
    halign = "left", valign = "center", wrapText = TRUE,
    border = c("left", "right"), borderStyle = "thin"
  )
  note_risk <- openxlsx::createStyle(
    halign = "center", valign = "center", wrapText = TRUE,
    border = c("left", "right"), borderStyle = "thin"
  )
  section_style <- openxlsx::createStyle(
    textDecoration = "bold", halign = "center", valign = "center",
    border = c("top", "bottom", "left", "right"), borderStyle = "medium"
  )
  overall_label_style <- openxlsx::createStyle(
    textDecoration = "bold", halign = "left", valign = "center"
  )
  overall_text_style <- openxlsx::createStyle(
    halign = "left", valign = "center", wrapText = TRUE
  )
  openxlsx::addStyle(
    wb, "Analysis notes", note_header, rows = 4, cols = 1:6,
    gridExpand = TRUE, stack = TRUE
  )
  openxlsx::addStyle(
    wb, "Analysis notes", note_field, rows = 5:26, cols = 1,
    gridExpand = TRUE, stack = TRUE
  )
  openxlsx::addStyle(
    wb, "Analysis notes", note_text, rows = 5:26, cols = 2:3,
    gridExpand = TRUE, stack = TRUE
  )
  openxlsx::addStyle(
    wb, "Analysis notes", note_risk, rows = 5:26, cols = 4:6,
    gridExpand = TRUE, stack = TRUE
  )
  openxlsx::addStyle(
    wb, "Analysis notes", overall_label_style, rows = 1, cols = 1
  )
  openxlsx::addStyle(
    wb, "Analysis notes", overall_text_style, rows = 1, cols = 2
  )
  openxlsx::addStyle(
    wb, "Analysis notes", section_style, rows = 3, cols = 4
  )
  openxlsx::setColWidths(
    wb, "Analysis notes", cols = 1:6,
    widths = c(30.71, 18, 97, 9.14, 12.57, 9.14)
  )
  openxlsx::setRowHeights(
    wb, "Analysis notes", rows = 1, heights = 90
  )
  openxlsx::setRowHeights(
    wb, "Analysis notes", rows = c(11, 13, 14, 17),
    heights = c(45, 45, 45, 60)
  )
  openxlsx::setRowHeights(
    wb, "Analysis notes", rows = c(12, 15, 22), heights = c(30, 30, 60)
  )
  comments_column <- match("Comments", result_names)
  freeze_column <- if (!is.na(comments_column)) comments_column + 1L else 5L
  openxlsx::freezePane(
    wb, "Results", firstActiveRow = 2, firstActiveCol = freeze_column
  )
  openxlsx::setColWidths(
    wb, "Results", cols = 2, widths = 30
  )
  openxlsx::setColWidths(
    wb, "Results",
    cols = setdiff(seq_len(ncol(prioritization_output$results)), 2),
    widths = 15
  )
  openxlsx::saveWorkbook(wb, output_path, overwrite = TRUE)

  invisible(output_path)
}

#' Create the country-prioritization code template
#'
#' @param output_path Parent output folder.
#' @param name Run-folder name.
#' @param edav Whether the run uses EDAV.
#' @returns No return value. Writes an R script to the run folder.
#' @keywords internal
#'
generate_country_prioritization_template <- function(output_path, name,
                                                      edav) {
  analysis_path <- file.path(output_path, name)
  template_path <- file.path(
    analysis_path, "country_prioritization_template.R"
  )

  quote_r <- function(x) {
    paste0('"', gsub('"', '\\\\"', x, fixed = TRUE), '"')
  }

  init_call <- paste0(
    "init_country_prioritization(path = ", quote_r(output_path),
    ", name = ", quote_r(name), ", edav = ", edav, ")"
  )

  lines <- c(
    "# Country prioritization code template",
    paste0("# Created on: ", Sys.Date()),
    "#",
    "# Run this file section by section. Update the input-file paths and",
    "# analysis dates before running the calculation.",
    "",
    "library(sirfunctions)",
    "library(dplyr)",
    "library(readxl)",
    "",
    init_call,
    "",
    "# Pull current POLIS/Tidy POLIS data into memory (no RDS file is created).",
    "raw_data <- get_all_polio_data(local_caching = FALSE)",
    "",
    "# Analysis period ----",
    "start_date <- lubridate::as_date(\"2025-09-01\")",
    "end_date <- lubridate::as_date(\"2026-08-31\")",
    "",
    "# Required user-supplied inputs ----",
    "# Place the immunity file in the parent country_prioritization folder,",
    "# or change this path.",
    "country_prioritization_parent <- Sys.getenv(\"GSAP_CTRY_PRIORITIZATION_PARENT\",",
    "  unset = \"C:/Users/XJA9/Desktop/country_prioritization\")",
    "immunity_file <- file.path(country_prioritization_parent, \"wuenic2025rev_web-update.xlsx\")",
    "wuenic_year <- 2025",
    "wuenic_target_grp <- \"si\"",
    "",
    "if (!file.exists(immunity_file)) stop(\"Add wuenic2025rev_web-update.xlsx to the parent country_prioritization folder or update immunity_file.\")",
    "",
    "# This workbook is long-format; set wuenic_year and wuenic_target_grp",
    "# above to select the DTP1, DTP3, and IPV1 data used for country",
    "# prioritization.",
    "immunity_data <- read_GSAP_immunity_data(",
    "  immunity_file,",
    "  year = wuenic_year,",
    "  target_grp = wuenic_target_grp",
    ")",
    "# Risk-category input for the Previous (June 2023) column; verify that",
    "# this EDAV table is the intended historical version.",
    "previous_risk_table <- edav_io(\"read\", file_loc = get_constant(\"CTRY_RISK_CAT\"))",
    "",
    "# Use the country spatial layer attached to raw_data for the 200-km flag.",
    "ctry_sf <- if (\"global.ctry\" %in% names(raw_data)) raw_data$global.ctry else NULL",
    "",
    "# Laboratory locations are also pulled from EDAV.",
    "lab_locs <- get_lab_locs()",
    "",
    "# Load cleaned laboratory data so C2 uses DateStoolReceivedinLab.",
    "edav_io(\"read\", file_loc = get_constant(\"CLEANED_LAB_DATA\"))",
    "lab_data <- get(\"lab_data\", envir = globalenv())",
    "",
    "# Pull and calculate the required source data ----",
    "country_prio_data <- prepare_GSAP_ctry_prioritization_data(",
    "  raw_data = raw_data,",
    "  start_date = start_date,",
    "  end_date = end_date,",
    "  immunity_data = immunity_data,",
    "  risk_table = previous_risk_table,",
    "  lab_locs = lab_locs,",
    "  lab_data = lab_data,",
    "  ctry_sf = ctry_sf",
    ")",
    "",
    "# Analyze the immunity, detection, and proximity data ----",
    "country_prio_data <- analyze_GSAP_ctry_prioritization_data(",
    "  country_prio_data",
    ")",
    "",
    "# Review the calculated inputs before moving to scoring ----",
    "View(country_prio_data$surveillance_indicators)",
    "View(country_prio_data$immunity_indicators)",
    "View(country_prio_data$positive_indicators)",
    "View(country_prio_data$proximity_indicators)",
    "View(country_prio_data$country_indicators)",
    "names(country_prio_data$raw_data)",
    "",
    "# Optional diagnostic checks (separate from the prioritization report) ----",
    "checks_file <- file.path(",
    "  Sys.getenv(\"GSAP_CTRY_PRIORITIZATION_ROOT\"),",
    "  \"country_prioritization_checks.xlsx\"",
    ")",
    "# FALSE keeps the country-prioritization workbook to the three core checks.",
    "# Set include_details_inconsisten_GUIDs = TRUE to add inconsistent GUID details.",
    "# Set Full_KPI = TRUE when generating the expanded KPI checks workbook.",
    "country_prio_checks <- generate_checks(",
    "  raw_data = raw_data,",
    "  start_date = start_date,",
    "  end_date = end_date,",
    "  output_path = checks_file,",
    "  include_details_inconsisten_GUIDs = FALSE,",
    "  Full_KPI = FALSE",
    ")",
    "country_prio_checks",
    "",
    "# Calculate the final scores and output table ----",
    "country_prio_output <- calculate_GSAP_ctry_prioritization(",
    "  analyzed_data = country_prio_data,",
    "  previous_risk_table = previous_risk_table,",
    "  # Set to TRUE to include all countries present in the AFP data.",
    "  include_all_countries = FALSE",
    ")",
    "View(country_prio_output$results)",
    "",
    "# Export one Excel workbook ----",
    "output_file <- file.path(",
    "  Sys.getenv(\"GSAP_CTRY_PRIORITIZATION_ROOT\"),",
    "  \"country_prioritization.xlsx\"",
    ")",
    "export_GSAP_ctry_prioritization(country_prio_output, output_file)",
    "output_file"
  )

  writeLines(lines, template_path)
  invisible(template_path)
}
