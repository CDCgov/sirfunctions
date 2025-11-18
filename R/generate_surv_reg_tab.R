#' Regional Surveillance Indicators by Year (Multi-country aggregate)
#'
#' @description
#' Computes **region-level** time series of surveillance indicators by
#' aggregating across all countries present in your inputs (or implicitly after
#' the joins). The function:
#' 1) builds district-level indicators, restricts to districts with **U15 ≥ 100,000**,
#' 2) derives the **% population in adequate districts** (NPAFP rate ≥ 2 **and**
#'    stool adequacy ≥ 80%), and counts of adequate vs. total ≥100k districts,
#' 3) aggregates **country-level** indicators to the region using **simple means**
#'    for rates and **sums** for AFP cases, and
#' 4) returns either a tidy tibble or a formatted `flextable`.
#'
#' @param ctry_data A list-like object that contains at least `dist.pop`, a data
#'   frame with district metadata. Must include columns:
#'   - `ctry` (country code/name),
#'   - `adm2guid` (district id),
#'   and preferably `year` and a U15 population column (e.g., `u15pop`).
#'
#' @param ctry.extract Country-level dataset (one row per country-year). Should
#'   contain `year` and either `adm0guid` (to join with \code{cstool}) or
#'   `ctry`. It should include `npafp_rate` and `per.stool.ad`, or columns that
#'   can be unambiguously renamed to these.
#'
#' @param dist.extract District-level dataset (one row per district-year) with
#'   at minimum `adm2guid` and `year`. If it already contains `u15pop`,
#'   `npafp_rate`, `per.stool.ad`, those are used; otherwise they may be pulled
#'   in via joins.
#'
#' @param cstool Country-level surveillance stool adequacy dataset with `year` and
#'   either `adm0guid` or `ctry`, containing `npafp_rate` and `per.stool.ad`
#'   (or columns that can be renamed to these).
#'
#' @param dstool District-level surveillance stool adequacy dataset with `adm2guid`,
#'   `year`, and indicator columns such as `npafp_rate`, `per.stool.ad`.
#'
#' @param afp.cases Either:
#'   - country-year AFP case data with columns `ctry`, `year`, and a cases
#'     column (e.g., `afp.cases`, `afp.case`, `cases`) **or**
#'   - region/overall year totals with `year` and a cases column.
#'   The function will rename the first matching cases column to `afp.cases`.
#'
#' @param start_year,end_year Optional numeric bounds to filter the analysis
#'   years, inclusive.
#'
#' @param output One of `"flextable"` (default) or `"tibble"`. When `"tibble"`,
#'   returns a data frame with columns:
#'   `year`, `afp.cases`, `npafp_rate`, `per.stool.ad`, `prop.dist.adeq`, `prop`.
#'
#' @details
#' **U15 population column detection**: the function tries to ensure a column
#' named `u15pop` exists in the joined district data by:
#' 1) coalescing `u15pop.x`/`u15pop.y` after joins,
#' 2) renaming common aliases (e.g., `u15_pop`, `U15Pop`, `under15_pop`), or
#' 3) importing from `ctry_data$dist.pop` by `adm2guid` and `year`.
#'
#' **Adequacy rule (district level)**:
#' - Adequate if `npafp_rate >= 2` **and** `per.stool.ad >= 80`.
#' - The % population in adequate ≥100k districts is:
#'   \eqn{100 * (sum(U15 in adequate ≥100k districts) / sum(U15 in all ≥100k districts))}.
#'
#' **Aggregation**:
#' - AFP cases: summed across countries per year.
#' - `npafp_rate` and `per.stool.ad`: **simple means** across countries per year
#'   (switch to a weighted mean if needed).
#'
#' The output `flextable` renders `year` as plain text (no thousands separator).
#'
#' @return A `flextable` (default) for presentation, or a tibble when
#'   `output = "tibble"`.
#'
#' @examples
#' \dontrun{
#' ft <- generate_surv_reg_tab(
#'   ctry_data    = ctry_data,
#'   ctry.extract = ctry.extract,
#'   dist.extract = dist.extract,
#'   cstool       = cstool,
#'   dstool       = dstool,
#'   afp.cases    = afp.cases,
#'   start_year   = 2021,
#'   end_year     = 2024,
#'   output       = "flextable"
#' )
#' }
#'
#' @export
generate_surv_reg_tab <- function(
    ctry_data, ctry.extract, dist.extract, cstool, dstool, afp.cases,
    start_year = NULL, end_year = NULL,
    output = c("flextable","tibble")
) {
  output <- match.arg(output)
  for (pkg in c("dplyr","tidyr")) if (!requireNamespace(pkg, quietly=TRUE)) stop(sprintf('Need %s', pkg))

  # 1) Map districts \u2192 countries
  if (is.null(ctry_data$dist.pop) || !"ctry" %in% names(ctry_data$dist.pop))
    stop("ctry_data$dist.pop with columns ctry, adm2guid is required.")
  dist_map <- ctry_data$dist.pop |>
    dplyr::select(adm2guid, ctry) |>
    dplyr::distinct()

  # 2) Join district indicators
  dist.ind <- dplyr::left_join(dist.extract, dstool, by = c("adm2guid","year")) |>
    dplyr::left_join(dist_map,     by = "adm2guid")

  if (!is.null(start_year)) dist.ind <- dplyr::filter(dist.ind, year >= start_year)
  if (!is.null(end_year))   dist.ind <- dplyr::filter(dist.ind, year <= end_year)

  # 3) Ensure a column named u15pop exists
  nm <- names(dist.ind)
  if (all(c("u15pop.x","u15pop.y") %in% nm)) {
    dist.ind <- dist.ind |>
      dplyr::mutate(u15pop = dplyr::coalesce(.data$u15pop.x, .data$u15pop.y)) |>
      dplyr::select(-u15pop.x, -u15pop.y)
  }
  if (!"u15pop" %in% names(dist.ind)) {
    alias <- grep("^(u15pop|u15[_\\.]?pop|u15population|u_?15_?pop|pop[_\\.]?u15|under[_ ]?15(_?pop|_?population)?)$",
                  names(dist.ind), ignore.case = TRUE, value = TRUE)
    if (length(alias)) {
      dist.ind <- dplyr::rename(dist.ind, u15pop = dplyr::all_of(alias[1]))
    } else if (all(c("adm2guid","year") %in% names(ctry_data$dist.pop))) {
      u15_src_cols <- intersect(c("u15pop","u15_pop","U15Pop","u_15_pop","under15_pop","under_15_pop"),
                                names(ctry_data$dist.pop))
      if (length(u15_src_cols)) {
        u15_src <- ctry_data$dist.pop |>
          dplyr::select(.data$adm2guid, .data$year, u15pop = dplyr::all_of(u15_src_cols[1]))
        dist.ind <- dplyr::left_join(dist.ind, u15_src, by = c("adm2guid","year"))
      }
    }
  }
  if (!"u15pop" %in% names(dist.ind)) {
    stop("Couldn't find district U15 population in dist.ind. Rename to 'u15pop' or provide it via ctry_data$dist.pop.")
  }
  dist.ind$u15pop <- suppressWarnings(as.numeric(dist.ind$u15pop))

  # 4) Region metrics (across all countries present)
  dist_100k <- dist.ind |> dplyr::filter(u15pop >= 1e5)

  tot.dist.pop <- dist_100k |>
    dplyr::group_by(year) |>
    dplyr::summarise(tot.dist.pop = sum(u15pop, na.rm = TRUE), .groups = "drop")

  dist.adeq <- dist_100k |>
    dplyr::filter(npafp_rate >= 2, `per.stool.ad` >= 80) |>
    dplyr::group_by(year) |>
    dplyr::summarise(tot.dist.adeq = sum(u15pop, na.rm = TRUE), .groups = "drop")

  meet.ind <- dplyr::left_join(tot.dist.pop, dist.adeq, by = "year") |>
    dplyr::mutate(
      tot.dist.adeq  = tidyr::replace_na(.data$tot.dist.adeq, 0),
      prop.dist.adeq = 100 * .data$tot.dist.adeq / dplyr::if_else(.data$tot.dist.pop > 0, .data$tot.dist.pop, NA_real_)
    )

  num100k <- dist_100k |> dplyr::distinct(year, adm2guid) |> dplyr::count(year, name = "dist.100k.num")
  adeq100k <- dist_100k |>
    dplyr::filter(npafp_rate >= 2, `per.stool.ad` >= 80) |>
    dplyr::distinct(year, adm2guid) |>
    dplyr::count(year, name = "ad.dist.100k.num")
  adeq.dists <- dplyr::left_join(num100k, adeq100k, by = "year") |>
    dplyr::mutate(dplyr::across(dplyr::ends_with("num"), ~ tidyr::replace_na(.x, 0)),
                  prop = paste0(ad.dist.100k.num, "/", dist.100k.num))

  # 5) Country indicators \u2192 region summary
  ctry.ind <- dplyr::left_join(ctry.extract, cstool, by = c("year","adm0guid"))
  if (!is.null(start_year)) ctry.ind <- dplyr::filter(ctry.ind, year >= start_year)
  if (!is.null(end_year))   ctry.ind <- dplyr::filter(ctry.ind, year <= end_year)

  if ("ctry" %in% names(afp.cases)) {
    afp.sel <- afp.cases |>
      dplyr::rename(afp.cases = dplyr::any_of(c("afp.cases","afp.case")))
    if (!is.null(start_year)) afp.sel <- dplyr::filter(afp.sel, year >= start_year)
    if (!is.null(end_year))   afp.sel <- dplyr::filter(afp.sel, year <= end_year)
    ctry.ind <- dplyr::left_join(ctry.ind, afp.sel, by = c("ctry","year"))
  } else {
    afp.sel <- afp.cases |>
      dplyr::rename(afp.cases = dplyr::any_of(c("afp.cases","afp.case"))) |>
      dplyr::group_by(year) |>
      dplyr::summarise(afp.cases = sum(afp.cases, na.rm = TRUE), .groups = "drop")
    ctry.ind <- dplyr::left_join(ctry.ind, afp.sel, by = "year")
  }

  reg <- ctry.ind |>
    dplyr::group_by(year) |>
    dplyr::summarise(
      afp.cases      = sum(afp.cases, na.rm = TRUE),
      npafp_rate     = mean(npafp_rate, na.rm = TRUE),
      `per.stool.ad` = mean(`per.stool.ad`, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::left_join(meet.ind,  by = "year") |>
    dplyr::left_join(adeq.dists, by = "year") |>
    dplyr::arrange(year) |>
    dplyr::mutate(
      dplyr::across(dplyr::any_of(c("afp.cases","npafp_rate","per.stool.ad","prop.dist.adeq")),
                    ~ suppressWarnings(as.numeric(.))),
      dplyr::across(dplyr::any_of(c("afp.cases","npafp_rate","per.stool.ad","prop.dist.adeq")),
                    ~ round(., 1))
    ) |>
    dplyr::select(year, afp.cases, npafp_rate, `per.stool.ad`, prop.dist.adeq, prop)

  # ensure year prints as plain text (no thousands separator)
  reg <- reg |> dplyr::mutate(year = as.character(year))

  if (output == "tibble") return(reg)

  flextable::flextable(reg) |>
    flextable::theme_booktabs() |>
    flextable::bold(part = "header") |>
    flextable::colformat_double(
      j = intersect(names(reg), c("afp.cases","npafp_rate","per.stool.ad","prop.dist.adeq")),
      digits = 1, na_str = "---"
    ) |>
    flextable::set_header_labels(
      year = "Year",
      afp.cases = "AFP cases",
      npafp_rate = "NPAFP rate*",
      `per.stool.ad` = "Stool adequacy**",
      prop.dist.adeq = "% Pop in adequate \u2265100k districts",
      prop = "Districts \u2265100k meeting both (met/total)"
    ) |>
    flextable::autofit()
}

