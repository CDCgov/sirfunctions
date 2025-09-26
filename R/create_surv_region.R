generate_surv_reg_tab <- function(
    ctry_data,
    ctry.extract,
    dist.extract,
    cstool,
    dstool,
    afp.case,
    countries = NULL,
    region_label = "Region",
    start_year = NULL,
    end_year   = NULL
) {

  for (pkg in c("dplyr","tidyr","stringr","tibble","janitor","flextable","rlang")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(sprintf('Package "%s" must be installed.', pkg), call. = FALSE)
    }
  }

  `%||%` <- function(a, b) if (is.null(a)) b else a
  norm <- function(x) stringr::str_trim(stringr::str_to_upper(as.character(x)))
  ensure_ctry <- function(df, df_name) {
    if (!"ctry" %in% names(df)) {
      if ("adm0guid" %in% names(df) && "adm0guid" %in% names(ctry.extract) && "ctry" %in% names(ctry.extract)) {
        keymap <- dplyr::distinct(ctry.extract, .data$adm0guid, ctry = .data$ctry)
        df <- dplyr::left_join(df, keymap, by = "adm0guid")
      }
    }
    if (!"ctry" %in% names(df)) {
      rlang::abort(paste0("'", df_name, "' needs a 'ctry' column or an 'adm0guid' mappable to 'ctry'."))
    }
    df
  }
  std_ind_cols <- function(df, level = c("country","district")) {
    level <- match.arg(level)
    nms <- names(df)
    pick <- function(patterns) {
      hit <- unique(unlist(lapply(patterns, function(p) grep(p, nms, ignore.case = TRUE, value = TRUE))))
      if (length(hit)) hit[1] else NA_character_
    }
    npafp_col <- pick(c("^npafp[_\\. ]?rate$", "^npa[_\\. ]?rate$", "npafp"))
    stool_col <- pick(c("^per[_\\. ]?stool[_\\. ]?ad$", "^stool[_\\. ]?ad", "adequacy"))
    u15_col   <- pick(c("^u15[_\\. ]?pop(ulation)?$", "^pop[_\\. ]?u15$", "^under[_ ]?15(_pop| population)?$"))

    if (!is.na(npafp_col) && npafp_col != "npafp_rate") df <- dplyr::rename(df, npafp_rate = !!rlang::sym(npafp_col))
    if (!is.na(stool_col) && stool_col != "per.stool.ad") df <- dplyr::rename(df, `per.stool.ad` = !!rlang::sym(stool_col))
    if (level == "country" && !is.na(u15_col) && u15_col != "u15pop") df <- dplyr::rename(df, u15pop = !!rlang::sym(u15_col))
    if (level == "district" && !is.na(u15_col) && u15_col != "u15pop") df <- dplyr::rename(df, u15pop = !!rlang::sym(u15_col))

    if ("npafp_rate" %in% names(df))    df$npafp_rate     <- suppressWarnings(as.numeric(df$npafp_rate))
    if ("per.stool.ad" %in% names(df))  df$`per.stool.ad` <- suppressWarnings(as.numeric(df$`per.stool.ad`))
    if ("u15pop" %in% names(df))        df$u15pop         <- suppressWarnings(as.numeric(df$u15pop))
    df
  }

  ctry.extract <- ensure_ctry(ctry.extract, "ctry.extract")
  dist.extract <- ensure_ctry(dist.extract, "dist.extract")
  dstool       <- ensure_ctry(dstool,       "dstool")
  cstool       <- ensure_ctry(cstool,       "cstool")

  dist.extract <- std_ind_cols(dist.extract, level = "district") # in case indicators live here
  dstool       <- std_ind_cols(dstool,       level = "district")
  cstool       <- std_ind_cols(cstool,       level = "country")

  if (is.null(countries) || !length(countries)) {
    src <- if (is.data.frame(ctry_data)) ctry_data else ctry_data$dist.pop
    if (is.null(src) || !"ctry" %in% names(src)) {
      rlang::abort("Provide `countries` or ensure `ctry_data` (or ctry_data$dist.pop) contains a 'ctry' column.")
    }
    countries <- src |> dplyr::distinct(.data$ctry) |> dplyr::pull(.data$ctry)
  }
  countries <- norm(countries)
  stopifnot(is.character(countries), length(countries) > 0)

  filt <- function(df) dplyr::filter(df, norm(.data$ctry) %in% countries)
  ctry.extract <- filt(ctry.extract)
  dist.extract <- filt(dist.extract)
  dstool       <- filt(dstool)
  cstool       <- filt(cstool)

  if ("ctry" %in% names(afp.case)) {
    afp.case <- afp.case |>
      dplyr::rename(afp.cases = dplyr::any_of(c("afp.cases","afp.case"))) |>
      dplyr::mutate(ctry = norm(.data$ctry)) |>
      filt()
  } else {
    region_afp <- afp.case |>
      dplyr::rename(afp.cases = dplyr::any_of(c("afp.cases","afp.case"))) |>
      dplyr::group_by(.data$year) |>
      dplyr::summarise(afp.cases = sum(.data$afp.cases, na.rm = TRUE), .groups = "drop")
    afp.case <- ctry.extract |> dplyr::distinct(.data$ctry, .data$year) |> dplyr::mutate(afp.cases = NA_real_)
  }

  if (!is.null(start_year)) {
    ctry.extract <- dplyr::filter(ctry.extract, .data$year >= start_year)
    dist.extract <- dplyr::filter(dist.extract, .data$year >= start_year)
    dstool       <- dplyr::filter(dstool,       .data$year >= start_year)
    cstool       <- dplyr::filter(cstool,       .data$year >= start_year)
    afp.case     <- dplyr::filter(afp.case,     .data$year >= start_year)
    if (exists("region_afp", inherits = TRUE)) region_afp <- dplyr::filter(region_afp, .data$year >= start_year)
  }
  if (!is.null(end_year)) {
    ctry.extract <- dplyr::filter(ctry.extract, .data$year <= end_year)
    dist.extract <- dplyr::filter(dist.extract, .data$year <= end_year)
    dstool       <- dplyr::filter(dstool,       .data$year <= end_year)
    cstool       <- dplyr::filter(cstool,       .data$year <= end_year)
    afp.case     <- dplyr::filter(afp.case,     .data$year <= end_year)
    if (exists("region_afp", inherits = TRUE)) region_afp <- dplyr::filter(region_afp, .data$year <= end_year)
  }

  if (!all(c("year","adm2guid","u15pop") %in% names(dist.extract)))
    rlang::abort("dist.extract must include: 'year', 'adm2guid', 'u15pop'.")
  if (!all(c("ctry","year") %in% names(ctry.extract)))
    rlang::abort("ctry.extract must include: 'ctry','year'.")
  if (!all(c("ctry","year") %in% names(cstool)))
    rlang::abort("cstool must include: 'ctry','year'.")
  if (!all(c("ctry","year","afp.cases") %in% names(afp.case)))
    rlang::abort("afp.case (working copy) must include: 'ctry','year','afp.cases'.")

  u15_aliases <- c("u15pop","u15_pop","U15Pop","u_15_pop","pop_u15","under15_pop","under_15_pop","u15Population")
  dstool_sel <- dstool %>%
    dplyr::select(.data$adm2guid, .data$year, dplyr::everything()) %>%
    dplyr::select(-dplyr::any_of(intersect(u15_aliases, names(dstool))))

  dist.ind.afp <- dplyr::left_join(dist.extract, dstool_sel, by = c("adm2guid","year"))

  if (!"u15pop" %in% names(dist.ind.afp)) {
    u15_cands <- names(dist.ind.afp)[grepl("^u15pop(\\.x|\\.y)?$", names(dist.ind.afp), ignore.case = TRUE)]
    if (length(u15_cands)) {
      dist.ind.afp <- dplyr::mutate(dist.ind.afp, u15pop = dplyr::coalesce(!!!rlang::syms(u15_cands)))
    } else {
      rlang::abort(paste0("Couldn't find u15pop after join. Columns: ", paste(names(dist.ind.afp), collapse = ", ")))
    }
  }

  pick1 <- function(nms, patterns) {
    hits <- unique(unlist(lapply(patterns, function(p) grep(p, nms, ignore.case = TRUE, value = TRUE))))
    if (length(hits)) hits[1] else NA_character_
  }
  nm <- names(dist.ind.afp)
  np_col <- pick1(nm, c("^npafp[_\\. ]?rate$", "^npa[_\\. ]?rate$", "npafp"))
  st_col <- pick1(nm, c("^per[_\\. ]?stool[_\\. ]?ad$", "^stool[_\\. ]?ad", "adequacy"))
  if (is.na(np_col)) rlang::abort("No district NPAFP rate column found after join.")
  if (is.na(st_col)) rlang::abort("No district stool adequacy column found after join.")
  if (np_col != "npafp_rate")    dist.ind.afp <- dplyr::rename(dist.ind.afp, npafp_rate = !!rlang::sym(np_col))
  if (st_col != "per.stool.ad")  dist.ind.afp <- dplyr::rename(dist.ind.afp, `per.stool.ad` = !!rlang::sym(st_col))

  suppressWarnings({
    dist.ind.afp$u15pop         <- as.numeric(dist.ind.afp$u15pop)
    dist.ind.afp$npafp_rate     <- as.numeric(dist.ind.afp$npafp_rate)
    dist.ind.afp$`per.stool.ad` <- as.numeric(dist.ind.afp$`per.stool.ad`)
  })

  dist_100k <- dplyr::filter(dist.ind.afp, .data$u15pop >= 1e5)

  tot.dist.pop <- dist_100k |>
    dplyr::group_by(.data$year) |>
    dplyr::summarise(tot.dist.pop = sum(.data$u15pop, na.rm = TRUE), .groups = "drop")

  dist.adeq.ind <- dist_100k |>
    dplyr::filter(.data$npafp_rate >= 2, .data$`per.stool.ad` >= 80) |>
    dplyr::group_by(.data$year) |>
    dplyr::summarise(tot.dist.adeq = sum(.data$u15pop, na.rm = TRUE), .groups = "drop")

  meet.ind <- dplyr::left_join(tot.dist.pop, dist.adeq.ind, by = "year") |>
    dplyr::mutate(
      tot.dist.adeq = tidyr::replace_na(.data$tot.dist.adeq, 0),
      prop.dist.adeq = 100 * .data$tot.dist.adeq /
        dplyr::if_else(.data$tot.dist.pop > 0, .data$tot.dist.pop, NA_real_)
    )

  num.dists.100k <- dist_100k |>
    dplyr::distinct(.data$year, .data$adm2guid) |>
    dplyr::count(.data$year, name = "dist.100k.num")

  ad.dists.100k <- dist_100k |>
    dplyr::filter(.data$npafp_rate >= 2, .data$`per.stool.ad` >= 80) |>
    dplyr::distinct(.data$year, .data$adm2guid) |>
    dplyr::count(.data$year, name = "ad.dist.100k.num")

  adeq.dists <- dplyr::full_join(num.dists.100k, ad.dists.100k, by = "year") |>
    dplyr::mutate(
      dplyr::across(dplyr::ends_with("num"), ~ tidyr::replace_na(.x, 0)),
      prop = paste0(.data$ad.dist.100k.num, "/", .data$dist.100k.num)
    )

  ctry_keys  <- ctry.extract |> dplyr::distinct(.data$ctry, .data$year)
  cstool_sel <- cstool |> dplyr::select(.data$ctry, .data$year,
                                        npafp_rate = dplyr::any_of("npafp_rate"),
                                        `per.stool.ad` = dplyr::any_of("per.stool.ad"),
                                        u15pop = dplyr::any_of("u15pop"))

  ctry.ind <- ctry_keys |>
    dplyr::left_join(cstool_sel, by = c("ctry","year")) |>
    dplyr::left_join(afp.case,   by = c("ctry","year"))

  u15_country_col <- intersect(c("u15pop","u15_pop","u15_population"), names(ctry.ind))
  wcol <- if (length(u15_country_col)) u15_country_col[1] else NULL
  wmean <- function(x, w = NULL) {
    if (is.null(w)) return(mean(x, na.rm = TRUE))
    if (length(x) != length(w)) return(mean(x, na.rm = TRUE))
    if (all(is.na(x))) return(NA_real_)
    sum(x * w, na.rm = TRUE) / sum(w[!is.na(x)], na.rm = TRUE)
  }

  region.ind <- ctry.ind |>
    dplyr::group_by(.data$year) |>
    dplyr::summarise(
      afp.cases      = { if (exists("region_afp", inherits = TRUE)) NA_real_ else sum(.data$afp.cases %||% 0, na.rm = TRUE) },
      npafp_rate     = wmean(.data$npafp_rate, if (is.null(wcol)) NULL else .data[[wcol]]),
      `per.stool.ad` = wmean(.data$`per.stool.ad`, if (is.null(wcol)) NULL else .data[[wcol]]),
      .groups = "drop"
    ) |>
    dplyr::left_join(dplyr::select(meet.ind, .data$year, .data$prop.dist.adeq), by = "year") |>
    dplyr::left_join(adeq.dists, by = "year")

  if (exists("region_afp", inherits = TRUE)) {
    region.ind <- region.ind |>
      dplyr::select(-.data$afp.cases) |>
      dplyr::left_join(region_afp, by = "year")
  }

  region.ind <- region.ind |>
    dplyr::arrange(.data$year) |>
    dplyr::mutate(
      dplyr::across(c(.data$afp.cases, .data$npafp_rate, .data$`per.stool.ad`, .data$prop.dist.adeq),
                    ~ suppressWarnings(as.numeric(.))),
      dplyr::across(c(.data$afp.cases, .data$npafp_rate, .data$`per.stool.ad`, .data$prop.dist.adeq),
                    ~ round(., 1))
    )

  mat <- as.data.frame(t(region.ind)) |>
    janitor::row_to_names(row_number = 1) |>
    tibble::rownames_to_column("type") |>
    dplyr::filter(.data$type %in% c("afp.case","npafp_rate","per.stool.ad","prop.dist.adeq","prop")) |>
    dplyr::mutate(
      type = dplyr::case_when(
        .data$type == "npafp_rate"     ~ "NPAFP rate*",
        .data$type == "afp.cases"      ~ "AFP cases",
        .data$type == "per.stool.ad"   ~ "Stool adequacy**",
        .data$type == "prop.dist.adeq" ~ "% Population living in districts ≥100,000 U15 that met both indicators",
        .data$type == "prop"           ~ "Districts ≥100,000 U15 that met both indicators",
        TRUE ~ .data$type
      )
    )
  mat <- mat[c(2,1,3,4,5), , drop = FALSE]

  ft <- flextable::flextable(mat) |>
    flextable::theme_booktabs() |>
    flextable::bold(part = "header") |>
    flextable::set_header_labels(type = region_label) |>
    flextable::colformat_double(j = 2:ncol(mat), digits = 1, na_str = "---") |>
    flextable::add_footer_row(
      top = FALSE,
      values = paste0(
        "* If country U15 population was available, regional NPAFP rate and stool adequacy use U15-weighted means; ",
        "otherwise simple means are shown.\n",
        "** Stool adequacy defined per Certification Indicator: two stools ≥24h apart, ≤14 days of onset, ",
        "and received in good condition at a WHO-accredited laboratory (missing condition assumed good)."
      ),
      colwidths = ncol(mat)
    ) |>
    flextable::autofit()

  return(ft)
}
