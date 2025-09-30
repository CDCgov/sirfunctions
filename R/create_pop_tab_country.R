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
    dplyr::select(
      "year",
      "n_npafp",
      "u15pop",
      "adm0guid",
      "ctry",
      "npafp_rate"
    )

  # Stool adequacy
  sub.stool.cy <- cstool |>
    dplyr::filter(!is.na(ctry)) |>
    dplyr::select("year", "per.stool.ad", "adm0guid", "ctry")

  # ---- Join, diffs, rounding ----
  sub.join <- dplyr::full_join(sub.case.cy, sub.stool.cy, by = join_by(year, adm0guid, ctry)) |>
    dplyr::rename(country = "ctry") |>
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
  date.analysis <- seq(lubridate::year(start_date), lubridate::year(end_date), 1)
  pop.date.analysis <- paste0("u15pop_", date.analysis[1:length(date.analysis) - 1])

  sub.ctry.join.wide <- tidyr::pivot_wider(
    sub.join,
    names_from = "year",
    values_from = c(
      "per.stool.ad",
      "diff",
      "diff_per",
      "n_npafp",
      "npafp_rate",
      "u15pop"
    )
  ) %>%
    dplyr::select(-dplyr::any_of(pop.date.analysis))

  var.ord <- c(
    "country",
    paste0("u15pop_", date.analysis[length(date.analysis)]),
    paste0("n_npafp_", date.analysis),
    paste0("diff_per_", date.analysis[2:length(date.analysis)]),
    paste0("npafp_rate_", date.analysis),
    paste0("per.stool.ad_", date.analysis)
  )

  sub.ctry.join.wide <- sub.ctry.join.wide |> dplyr::select(dplyr::any_of(var.ord)) %>%
    replace(is.na(.), 0)

  var.ord.case <- c(
    "country",
    paste0("u15pop_", date.analysis[length(date.analysis)]),
    paste0("n_npafp_", date.analysis),
    paste0("diff_per_", date.analysis[2:length(date.analysis)])
  )

  # ---- Coloring (targets) ----
  # NPAFP table
  col_palette <- c("#FF9999", "white")
  col.npafp.rate <- sub.ctry.join.wide |>
    dplyr::select(dplyr::any_of(paste0("npafp_rate_", date.analysis))) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), \(x) tidyr::replace_na(x, 0))) |>
    dplyr::mutate(dplyr::across(c(dplyr::everything()), \(x) cut(
      x,
      breaks = c(0, 2),
      right = F,
      label = FALSE
    )))

  npafp.rate.colors <- col_palette[as.matrix(col.npafp.rate)]

  # Stool adequacy
  col_palette <- c("#FF9999", "white")
  col.stool.ad <- sub.ctry.join.wide |> dplyr::select(dplyr::any_of(paste0("per.stool.ad_", date.analysis))) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), \(x) tidyr::replace_na(x, 0))) |>
    dplyr::mutate(dplyr::across(c(dplyr::everything()), \(x) cut(
      x,
      breaks = c(0, 80),
      right = F,
      label = FALSE
    )))

  stool.ad.colors <- col_palette[as.matrix(col.stool.ad)]

  # case vars only
  sub.ctry.join.wide.case <- sub.ctry.join.wide %>%
    dplyr::select(dplyr::any_of(var.ord.case))
  # Cases and differences

  null.col <- rep(c(NA),
                  times = ncol(sub.ctry.join.wide.case) * nrow(sub.ctry.join.wide.case)
  )

  col.mat <- c(null.col, npafp.rate.colors, stool.ad.colors)

  # Make countries not meeting indicators red
  # If stool ad or NPAFP below threshold - color = "#CC0000"
  # Subset of prov not meeting indicators any year
  inad.ctry <- sub.join %>%
    dplyr::filter(npafp_rate < 2 | per.stool.ad < 80)

  uni.inad.ctry <- match(unique(inad.ctry$country), sub.ctry.join.wide$country)

  # Color matrix
  col.mat.txt <- col.mat %>%
    stringr::str_replace(., "#FF9999", "#CC0000")
  col.mat.txt[uni.inad.ctry] <- "#CC0000"

  # Flextable column formatting calculations
  # # NPAFP cases length
  npafp.case.length <- length(subset(var.ord, grepl("n_n", var.ord) == T |
                                       grepl("diff", var.ord) == T))
  # NPAFP rate length
  npafp.rate.length <- length(subset(var.ord, grepl("rate", var.ord) == T))
  # stool adequacy length
  stool.ad.length <- length(subset(var.ord, grepl("stool", var.ord) == T))

  # Labels for % difference
  diff.yr <- length(which(grepl("diff", names(
    sub.ctry.join.wide
  )) == T))

  diff.lab <- NULL
  for (i in 1:(diff.yr)) {
    diff.lab[i] <- paste(
      "% difference ",
      min(date.analysis) + i - 1,
      "-",
      min(date.analysis) + i
    )
  }

  # Names for flextable columns
  names1 <- names(sub.ctry.join.wide)
  names2 <- c(
    "Country",
    paste0("U15 Population - ", max(date.analysis)),
    date.analysis,
    diff.lab,
    date.analysis,
    date.analysis
  )


  small_border <- flextable::fp_border_default(color = "black", width = 1)
  # pop.tab flextable
  pop.tab <- flextable::flextable(sub.ctry.join.wide) %>%
    flextable::theme_booktabs() %>%
    flextable::bg(j = colnames(sub.ctry.join.wide), bg = col.mat) %>%
    flextable::color(j = colnames(sub.ctry.join.wide), color = col.mat.txt) %>%
    flextable::align(align = "center", part = "all") %>%
    flextable::set_header_df(
      mapping = data.frame(
        keys = names1,
        values = names2,
        stringsAsFactors = FALSE
      ),
      key = "keys"
    ) %>%
    flextable::add_header_row(
      values = c("", "# NP AFP Cases", "NP AFP rate", "% Stool Adequacy"),
      colwidths = c(2, npafp.case.length, stool.ad.length, stool.ad.length),
      top = TRUE
    ) %>%
    flextable::vline(
      j = c(
        2,
        2 + npafp.case.length,
        2 + npafp.case.length + stool.ad.length
      ),
      border = small_border
    ) %>%
    flextable::hline(part = "header") %>%
    flextable::bold(bold = TRUE, part = "header") %>%
    flextable::align(align = "center", part = "all")

  return(pop.tab)
}

