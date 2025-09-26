generate_pop_tab_ctry <- function(pnpafp, pstool, start_date, end_date) {
  if (!requireNamespace("flextable", quietly = TRUE)) {
    stop('Package "flextable" must be installed to use this function.', call. = FALSE)
  }

  # Years to include / label
  start_date <- lubridate::as_date(start_date)
  end_date   <- lubridate::as_date(end_date)
  yrs <- seq(lubridate::year(start_date), lubridate::year(end_date), by = 1)

  # ---- Country-year aggregations----
  sub.case.cy <- pnpafp |>
    dplyr::filter(!is.na(ctry)) |>
    dplyr::group_by(country = ctry, year) |>
    dplyr::summarise(
      n_npafp    = sum(n_npafp, na.rm = TRUE),
      u15pop     = sum(u15pop,    na.rm = TRUE),
      npafp_rate = dplyr::first(na.omit(npafp_rate), default = NA_real_),
      .groups = "drop"
    )

  # Stool adequacy
  sub.stool.cy <- pstool |>
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
