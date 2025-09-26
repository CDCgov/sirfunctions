generate_pop_tab_country <- function(
    pnpafp, pstool, start_date, end_date,
    country_cols = c("Country","Admin0OfficialName","ctry","country"),
    year_col = "year",
    weight_pop_cols = c("u15pop","u5_pop")
) {
  if (!requireNamespace("flextable", quietly = TRUE)) {
    stop('Package "flextable" must be installed to use this function.', call. = FALSE)
  }

  # --- helpers ---
  pick_first_col <- function(df, candidates) {
    f <- intersect(candidates, names(df))
    if (length(f) == 0) return(NULL)
    f[[1]]
  }

  wmean <- function(x, w) {
    if (is.null(w) || !(length(w) == length(x))) return(mean(x, na.rm = TRUE))
    ok <- is.finite(x) & is.finite(w) & !is.na(w)
    if (!any(ok)) return(NA_real_)
    sum(x[ok] * w[ok], na.rm = TRUE) / sum(w[ok], na.rm = TRUE)
  }

  # --- dates ---
  start_date <- lubridate::as_date(start_date)
  end_date   <- lubridate::as_date(end_date)
  date.analysis <- seq(lubridate::year(start_date), lubridate::year(end_date), by = 1)

  # --- detect columns ---
  ccol_p <- pick_first_col(pnpafp, country_cols)
  ccol_s <- pick_first_col(pstool,  country_cols)
  if (is.null(ccol_p) || is.null(ccol_s)) {
    stop("Couldn't find a country column. Tried: ", paste(country_cols, collapse = ", "))
  }
  wcol <- pick_first_col(pnpafp, weight_pop_cols)
  if (is.null(wcol)) wcol <- "u15pop"

  # --- select minimal sets ---
  sub.case <- pnpafp |>
    dplyr::select(dplyr::any_of(c(ccol_p, year_col, "n_npafp", "u15pop", "npafp_rate"))) |>
    dplyr::rename(country = dplyr::all_of(ccol_p))

  sub.stool <- pstool |>
    dplyr::select(dplyr::any_of(c(ccol_s, year_col, "per.stool.ad"))) |>
    dplyr::rename(country = dplyr::all_of(ccol_s))

  # --- country-year aggregation ---
  sub.case.cy <- sub.case |>
    dplyr::filter(!is.na(country)) |>
    dplyr::group_by(country, .data[[year_col]]) |>
    dplyr::summarise(
      n_npafp    = sum(n_npafp, na.rm = TRUE),
      u15pop     = sum(u15pop,  na.rm = TRUE),
      npafp_rate = if ("npafp_rate" %in% names(dplyr::cur_data_all())) {
        wmean(npafp_rate, if (wcol %in% names(dplyr::cur_data_all())) .data[[wcol]] else u15pop)
      } else NA_real_,
      .groups = "drop"
    ) |>
    dplyr::rename(year = dplyr::all_of(year_col))

  sub.stool.cy <- sub.stool |>
    dplyr::filter(!is.na(country)) |>
    dplyr::group_by(country, .data[[year_col]]) |>
    dplyr::summarise(
      per.stool.ad = mean(per.stool.ad, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::rename(year = dplyr::all_of(year_col))

  # --- join + diffs, rounding ---
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

  # --- wide layout like original ---
  pop.date.analysis <- if (length(date.analysis) > 1) {
    paste0("u15pop_", date.analysis[seq_len(length(date.analysis) - 1)])
  } else character(0)

  sub.wide <- tidyr::pivot_wider(
    sub.join,
    names_from = "year",
    values_from = c("per.stool.ad","diff","diff_per","n_npafp","npafp_rate","u15pop")
  ) |>
    dplyr::select(-dplyr::all_of(pop.date.analysis))

  n_npafp_cols     <- paste0("n_npafp_", date.analysis)
  diff_per_cols    <- if (length(date.analysis) > 1) paste0("diff_per_", date.analysis[-1]) else character(0)
  npafp_rate_cols  <- paste0("npafp_rate_", date.analysis)
  stool_cols       <- paste0("per.stool.ad_", date.analysis)
  latest_pop_col   <- paste0("u15pop_", tail(date.analysis, 1))

  var.ord <- c("country", latest_pop_col, n_npafp_cols, diff_per_cols, npafp_rate_cols, stool_cols)
  sub.wide <- sub.wide[, var.ord, drop = FALSE] |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~tidyr::replace_na(.x, 0)))

  var.ord.case <- c("country", latest_pop_col, n_npafp_cols, diff_per_cols)

  # --- color matrices (same rules as original) ---
  col_palette <- c("#FF9999", "white")

  col.npafp.rate <- sub.wide[, npafp_rate_cols, drop = FALSE] |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~tidyr::replace_na(.x, 0))) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~cut(.x, breaks = c(0, 2), right = FALSE, labels = FALSE)))
  npafp.rate.colors <- col_palette[as.matrix(col.npafp.rate)]

  col.stool.ad <- sub.wide[, stool_cols, drop = FALSE] |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~tidyr::replace_na(.x, 0))) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), ~cut(.x, breaks = c(0, 80), right = FALSE, labels = FALSE)))
  stool.ad.colors <- col_palette[as.matrix(col.stool.ad)]

  sub.wide.case <- sub.wide |>
    dplyr::select(dplyr::all_of(var.ord.case))

  null.col <- rep(NA_character_, ncol(sub.wide.case) * nrow(sub.wide.case))
  col.mat  <- c(null.col, npafp.rate.colors, stool.ad.colors)

  inad <- sub.join |>
    dplyr::filter(npafp_rate < 2 | per.stool.ad < 80)
  uni.inad <- match(unique(inad$country), sub.wide$country)

  col.mat.txt <- stringr::str_replace(col.mat, "#FF9999", "#CC0000")
  col.mat.txt[uni.inad] <- "#CC0000"

  # header sizes
  npafp.case.length <- length(n_npafp_cols) + length(diff_per_cols)
  npafp.rate.length <- length(npafp_rate_cols)
  stool.ad.length   <- length(stool_cols)

  diff.yr <- length(diff_per_cols)
  diff.lab <- if (diff.yr > 0) {
    vapply(seq_len(diff.yr), function(i) {
      paste("% difference ", min(date.analysis) + i - 1, "-", min(date.analysis) + i)
    }, character(1))
  } else character(0)

  names1 <- names(sub.wide)
  names2 <- c("Country",
              paste0("U15 Population - ", max(date.analysis)),
              as.character(date.analysis),
              diff.lab,
              as.character(date.analysis),
              as.character(date.analysis))

  small_border <- flextable::fp_border_default(color = "black", width = 1)

  pop.tab <- flextable::flextable(sub.wide) |>
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

  return(pop.tab)
}

