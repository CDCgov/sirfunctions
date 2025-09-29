#' Country-Level Population Surveillance Table (wide, multi-year)
#'
#' @description
#' Builds a formatted table of country-level surveillance indicators across
#' a span of years. It aggregates inputs to the **country–year** level,
#' computes year-over-year differences in NP-AFP case counts,
#' pivots to a wide layout (one row per country; columns per year), and
#' applies target-based highlighting for **NPAFP rate < 2** and
#' **stool adequacy < 80%**.
#'
#' @param cnpafp A data frame containing country-level NP-AFP case data with
#'   at least the columns:
#'   - `ctry` (country identifier),
#'   - `year` (numeric or integer year),
#'   - `n_npafp` (NP-AFP case count),
#'   - `u15pop` (under-15 population),
#'   - `npafp_rate` (NP-AFP rate per 100,000).
#'
#' @param cstool A data frame containing country-level stool adequacy data with
#'   at least:
#'   - `ctry` (country identifier),
#'   - `year` (year),
#'   - `per.stool.ad` (percent stool adequacy).
#'
#' @param start_date,end_date Dates (any format coercible by
#'   [lubridate::as_date()]) defining the inclusive year range to display.
#'   All years between `year(start_date)` and `year(end_date)` are included.
#'
#' @details
#' - **Aggregation:** For each `ctry`–`year`, `n_npafp` and `u15pop` are summed.
#'   `npafp_rate` takes the first non-missing value encountered for that group.
#'   `per.stool.ad` is averaged across rows within the group.
#' - **Diff columns:** A year-on-year % difference for `n_npafp` is computed
#'   per country (`diff_per`), and rounded to 1 decimal.
#' - **Wide layout:** The result is pivoted to wide columns per year for
#'   `n_npafp`, `diff_per`, `npafp_rate`, `per.stool.ad`, and the latest year’s
#'   `u15pop` (older `u15pop_YYYY` columns are dropped).
#' - **Highlighting:** Cells with `npafp_rate < 2` or `per.stool.ad < 80` are
#'   colored `#FF9999`; country labels are darkened (`#CC0000`) if the country
#'   falls below either target in any year.
#'
#' @return A `flextable` object suitable for viewing in the RStudio Viewer
#'   (e.g., with `flextable::save_as_html()` + `rstudioapi::viewer()`), or
#'   exporting to Word/PowerPoint/HTML via `flextable`.
#'
#' @examples
#' \dontrun{
#' tab <- generate_pop_tab_ctry(
#'   cnpafp  = ctry.extract,  # your country NP-AFP dataset
#'   cstool  = cstool,        # your country stool adequacy dataset
#'   start_date = "2021-01-01",
#'   end_date   = "2024-12-31"
#' )
#' # View in RStudio
#' tmp <- tempfile(fileext = ".html")
#' flextable::save_as_html(tab, path = tmp)
#' rstudioapi::viewer(tmp)
#' }
#'
#' @importFrom lubridate as_date year
#' @importFrom dplyr filter group_by summarise mutate across ungroup arrange full_join
#' @importFrom dplyr select any_of lag
#' @importFrom tidyr pivot_wider replace_na
#' @importFrom stringr str_replace
#' @importFrom flextable flextable theme_booktabs bg color align set_header_df
#' @importFrom flextable add_header_row vline hline bold fp_border_default
#' @export
generate_pop_tab_ctry <- function(cnpafp, cstool, start_date, end_date) {
  if (!requireNamespace("flextable", quietly = TRUE)) {
    stop('Package "flextable" must be installed to use this function.', call. = FALSE)
  }

  # Years to include / label
  start_date <- lubridate::as_date(start_date)
  end_date   <- lubridate::as_date(end_date)
  yrs <- seq(lubridate::year(start_date), lubridate::year(end_date), by = 1)

  # ---- Country-year aggregations----
  sub.case.cy <- cnpafp |>
    dplyr::filter(!is.na(ctry)) |>
    dplyr::group_by(country = ctry, year) |>
    dplyr::summarise(
      n_npafp    = sum(n_npafp, na.rm = TRUE),
      u15pop     = sum(u15pop,    na.rm = TRUE),
      npafp_rate = dplyr::first(na.omit(npafp_rate), default = NA_real_),
      .groups = "drop"
    )

  # Stool adequacy
  sub.stool.cy <- cstool |>
    dplyr::filter(!is.na(ctry)) |>
    dplyr::group_by(country = ctry, year) |>
    dplyr::summarise(
      per.stool.ad = mean(per.stool.ad, na.rm = TRUE),
      .groups = "drop"
    )

  # ---- Join, diffs, rounding ----
  sub.join <- dplyr::full_join(sub.case.cy, sub.stool.cy, by = c("country","year")) |>
    dplyr::arrange(country, year) |>
    dplyr::group_by(country) |>
    dplyr::mutate(
      diff     = dplyr::lag(n_npafp),
      diff_per = round(100 * (n_npafp - dplyr::lag(n_npafp)) / dplyr::lag(n_npafp), 1)
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      dplyr::across(c(per.stool.ad, diff, diff_per, n_npafp), ~round(.x, 0)),
      dplyr::across(c(npafp_rate), ~round(.x, 1)),
      u15pop = round(u15pop, 0)
    ) |>
    dplyr::filter(!is.na(country))

  # ---- Long -> Wide with year columns; keep only latest pop column ----
  pop_rm <- if (length(yrs) > 1) paste0("u15pop_", yrs[-length(yrs)]) else character(0)

  sub.wide <- tidyr::pivot_wider(
    sub.join,
    names_from  = "year",
    values_from = c("per.stool.ad","diff","diff_per","n_npafp","npafp_rate","u15pop")
  ) |>
    dplyr::select(-dplyr::all_of(pop_rm))

  n_npafp_cols    <- paste0("n_npafp_", yrs)
  diff_per_cols   <- if (length(yrs) > 1) paste0("diff_per_", yrs[-1]) else character(0)
  npafp_rate_cols <- paste0("npafp_rate_", yrs)
  stool_cols      <- paste0("per.stool.ad_", yrs)
  latest_pop_col  <- paste0("u15pop_", tail(yrs, 1))

  var.ord <- c("country", latest_pop_col, n_npafp_cols, diff_per_cols, npafp_rate_cols, stool_cols)
  sub.wide <- sub.wide[, var.ord, drop = FALSE] |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~tidyr::replace_na(.x, 0)))

  var.ord.case <- c("country", latest_pop_col, n_npafp_cols, diff_per_cols)

  # ---- Coloring (targets) ----
  col_palette <- c("#FF9999", "white")

  col.npafp.rate <- sub.wide[, npafp_rate_cols, drop = FALSE] |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~tidyr::replace_na(.x, 0))) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~cut(.x, breaks = c(0, 2), right = FALSE, labels = FALSE)))
  npafp.rate.colors <- col_palette[as.matrix(col.npafp.rate)]

  col.stool.ad <- sub.wide[, stool_cols, drop = FALSE] |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~tidyr::replace_na(.x, 0))) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~cut(.x, breaks = c(0, 80), right = FALSE, labels = FALSE)))
  stool.ad.colors <- col_palette[as.matrix(col.stool.ad)]

  sub.wide.case <- sub.wide |> dplyr::select(dplyr::all_of(var.ord.case))
  null.col <- rep(NA_character_, ncol(sub.wide.case) * nrow(sub.wide.case))
  col.mat  <- c(null.col, npafp.rate.colors, stool.ad.colors)

  # Darken country label if sub-target in any year
  inad <- sub.join |> dplyr::filter(npafp_rate < 2 | per.stool.ad < 80)
  uni.inad <- match(unique(inad$country), sub.wide$country)

  col.mat.txt <- stringr::str_replace(col.mat, "#FF9999", "#CC0000")
  col.mat.txt[uni.inad] <- "#CC0000"

  # ---- Headers ----
  npafp.case.length <- length(n_npafp_cols) + length(diff_per_cols)
  npafp.rate.length <- length(npafp_rate_cols)
  stool.ad.length   <- length(stool_cols)

  diff.lab <- if (length(diff_per_cols) > 0) {
    vapply(seq_along(diff_per_cols), function(i) {
      paste("% difference ", min(yrs) + i - 1, "-", min(yrs) + i)
    }, character(1))
  } else character(0)

  names1 <- names(sub.wide)
  names2 <- c("Country",
              paste0("U15 Population - ", max(yrs)),
              as.character(yrs),
              diff.lab,
              as.character(yrs),
              as.character(yrs))

  small_border <- flextable::fp_border_default(color = "black", width = 1)

  flextable::flextable(sub.wide) |>
    flextable::theme_booktabs() |>
    flextable::bg(j = colnames(sub.wide), bg = col.mat) |>
    flextable::color(j = colnames(sub.wide), color = col.mat.txt) |>
    flextable::align(align = "center", part = "all") |>
    flextable::set_header_df(
      mapping = data.frame(keys = names1, values = names2, stringsAsFactors = FALSE),
      key = "keys"
    ) |>
    flextable::add_header_row(
      values = c("", "# NP AFP Cases", "NP AFP rate", "% Stool Adequacy"),
      colwidths = c(2, npafp.case.length, npafp.rate.length, stool.ad.length),
      top = TRUE
    ) |>
    flextable::vline(
      j = c(2,
            2 + npafp.case.length,
            2 + npafp.case.length + npafp.rate.length),
      border = small_border
    ) |>
    flextable::hline(part = "header") |>
    flextable::bold(bold = TRUE, part = "header") |>
    flextable::align(align = "center", part = "all")
}

