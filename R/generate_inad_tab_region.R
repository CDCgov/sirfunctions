#' Generate a stool adequacy summary at the regional level
#'
#' @description
#' Generates a summary table at the country level highlighting issues around stool adequacy.
#'
#' @inheritParams generate_inad_tab
#'
#' @returns `flextable` A summary of yearly stool adequacy at the regional level.
#' @export
#'
#' @examples
#' \dontrun{
#' inad_region <- generate_inad_tab_region(ctry_data$afp.all.2, cstool)
#' }
generate_inad_tab_region <- function(afp_data, cstool, start_date, end_date) {
  start_date <- lubridate::as_date(start_date)
  end_date <- lubridate::as_date(end_date)

  if (!requireNamespace("janitor", quietly = TRUE)) {
    stop('Package "janitor" must be installed to use this function.',
         .call = FALSE
    )
  }

  if (!requireNamespace("tibble", quietly = TRUE)) {
    stop('Package "tibble" must be installed to use this function.',
         .call = FALSE
    )
  }

  if (!requireNamespace("flextable", quietly = TRUE)) {
    stop('Package "flextable" must be installed to use this function.',
         .call = FALSE
    )
  }

  # All AFP cases
  afps.all <- afp_data %>%
    dplyr::filter(
      dplyr::between(date, start_date, end_date),
      cdc.classification.all2 != "NOT-AFP"
    ) |>
    dplyr::group_by(year) |>
    dplyr::summarise(
      good.cond.1 = sum(
        (ontostool1 <= 14 & (stool.1.condition == "Good" | is.na(stool.1.condition))) |
          (ontostool2 <= 14 & (stool.2.condition == "Good" | is.na(stool.2.condition))),
        na.rm = T
      ),
      good.cond.2 = sum(stool1missing == 0 &
                          stool2missing == 0 &
                          ontostool1 <= 21 &
                          ontostool2 <= 21 &
                          (stool.1.condition == "Good" | is.na(stool.1.condition)) &
                          (stool.2.condition == "Good" | is.na(stool.2.condition)), na.rm = T),
      afp.cases = n()
    ) |>
    dplyr::mutate(
      good.cond.1per = round(good.cond.1 / afp.cases * 100, 0),
      good.cond.2per = round(good.cond.2 / afp.cases * 100, 0)
    ) |>
    dplyr::mutate(
      good.cond.1per = paste0(
        good.cond.1per,
        "% (", good.cond.1, "/", afp.cases, " cases)"
      ),
      good.cond.2per = paste0(
        good.cond.2per,
        "% (", good.cond.2, "/", afp.cases, " cases)"
      )
    )

  # Join with cstool
  cstool_year <- cstool |>
    dplyr::group_by(year) |>
    dplyr::summarize(dplyr::across(dplyr::all_of(c(9:22)), \(x) sum(x, na.rm = TRUE))) |>
    dplyr::mutate(per.stool.ad = num.adequate / adequacy.denominator * 100)
  allinadstool <- dplyr::left_join(cstool_year, afps.all) |>
    mutate(per.stool.ad = round(per.stool.ad, 0))

  # Create additional columns
  allinadstool <- allinadstool |>
    dplyr::mutate(
      timelyper = round(late.collection / num.inadequate * 100, 0),
      missingper = round(one.or.no.stool / num.inadequate * 100, 0),
      poorper = round(bad.condition / num.inadequate * 100, 0),
      badper = round(bad.data / num.inadequate * 100, 0)
    ) |>
    dplyr::mutate(
      timelyper = paste0(late.collection, " (", timelyper, "%)"),
      missingper = paste0(one.or.no.stool, " (", missingper, "%)"),
      poorper = paste0(bad.condition, " (", poorper, "%)"),
      badper = paste0(bad.data, " (", badper, "%)")
    )

  inad.tab <- allinadstool |>
    dplyr::select(-dplyr::any_of(c("weight",
                                   "days_in_year", "days.at.risk",
                                   "adm0guid", "earliest_date", "latest_date",
                                   "datasource", "ctry", "u15pop"
    ))) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), \(x) as.character(x))) |>
    tidyr::pivot_longer(
      cols = c("afp.cases":"badper"),
      names_to = "type"
    ) |>
    tidyr::pivot_wider(names_from = "year", values_from = "value") |>
    dplyr::filter(
      type %in% c(
        "num.adequate",
        "num.inadequate",
        "per.stool.ad",
        "timelyper",
        "missingper",
        "poorper",
        "badper",
        "good.cond.1per",
        "good.cond.2per"
      )
    ) %>%
    dplyr::mutate(
      type = dplyr::case_when(
        type == "num.adequate" ~ "Cases with adequate stools",
        type == "num.inadequate" ~ "Cases with inadequate stools",
        type == "per.stool.ad" ~ "Stool adequacy*",
        type == "afp.cases" ~ "",
        type == "timelyper" ~ "Late collection (%)",
        type == "missingper" ~ "No Stool/one stool",
        type == "poorper" ~ "Poor condition",
        type == "badper" ~ "Bad dates",
        type == "good.cond.1per" ~ "1 stool within 14 days of onset (+ condition)",
        type == "good.cond.2per" ~ "2 stools within 21 days of onset (+ condition)",
        FALSE ~ type
      )
    )

  inad.tab <- inad.tab[c(3, 1, 2, 6, 7, 8, 9, 4, 5), ] # Reorder the table to be in the correct order

  inad.tab$sub <- c(
    "",
    "",
    "",
    "Among Inadequate Cases",
    "Among Inadequate Cases",
    "Among Inadequate Cases",
    "Among Inadequate Cases",
    "Among All Cases",
    "Among All Cases"
  )

  inad.tab.flex.a <- flextable::as_grouped_data(inad.tab, groups = c("sub"))
  inad.tab.flex <- flextable::flextable(inad.tab.flex.a) |>
    flextable::theme_booktabs() |>
    flextable::bold(bold = TRUE, part = "header") |>
    flextable::set_header_labels(type = "", sub = "") |>
    flextable::add_footer_row(
      top = F,
      "*Stool adequacy defined as per Certification Indicator, i.e., 2 stools collected at least 24h apart AND <=14d of onset AND received in good condition at a WHO-accredited laboratory (missing condition assumed good)",
      colwidths = ncol(inad.tab)
    ) %>%
    flextable::autofit()

  return(inad.tab.flex)
}
