# PROV-level AFP desk-review outputs ---------------------------------------
#
# These functions mirror the national desk-review outputs while consistently
# restricting data and geometry to one PROV.  Figures are returned as ggplot
# objects.  They are saved only when `output_path` is supplied explicitly.

.dr_prov_slug <- function(prov_name) {
  slug <- tolower(trimws(prov_name))
  slug <- gsub("[^a-z0-9]+", "-", slug)
  gsub("(^-+|-+$)", "", slug)
}

.dr_prov_save <- function(plot, filename, output_path, width, height) {
  if (!is.null(output_path) && nzchar(output_path)) {
    ggplot2::ggsave(
      filename = filename,
      plot = plot,
      path = output_path,
      width = width,
      height = height
    )
  }
  invisible(plot)
}

.dr_prov_empty_plot <- function(title, message = "No records available") {
  ggplot2::ggplot() +
    ggplot2::annotate("text", x = 0, y = 0, label = message, size = 5) +
    ggplot2::xlim(-1, 1) +
    ggplot2::ylim(-1, 1) +
    ggplot2::labs(title = title) +
    ggplot2::theme_void()
}

.dr_normalize_admin_name <- function(x) {
  x <- iconv(as.character(x), to = "ASCII//TRANSLIT")
  x <- tolower(trimws(x))
  x <- gsub("[^a-z0-9]+", " ", x)
  x <- gsub("\\bprov\\s*$", "", x)
  trimws(gsub("\\s+", " ", x))
}

.dr_filter_prov <- function(data, prov_name,
                             columns = c("ADM1_NAME", "prov")) {
  if (is.null(data)) {
    return(data)
  }

  prov_col <- columns[columns %in% names(data)][1]
  if (is.na(prov_col)) {
    cli::cli_abort(paste0(
      "Could not find a prov column. Expected one of: ",
      paste(columns, collapse = ", "), "."
    ))
  }

  values <- .dr_normalize_admin_name(data[[prov_col]])
  requested_prov <- .dr_normalize_admin_name(prov_name)
  keep <- !is.na(values) & values == requested_prov
  data[keep, , drop = FALSE]
}

.dr_prov_shape_years <- function(shape, prov_name, start_date, end_date) {
  if (is.null(shape) || nrow(shape) == 0) {
    cli::cli_abort(paste0(
      "The map geometry has zero rows before prov filtering. ",
      "Check the `ADM0_NAME` country filter used to create the shape object."
    ))
  }

  prov_col <- c("ADM1_NAME", "prov")[
    c("ADM1_NAME", "prov") %in% names(shape)
  ][1]
  available_geometry_prov_names <- if (!is.na(prov_col)) {
    sort(unique(as.character(shape[[prov_col]])))
  } else {
    character()
  }

  shape <- .dr_filter_prov(shape, prov_name)


  if (nrow(shape) == 0) {
    preview <- paste(utils::head(available_geometry_prov_names, 20), collapse = ", ")
    cli::cli_abort(paste0(
      "No map geometry found for prov: ", prov_name, ". ",
      "Available geometry names include: ", preview, "."
    ))
  }

  if ("active.year.01" %in% names(shape)) {
    shape <- shape |>
      dplyr::filter(dplyr::between(
        active.year.01,
        lubridate::year(start_date),
        lubridate::year(end_date)
      )) |>
      dplyr::mutate(year = active.year.01)
  } else if (!"year" %in% names(shape)) {
    cli::cli_abort("Map geometry must contain `active.year.01` or `year`.")
  }

  shape
}

#' List available prov_names in country data
#'
#' Uses `ctry.data$prov$ADM1_NAME` as the preferred source, with the province
#' population and AFP data used as fallbacks for older country-data objects.
#'
#' @param ctry.data Country data returned by `init_dr()`.
#' @returns A sorted character vector of prov names.
list_desk_review_prov <- function(ctry.data) {
  candidates <- list(
    if (!is.null(ctry.data$prov)) ctry.data$prov else NULL,
    if (!is.null(ctry.data$prov.pop)) ctry.data$prov.pop else NULL,
    if (!is.null(ctry.data$afp.all.2)) ctry.data$afp.all.2 else NULL
  )

  for (candidate in candidates) {
    if (is.null(candidate)) next
    prov_col <- c("ADM1_NAME", "prov")[c("ADM1_NAME", "prov") %in% names(candidate)][1]
    if (!is.na(prov_col)) {
      prov_names <- sort(unique(trimws(as.character(candidate[[prov_col]]))))
      return(prov_names[!is.na(prov_names) & nzchar(prov_names)])
    }
  }

  cli::cli_abort(
    "No prov names found in `ctry.data$prov`, `ctry.data$prov.pop`, or `ctry.data$afp.all.2`."
  )
}

#' PROV DIST under-15 population, roads, and labels map
#'
#' This is the prov-level counterpart of `generate_pop_map()` and
#' `generate_dist_pop_map()`. Existing DIST under-15 population estimates are
#' joined to DIST geometry; missing population is displayed rather than imputed.
#'
#' @param ctry.data Country data returned by `init_dr()`.
#' @param prov_name PROV name.
#' @param prov.shape,dist.shape Long-format PROV and DIST geometry.
#' @param end_date Date determining the map and population year.
#' @param output_path Optional directory for the PNG file. `NULL` does not save.
#' @param include_cities Whether to add available population-centre points.
#' @param label_size DIST label size.
#' @param repel_labels Whether to repel DIST labels and draw leader lines.
#' @param road_color,road_linewidth Road color and line width.
#' @param dist_line_color,dist_linewidth DIST boundary color and line width.
#' @param caption_size Caption text size.
#' @returns A ggplot object.
#' @export
generate_prov_population_roads_map <- function(
    ctry.data, prov_name, prov.shape, dist.shape, end_date,
    output_path = NULL, include_cities = FALSE, label_size = 3,
    repel_labels = TRUE, road_color = "#2166AC", road_linewidth = 0.7,
    dist_line_color = "grey55", dist_linewidth = 0.25,
    caption_size = 9) {
  end_date <- lubridate::as_date(end_date)
  target_year <- lubridate::year(end_date)


  prov_boundary <- .dr_filter_prov(prov.shape, prov_name)

  prov_dists <- .dr_filter_prov(dist.shape, prov_name)
  if (nrow(prov_boundary) == 0 || nrow(prov_dists) == 0) {
    cli::cli_abort(paste0(
      "PROV geometry was not found for: ", prov_name, "."
    ))
  }

  shape_year_column <- function(shape) {
    candidates <- c("active.year.01", "year")
    candidates[candidates %in% names(shape)][1]
  }
  select_map_year <- function(shape, geography) {
    year_column <- shape_year_column(shape)
    if (is.na(year_column)) {
      cli::cli_abort(paste0(
        geography, " geometry must contain `active.year.01` or `year`."
      ))
    }
    available_years <- sort(unique(as.integer(shape[[year_column]])))
    available_years <- available_years[!is.na(available_years)]
    if (length(available_years) == 0) {
      cli::cli_abort(paste0(
        geography, " geometry has no usable map years for ", prov_name, "."
      ))
    }
    map_year <- if (target_year %in% available_years) {
      target_year
    } else {
      prior_years <- available_years[available_years <= target_year]
      if (length(prior_years) == 0) max(available_years) else max(prior_years)
    }
    if (map_year != target_year) {
      cli::cli_alert_warning(paste0(
        geography, " geometry for ", target_year,
        " was unavailable; using ", map_year, "."
      ))
    }
    shape |>
      dplyr::filter(.data[[year_column]] == map_year) |>
      dplyr::mutate(year = target_year)
  }

  prov_boundary <- select_map_year(prov_boundary, "PROV")
  prov_dists <- select_map_year(prov_dists, "DIST")

  dist_name_column <- c("ADM2_NAME", "dist")[
    c("ADM2_NAME", "dist") %in% names(prov_dists)
  ][1]
  if (is.na(dist_name_column)) {
    cli::cli_abort("DIST geometry must contain `ADM2_NAME` or `dist`.")
  }
  prov_dists$.dist_name <- as.character(prov_dists[[dist_name_column]])

  required_population_columns <- c("adm2guid", "year", "u15pop")
  if (is.null(ctry.data$dist.pop) ||
      !all(required_population_columns %in% names(ctry.data$dist.pop))) {
    cli::cli_abort(paste0(
      "`ctry.data$dist.pop` must contain: ",
      paste(required_population_columns, collapse = ", "), "."
    ))
  }
  prov_population <- .dr_filter_prov(ctry.data$dist.pop, prov_name) |>
    dplyr::filter(year == target_year) |>
    dplyr::mutate(u15pop = suppressWarnings(as.numeric(u15pop))) |>
    dplyr::group_by(adm2guid, year) |>
    dplyr::summarise(
      u15pop = if (all(is.na(u15pop))) NA_real_ else max(u15pop, na.rm = TRUE),
      .groups = "drop"
    )

  prov_dists <- dplyr::left_join(
    dplyr::select(prov_dists, -dplyr::any_of("u15pop")),
    prov_population,
    by = c("GUID" = "adm2guid", "year" = "year")
  )
  label_points <- suppressWarnings(sf::st_point_on_surface(prov_dists))
  # Geometry columns downloaded by different spatial helpers may be named
  # `Shape`, `SHAPE`, or `geometry`. Normalize only this derived label layer so

  # ggrepel's sf-coordinate statistic always receives `geometry`.
  label_points <- sf::st_sf(

    sf::st_drop_geometry(label_points),
    geometry = sf::st_geometry(label_points),
    crs = sf::st_crs(label_points)
  )

  clip_to_prov <- function(layer, layer_name) {
    if (is.null(layer) || !inherits(layer, "sf") || nrow(layer) == 0) {
      return(NULL)
    }
    tryCatch(
      {
        layer <- sf::st_transform(layer, sf::st_crs(prov_boundary))
        boundary <- sf::st_union(sf::st_make_valid(prov_boundary))
        layer <- suppressWarnings(sf::st_crop(layer, sf::st_bbox(boundary)))
        suppressWarnings(sf::st_intersection(layer, boundary))
      },
      error = function(error) {
        cli::cli_alert_warning(paste0(
          layer_name, " could not be clipped for ", prov_name,
          " and will be omitted: ", conditionMessage(error)
        ))
        NULL
      }
    )
  }

  prov_roads <- clip_to_prov(ctry.data$roads, "Roads")
  prov_cities <- if (isTRUE(include_cities)) {
    clip_to_prov(ctry.data$cities, "Cities")
  } else {
    NULL
  }

  plot <- ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = prov_dists,
      ggplot2::aes(fill = u15pop),
      color = dist_line_color, linewidth = dist_linewidth
    )
  if (!is.null(prov_roads) && nrow(prov_roads) > 0) {
    plot <- plot + ggplot2::geom_sf(
      data = prov_roads, color = road_color, linewidth = road_linewidth,
      inherit.aes = FALSE
    )
  }
  if (!is.null(prov_cities) && nrow(prov_cities) > 0) {
    plot <- plot + ggplot2::geom_sf(
      data = prov_cities, color = "#00876C", size = 2,
      inherit.aes = FALSE
    )
  }
  plot <- plot +
    ggplot2::geom_sf(
      data = prov_boundary, fill = NA, color = "black", linewidth = 1,
      inherit.aes = FALSE
    )
  if (isTRUE(repel_labels)) {
    if (!requireNamespace("ggrepel", quietly = TRUE)) {
      stop(
        'Package "ggrepel" must be installed to repel DIST labels.',
        call. = FALSE
      )
    }
    plot <- plot + ggrepel::geom_label_repel(
      data = label_points,
      ggplot2::aes(label = .dist_name, geometry = geometry),
      stat = "sf_coordinates",
      size = label_size,
      seed = 2026,
      force = 3,
      force_pull = 0.5,
      box.padding = 0.35,
      point.padding = 0.1,
      min.segment.length = 0,
      max.overlaps = Inf,
      max.time = 3,
      max.iter = 20000,

      segment.color = "grey35",
      segment.size = 0.3,
      fill = scales::alpha("white", 0.82),

      label.size = 0.15,
      inherit.aes = FALSE
    )
  } else {
    plot <- plot + ggplot2::geom_sf_text(
      data = label_points,
      ggplot2::aes(label = .dist_name),
      size = label_size, check_overlap = FALSE,
      inherit.aes = FALSE
    )
  }
  plot <- plot +
    ggplot2::scale_fill_distiller(
      name = "Under-15 pop", palette = "YlOrRd", direction = 1,
      labels = scales::comma, na.value = "grey80"
    ) +
    ggplot2::labs(
      title = paste0(
        prov_name, " DIST Under-15 Population and Roads - ", target_year
      ),
      caption = paste0(
        "Under-15 population is shown with yellow-to-red fill; grey fill means missing population.\n",
        "DIST boundaries are thin grey lines; major roads are thicker blue lines; ",
        "the prov boundary is black.\n",
        if (isTRUE(repel_labels)) {
          "White label boxes name DISTs; grey leader lines point to small DISTs."
        } else {
          "Text labels name DISTs."
        },
        if (isTRUE(include_cities)) " Population centres are green." else ""
      )
    ) +
    sirfunctions::f.plot.looks("epicurve") +
    ggplot2::coord_sf(datum = NA, clip = "off") +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      legend.position = "right",
      plot.title = ggplot2::element_text(
        size = 15, face = "bold", hjust = 0.5
      ),
      plot.caption = ggplot2::element_text(hjust = 0, size = caption_size),
      plot.margin = ggplot2::margin(8, 28, 8, 28)
    )

  .dr_prov_save(
    plot,
    paste0(.dr_prov_slug(prov_name), "-dist-population-roads-map.png"),
    output_path, 10, 8
  )
  plot
}

#' Generate DIST population and roads maps for multiple prov_names
#'
#' @inheritParams generate_prov_population_roads_map
#' @param prov_names Character vector of PROV names. Defaults to all PROVs
#'   found in `ctry.data`.
#' @returns A named list of ggplot objects.
#' @export
generate_prov_population_roads_maps <- function(
    ctry.data, prov.shape, dist.shape, end_date,
    prov_names = list_desk_review_prov(ctry.data),
    output_path = NULL, include_cities = FALSE, label_size = 3,
    repel_labels = TRUE, road_color = "#2166AC", road_linewidth = 0.7,
    dist_line_color = "grey55", dist_linewidth = 0.25,
    caption_size = 9) {
  if (length(prov_names) == 0) {
    cli::cli_abort("At least one prov must be supplied.")
  }
  plots <- lapply(prov_names, function(prov_name) {
    generate_prov_population_roads_map(
      ctry.data = ctry.data,
      prov_name = prov_name,
      prov.shape = prov.shape,
      dist.shape = dist.shape,

      end_date = end_date,
      output_path = output_path,
      include_cities = include_cities,
      label_size = label_size,

      repel_labels = repel_labels,
      road_color = road_color,
      road_linewidth = road_linewidth,
      dist_line_color = dist_line_color,
      dist_linewidth = dist_linewidth,
      caption_size = caption_size
    )
  })
  names(plots) <- prov_names
  plots
}

#' PROV-only paralytic polio and compatible-case map
#'
#' @param ctry.data Country data returned by `init_dr()`.
#' @param prov_name One value from `list_desk_review_prov(ctry.data)`.
#' @param prov.shape PROV geometry in long format.
#' @param dist.shape Optional DIST geometry in long format. When supplied,
#'   district boundaries are drawn inside the selected prov.
#' @param start_date,end_date Analysis dates.
#' @param output_path Optional directory in which to save the PNG. `NULL` does
#'   not write a file.
#' @returns A ggplot object.
generate_prov_afp_case_map <- function(ctry.data, prov_name, prov.shape,
                                        start_date, end_date = lubridate::today(),
                                        output_path = NULL, dist.shape = NULL) {
  start_date <- lubridate::as_date(start_date)
  end_date <- lubridate::as_date(end_date)
  prov_shape <- .dr_prov_shape_years(
    prov.shape, prov_name, start_date, end_date
  )
  prov_districts <- if (!is.null(dist.shape)) {
    .dr_prov_shape_years(dist.shape, prov_name, start_date, end_date)
  } else {
    NULL
  }

  cases <- .dr_filter_prov(ctry.data$afp.all, prov_name)
  onset_col <- c("date.onset", "date")[c("date.onset", "date") %in% names(cases)][1]
  if (is.na(onset_col)) {
    cli::cli_abort("AFP case data must contain `date.onset` or `date`.")
  }

  onset <- lubridate::as_date(cases[[onset_col]])
  cases <- cases[!is.na(onset) & onset >= start_date & onset <= end_date, , drop = FALSE]
  para_colors <- sirfunctions::f.color.schemes("para.case")
  para_colors[c("cVDPV 3", "cVDPV3", "VDPV 3", "VDPV3")] <- c(
    "#08519C", "#08519C", "#00A6A6", "#00A6A6"
  )
  classifications <- as.character(cases$cdc.classification.all2)
  is_coinfection <- stringr::str_count(
    classifications,
    paste(
      "WILD 1", "cVDPV 2", "VDPV 2", "cVDPV 1", "VDPV 1", "cVDPV1",
      "cVDPV2", "VDPV1", "VDPV2", "cVDPV 3", "VDPV 3",
      "cVDPV3", "VDPV3", "Wild1", sep = "|"
    )
  ) >= 2
  cases <- cases[classifications %in% names(para_colors) | is_coinfection, , drop = FALSE]

  title <- paste("Paralytic Polio and Compatible Cases -", prov_name)
  if (nrow(cases) == 0) {
    plot <- .dr_prov_empty_plot(title)
  } else {
    missing_colors <- setdiff(unique(cases$cdc.classification.all2), names(para_colors))
    para_colors[missing_colors] <- "purple"
    # Keep the facet variable the same type as the map geometry year. Mixing a
    # factor case year with numeric geometry years can produce NA scale IDs in
    # recent ggplot2 versions when rvg builds the plot for PowerPoint.
    cases$year <- lubridate::year(lubridate::as_date(cases[[onset_col]]))

    plot <- ggplot2::ggplot() +
      ggplot2::geom_sf(
        data = prov_shape,
        color = "black", fill = "white", linewidth = 0.6

      )
    if (!is.null(prov_districts)) {
      plot <- plot + ggplot2::geom_sf(
        data = prov_districts,
        color = "grey60", fill = NA, linewidth = 0.25

      )
    }
    plot <- plot +
      ggplot2::geom_sf(
        data = cases,
        ggplot2::aes(color = cdc.classification.all2), size = 1.4
      ) +
      ggplot2::facet_wrap(ggplot2::vars(year)) +
      ggplot2::scale_color_manual(
        values = para_colors, name = "Case type", drop = FALSE
      ) +
      ggplot2::labs(title = title) +
      ggplot2::theme_void() +
      ggplot2::theme(legend.position = "bottom")
  }

  .dr_prov_save(
    plot,
    paste0(.dr_prov_slug(prov_name), "-afp-case-map.png"),
    output_path, 10, 5
  )
  plot
}

#' PROV AFP epicurve
#'
#' @inheritParams generate_prov_afp_case_map
#' @returns A ggplot object with weekly AFP cases faceted by onset year.
generate_prov_afp_epicurve <- function(ctry.data, prov_name, start_date,
                                        end_date = lubridate::today(),
                                        output_path = NULL) {
  start_date <- lubridate::as_date(start_date)
  end_date <- lubridate::as_date(end_date)
  afp <- .dr_filter_prov(ctry.data$afp.all.2, prov_name)
  afp <- afp |>
    dplyr::filter(dplyr::between(date, start_date, end_date)) |>
    dplyr::mutate(
      onset_year = lubridate::epiyear(date),
      epi_week = lubridate::epiweek(date)
    ) |>
    dplyr::count(onset_year, epi_week, cdc.classification.all2,
                 name = "afp_cases")

  title <- paste("AFP Epicurve -", prov_name)
  if (nrow(afp) == 0) {
    plot <- .dr_prov_empty_plot(title)
  } else {
    epi_colors <- sirfunctions::f.color.schemes("epicurve")
    epi_colors[c("cVDPV 3", "cVDPV3", "VDPV 3", "VDPV3")] <- c(
      "#08519C", "#08519C", "#00A6A6", "#00A6A6"
    )
    totals <- afp |>
      dplyr::group_by(onset_year) |>
      dplyr::summarise(total = sum(afp_cases), .groups = "drop") |>
      dplyr::mutate(panel = paste0(onset_year, " (N = ", total, ")"))
    afp <- dplyr::left_join(afp, totals, by = "onset_year")

    plot <- ggplot2::ggplot(
      afp,
      ggplot2::aes(x = epi_week, y = afp_cases,
                   fill = cdc.classification.all2)
    ) +
      ggplot2::geom_col() +
      ggplot2::facet_wrap(ggplot2::vars(panel), ncol = 3) +
      ggplot2::scale_fill_manual(
        values = epi_colors,
        name = "Classification", drop = TRUE
      ) +
      ggplot2::labs(title = title, x = "Epidemiologic week", y = "AFP cases") +
      ggplot2::theme_minimal() +
      ggplot2::theme(legend.position = "bottom")
  }

  .dr_prov_save(

    plot,
    paste0(.dr_prov_slug(prov_name), "-afp-epicurve.png"),
    output_path, 14, 5
  )
  plot
}


.dr_indicator_map <- function(indicator, prov_name, prov.shape, dist.shape,
                              start_date, end_date, value_type,
                              output_path = NULL, caption_size = 3) {
  start_date <- lubridate::as_date(start_date)
  end_date <- lubridate::as_date(end_date)
  prov_boundary <- .dr_prov_shape_years(
    prov.shape, prov_name, start_date, end_date
  )
  prov_districts <- .dr_prov_shape_years(
    dist.shape, prov_name, start_date, end_date
  )
  indicator <- .dr_filter_prov(indicator, prov_name)
  indicator <- indicator |>
    dplyr::filter(dplyr::between(
      year, lubridate::year(start_date), lubridate::year(end_date)
    ), !is.na(dist))

  if (value_type == "npafp") {
    title <- paste("NPAFP Rate Annualized - District -", prov_name)
    indicator$category <- cut(
      indicator$npafp_rate,
      breaks = c(-1, 0, 1, 2, 3, Inf),
      right = FALSE,
      labels = c("Zero NPAFP cases", "<1", "1-<2", "2-<3", "3+")
    )
    indicator <- indicator |>
      dplyr::mutate(
        category = as.character(category),
        category = dplyr::case_when(
          npafp_rate == 0 & u15pop >= 100000 ~ "Silent (u15pop >= 100K)",
          npafp_rate == 0 & u15pop < 100000 & u15pop > 0 ~
            "No cases (u15pop < 100K)",
          npafp_rate == 0 & u15pop == 0 ~ "Missing Pop",
          TRUE ~ category
        ),
        category = factor(
          category,
          levels = c(
            "<1", "1-<2", "2-<3", "3+", "Missing Pop",
            "No cases (u15pop < 100K)", "Silent (u15pop >= 100K)"
          )
        )
      )
    palette <- c(
      "No cases (u15pop < 100K)" = "lightgrey", "<1" = "#dc582a",
      "1-<2" = "#fdae61", "2-<3" = "#a6d96a", "3+" = "#1a9641",
      "Missing Pop" = "#2C83C7", "Silent (u15pop >= 100K)" = "#d7191c"
    )
    legend_title <- "NPAFP rate"
    filename <- paste0(.dr_prov_slug(prov_name), "-npafp-rate-map.png")
  } else {
    title <- paste("Stool Adequacy - District -", prov_name)
    indicator <- indicator |>
      dplyr::mutate(category = dplyr::case_when(
        afp.cases == 0 ~ "Zero AFP cases",
        afp.cases != 0 & per.stool.ad < 40 ~ "<40%",
        afp.cases != 0 & per.stool.ad >= 40 & per.stool.ad < 60 ~ "40-59%",
        afp.cases != 0 & per.stool.ad >= 60 & per.stool.ad < 80 ~ "60-79%",
        afp.cases != 0 & per.stool.ad >= 80 ~ "80%+",
        TRUE ~ NA_character_
      ),
      category = factor(
        category,
        levels = c("Zero AFP cases", "<40%", "40-59%", "60-79%", "80%+")
      ))
    palette <- c(
      "Zero AFP cases" = "lightgrey", "<40%" = "#d7191c",
      "40-59%" = "#fdae61", "60-79%" = "#ffffbf", "80%+" = "#2c7bb6",
      "Unable to Assess" = "white"
    )
    legend_title <- "Stool Adequacy"
    filename <- paste0(.dr_prov_slug(prov_name), "-stool-adequacy-map.png")

  }

  if (nrow(indicator) == 0) {
    plot <- .dr_prov_empty_plot(title)
  } else {
    mapped <- dplyr::left_join(
      prov_districts, indicator,

      by = c("GUID" = "adm2guid", "year" = "year")
    )
    if (value_type == "npafp") {
      annual_labels <- indicator |>
        dplyr::group_by(year, adm2guid, dist) |>
        dplyr::summarise(meets_target = sum(npafp_rate >= 3, na.rm = TRUE),
                         .groups = "drop") |>
        dplyr::group_by(year) |>
        dplyr::summarise(
          number_meeting = sum(meets_target, na.rm = TRUE),
          number_districts = dplyr::n(),
          .groups = "drop"
        ) |>
        dplyr::mutate(label = paste0(
          number_meeting, "/", number_districts, " (",
          round(100 * number_meeting / number_districts, 0), "%)",
          " districts with >= 3 cases of NPAFP \nper 100,000 population"
        ))
    } else {
      annual_labels <- indicator |>
        dplyr::group_by(year, adm2guid, dist) |>
        dplyr::summarise(meets_target = sum(per.stool.ad >= 80, na.rm = TRUE),
                         .groups = "drop") |>
        dplyr::group_by(year) |>
        dplyr::summarise(
          number_meeting = sum(meets_target, na.rm = TRUE),
          number_districts = dplyr::n(),
          .groups = "drop"
        ) |>
        dplyr::mutate(label = paste0(
          number_meeting, "/", number_districts, " (",
          round(100 * number_meeting / number_districts, 0), "%)",
          " districts with >= 80% stool adequacy"
        ))
    }

    prov_coordinates <- as.data.frame(sf::st_coordinates(prov_boundary))
    caption_y_adjustment <-
      (range(prov_coordinates$Y)[1] - range(prov_coordinates$Y)[2]) * 0.1

    plot <- ggplot2::ggplot() +
      ggplot2::geom_sf(
        data = prov_boundary,
        color = "black", fill = NA, size = 1
      ) +
      ggplot2::geom_sf(
        data = prov_boundary,
        color = "black", fill = "lightgrey", size = 0.5
      )
    if (value_type == "stool") {
      plot <- plot + ggplot2::geom_sf(
        data = prov_districts,
        color = "black", fill = "lightgrey", size = 0.5
      )
    }
    plot <- plot +
      ggplot2::geom_sf(
        data = mapped, ggplot2::aes(fill = category),
        color = "black", show.legend = TRUE
      ) +
      ggplot2::geom_text(
        data = annual_labels,
        ggplot2::aes(
          x = min(prov_coordinates$X),
          y = min(prov_coordinates$Y) + caption_y_adjustment,
          label = label
        ),
        size = caption_size,
        check_overlap = TRUE,
        hjust = 0
      ) +
      ggplot2::scale_fill_manual(

        name = legend_title, values = palette, drop = FALSE
      ) +
      ggplot2::ggtitle(title) +
      sirfunctions::f.plot.looks("epicurve") +
      ggplot2::facet_wrap(~year, ncol = 4) +
      ggplot2::theme(
        axis.text.x = ggplot2::element_blank(),
        axis.text.y = ggplot2::element_blank(),

        axis.ticks = ggplot2::element_blank()
      )
  }

  .dr_prov_save(plot, filename, output_path, 14, 8)
  plot
}

#' PROV-only annualized NPAFP rate map by district
#'
#' @param dist.extract District output from `f.npafp.rate.01()`.
#' @param prov_name PROV name.
#' @param prov.shape,dist.shape Long-format PROV and DIST geometry.
#' @param start_date,end_date Analysis dates.
#' @param output_path Optional output directory.
#' @param caption_size Caption text size.
#' @returns A ggplot object.
generate_prov_npafp_map <- function(dist.extract, prov_name, prov.shape,
                                     dist.shape, start_date, end_date,
                                     output_path = NULL, caption_size = 3) {
  .dr_indicator_map(
    dist.extract, prov_name, prov.shape, dist.shape, start_date, end_date,
    "npafp", output_path, caption_size
  )
}

#' PROV-only stool adequacy map by district
#'
#' @param dstool District output from `f.stool.ad.01()`.
#' @inheritParams generate_prov_npafp_map
#' @returns A ggplot object.
generate_prov_stool_adequacy_map <- function(dstool, prov_name, prov.shape,
                                              dist.shape, start_date, end_date,
                                              output_path = NULL,
                                              caption_size = 3) {
  .dr_indicator_map(
    dstool, prov_name, prov.shape, dist.shape, start_date, end_date,
    "stool", output_path, caption_size
  )
}

#' PROV stool adequacy issues table
#'
#' @param ctry.data Country data returned by `init_dr()`.
#' @param pstool Province output from `f.stool.ad.01()`.
#' @param prov_name PROV name.
#' @param start_date,end_date Analysis dates.
#' @returns A flextable.
generate_prov_stool_adequacy_table <- function(ctry.data, pstool, prov_name,
                                                start_date, end_date) {
  prov_afp <- .dr_filter_prov(ctry.data$afp.all.2, prov_name)
  prov_stool <- .dr_filter_prov(pstool, prov_name)
  prov_stool <- prov_stool |>
    dplyr::select(-dplyr::any_of(c("ADM1_NAME", "prov", "adm1guid")))

  generate_inad_tab(prov_afp, prov_stool, start_date, end_date)
}

#' PROV 60-day follow-up table
#'
#' @param cases.need60day Output from `generate_60_day_table_data()`.
#' @param prov_name PROV name.
#' @returns A flextable.
generate_prov_60_day_table <- function(cases.need60day, prov_name) {
  prov_cases <- .dr_filter_prov(cases.need60day, prov_name)
  generate_60_day_tab(prov_cases)
}

.dr_prov_npafp <- function(ctry.data, prov_name, start_date, end_date,
                            include_pending = FALSE) {
  classifications <- if (include_pending) {

    c("NPAFP", "PENDING", "LAB PENDING")
  } else {
    "NPAFP"
  }

  .dr_filter_prov(ctry.data$afp.all.2, prov_name) |>
    dplyr::filter(
      dplyr::between(date, lubridate::as_date(start_date), lubridate::as_date(end_date)),
      cdc.classification.all2 %in% classifications

    )
}

#' Immunization status of NPAFP cases in one prov
#'
#' Pending and lab-pending cases may be included to match the national graph.
#'
#' @inheritParams generate_prov_afp_epicurve
#' @param include_pending Include pending and lab-pending cases. Defaults to
#'   `TRUE`, matching `generate_case_num_dose_g()`.
#' @returns A ggplot object.
generate_prov_npafp_immunization_graph <- function(
    ctry.data, prov_name, start_date, end_date,
    include_pending = TRUE, output_path = NULL) {
  if (!requireNamespace("ggpubr", quietly = TRUE)) {
    stop(
      'Package "ggpubr" must be installed to create the immunization graph.',
      call. = FALSE
    )
  }

  dose.num.cols <- c(
    "4+" = "#548235", "3" = "#92D050", "1-2" = "#FFC000",
    "0" = "#C00000", "Unknown" = "#4F81BD", "Missing" = "#7F7F7F"
  )
  dcat.yr.prov <- .dr_prov_npafp(
    ctry.data, prov_name, start_date, end_date, include_pending
  ) |>
    dplyr::filter(dplyr::between(age.months, 6, 59) | is.na(age.months)) |>
    dplyr::mutate(
      year = factor(year),
      dose.cat = dplyr::case_when(
        is.na(dose.cat) ~ "Missing",
        as.character(dose.cat) %in% c(
          "Missing", "0", "1-2", "3", "4+", "Unknown"
        ) ~ as.character(dose.cat),
        TRUE ~ "Unknown"
      ),
      dose.cat = factor(dose.cat, levels = names(dose.num.cols))
    ) |>
    dplyr::group_by(dose.cat, year, prov) |>
    dplyr::summarise(freq = dplyr::n(), .groups = "drop")

  title <- paste("OPV/IPV Status of NPAFP Cases -", prov_name)
  if (nrow(dcat.yr.prov) == 0) {
    plot <- .dr_prov_empty_plot(title)
  } else {
    case.totals <- dcat.yr.prov |>
      dplyr::group_by(year) |>
      dplyr::summarise(freq = sum(freq), .groups = "drop")

    legend.data <- data.frame(
      dose.cat = factor(names(dose.num.cols), levels = names(dose.num.cols)),
      stringsAsFactors = FALSE
    )

    plot <- ggplot2::ggplot(
      dcat.yr.prov,
      ggplot2::aes(x = year, y = freq, fill = dose.cat)
    ) +
      ggplot2::geom_bar(stat = "identity", position = "fill") +
      ggplot2::geom_point(
        data = legend.data,
        mapping = ggplot2::aes(fill = dose.cat),
        x = -Inf, y = -Inf, shape = 22, size = 0, alpha = 0,
        inherit.aes = FALSE, show.legend = TRUE
      ) +
      ggplot2::xlab("") +
      ggplot2::ylab("Percent of Cases") +
      ggplot2::scale_fill_manual(

        name = "Number of doses - IPV/OPV",
        values = dose.num.cols,
        limits = names(dose.num.cols),
        breaks = names(dose.num.cols),
        drop = FALSE
      ) +
      ggplot2::guides(
        fill = ggplot2::guide_legend(
          nrow = 1, byrow = TRUE, title.position = "top",
          label.position = "right",

          override.aes = list(
            shape = 22, size = 6, alpha = 1, colour = NA
          )
        )
      ) +
      ggplot2::scale_y_continuous(
        labels = scales::percent,
        expand = ggplot2::expansion(mult = c(0, 0.08))
      ) +
      ggplot2::labs(
        title = title,
        caption = paste(
          "Note: Includes NPAFP, Pending, and Lab Pending cases.",
          "Cases with missing age are included."
        )
      ) +
      ggplot2::geom_text(
        data = case.totals,
        ggplot2::aes(x = year, y = 1.02, label = paste0("n = ", freq)),
        inherit.aes = FALSE, check_overlap = TRUE
      ) +
      ggpubr::theme_pubr() +
      ggplot2::theme(
        legend.position = "top",
        legend.direction = "horizontal",
        legend.box = "horizontal",
        legend.title = ggplot2::element_text(face = "bold"),
        legend.text = ggplot2::element_text(size = 10),
        plot.caption = ggplot2::element_text(
          size = 9, hjust = 0, margin = ggplot2::margin(t = 10)
        )
      )
  }

  .dr_prov_save(
    plot,
    paste0(.dr_prov_slug(prov_name), "-npafp-immunization.png"),
    output_path, 9, 8
  )
  plot
}

#' Histogram of NPAFP case age in one prov
#'
#' @inheritParams generate_prov_afp_epicurve
#' @param binwidth Width of histogram bins in years.
#' @returns A ggplot object.
generate_prov_npafp_age_histogram <- function(
    ctry.data, prov_name, start_date, end_date,
    binwidth = 1, output_path = NULL) {
  afp <- .dr_prov_npafp(ctry.data, prov_name, start_date, end_date) |>
    dplyr::filter(!is.na(age.months), age.months > 0) |>
    dplyr::mutate(
      age_years = floor(age.months / 12),
      year = lubridate::year(date),
      age_group = dplyr::case_when(
        age_years < 5 ~ "Under 5 years",
        age_years <= 15 ~ "5-15 years",
        age_years > 15 ~ "Over 15 years"
      ),
      age_group = factor(
        age_group,
        levels = c("Under 5 years", "5-15 years", "Over 15 years")
      )
    )

  title <- paste("Age Distribution of NPAFP Cases -", prov_name)
  if (nrow(afp) == 0) {
    plot <- .dr_prov_empty_plot(title)

  } else {
    year_labels <- afp |>
      dplyr::count(year, name = "year_cases") |>
      dplyr::mutate(panel = paste0(year, " (n = ", year_cases, ")"))
    afp <- dplyr::left_join(afp, year_labels, by = "year")

    age_group_percentages <- afp |>
      dplyr::count(year, age_group, .drop = FALSE, name = "cases") |>
      dplyr::group_by(year) |>
      dplyr::mutate(percentage = cases / sum(cases)) |>
      dplyr::ungroup() |>

      dplyr::left_join(year_labels, by = "year") |>
      dplyr::mutate(label_vjust = dplyr::case_when(
        age_group == "Under 5 years" ~ 1.2,
        age_group == "5-15 years" ~ 2.7,
        age_group == "Over 15 years" ~ 4.2
      ))

    plot <- ggplot2::ggplot(afp, ggplot2::aes(x = age_years)) +
      ggplot2::geom_histogram(
        ggplot2::aes(fill = age_group),
        binwidth = binwidth, boundary = 0,
        color = "white"
      ) +
      ggplot2::geom_text(
        data = age_group_percentages,
        ggplot2::aes(
          x = Inf, y = Inf,
          label = paste0(
            as.character(age_group), ": ",
            scales::percent(percentage, accuracy = 1),
            " (n = ", cases, ")"
          ),
          color = age_group,
          vjust = label_vjust
        ),
        inherit.aes = FALSE,
        hjust = 1.05,
        fontface = "bold",
        show.legend = FALSE
      ) +
      ggplot2::facet_wrap(ggplot2::vars(panel)) +
      ggplot2::scale_fill_manual(
        name = "Age group",
        values = c(
          "Under 5 years" = "#2c7bb6",
          "5-15 years" = "#fdae61",
          "Over 15 years" = "#d7191c"
        ),
        drop = FALSE
      ) +
      ggplot2::scale_color_manual(
        values = c(
          "Under 5 years" = "#2c7bb6",
          "5-15 years" = "#fdae61",
          "Over 15 years" = "#d7191c"
        ),
        guide = "none"
      ) +
      ggplot2::scale_x_continuous(
        limits = c(0, NA),
        breaks = scales::breaks_width(1),
        expand = ggplot2::expansion(mult = c(0, 0.05))
      ) +
      ggplot2::labs(
        title = title,
        x = "Completed age at onset (years)",
        y = "NPAFP cases",
        caption = paste(
          "Percentages are calculated within onset year among NPAFP cases",
          "with known positive age."
        )
      ) +
      ggplot2::theme_classic() +
      ggplot2::theme(
        panel.grid.major = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        legend.position = "top",
        plot.caption = ggplot2::element_text(hjust = 0)

      )
  }

  .dr_prov_save(
    plot,
    paste0(.dr_prov_slug(prov_name), "-npafp-age-histogram.png"),
    output_path, 9, 6
  )
  plot
}

#' Delayed detection of NPAFP cases in one prov

#'
#' Each bar is the proportion of all NPAFP cases with a nonmissing onset-to-
#' second-stool interval in that year. The two requested late-detection groups
#' are shown; cases collected within 14 days remain in the denominator.
#'
#' @inheritParams generate_prov_afp_epicurve
#' @returns A ggplot object.
generate_prov_npafp_detection_delay_graph <- function(
    ctry.data, prov_name, start_date, end_date, output_path = NULL) {
  delay_levels <- c("<=14 days", ">14 to <=60 days", ">60 days")
  afp <- .dr_prov_npafp(ctry.data, prov_name, start_date, end_date) |>
    dplyr::filter(!is.na(ontostool2), ontostool2 >= 0) |>
    dplyr::mutate(
      year = factor(lubridate::year(date)),
      delay_group = dplyr::case_when(
        ontostool2 <= 14 ~ "<=14 days",
        ontostool2 > 14 & ontostool2 <= 60 ~ ">14 to <=60 days",
        ontostool2 > 60 ~ ">60 days"
      ),
      delay_group = factor(delay_group, levels = delay_levels)
    )

  title <- paste("Onset to Second Stool Collection -", prov_name)
  if (nrow(afp) == 0) {
    plot <- .dr_prov_empty_plot(
      title, "No NPAFP cases with a valid onset-to-second-stool interval"
    )
  } else {
    denominator <- afp |>
      dplyr::count(year, name = "denominator")
    delay_counts <- afp |>
      dplyr::count(year, delay_group, name = "cases")
    delay_grid <- tidyr::expand_grid(
      year = sort(unique(afp$year)),
      delay_group = factor(delay_levels, levels = delay_levels)
    )
    delayed <- delay_grid |>
      dplyr::left_join(delay_counts, by = c("year", "delay_group")) |>
      dplyr::mutate(cases = tidyr::replace_na(cases, 0L)) |>
      dplyr::left_join(denominator, by = "year") |>
      dplyr::mutate(
        proportion = cases / denominator,
        display_label = dplyr::case_when(
          proportion > 0 & proportion < 0.01 ~ "1%",
          TRUE ~ scales::percent(proportion, accuracy = 1)
        )
      )

    plot <- ggplot2::ggplot(
      delayed,
      ggplot2::aes(x = year, y = proportion, fill = delay_group)
    ) +
      ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.9)) +
      ggplot2::geom_text(
        ggplot2::aes(label = display_label),
        position = ggplot2::position_dodge(width = 0.9), vjust = -0.25
      ) +
      ggplot2::scale_fill_manual(
        name = "Onset to second stool",
        values = c(
          "<=14 days" = "#1a9641",
          ">14 to <=60 days" = "#fdae61",
          ">60 days" = "#d7191c"
        ),
        limits = delay_levels,
        drop = FALSE
      ) +

      ggplot2::scale_y_continuous(
        labels = scales::percent,
        limits = c(0, max(delayed$proportion, na.rm = TRUE) * 1.15)
      ) +
      ggplot2::labs(
        title = title, x = NULL, y = "Proportion of NPAFP cases",
        caption = "Denominator: NPAFP cases with a nonmissing onset-to-second-stool interval."
      ) +
      ggplot2::theme_classic() +
      ggplot2::theme(
        panel.grid.major = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        legend.position = "top"

      )
  }

  .dr_prov_save(
    plot,
    paste0(.dr_prov_slug(prov_name), "-npafp-detection-delay.png"),
    output_path, 9, 6
  )
  plot
}

#' Annual AFP timeliness map panels by district for one prov
#'
#' The four indicators use the cleaned desk-review flags `noti.7d.on`,
#' `inv.2d.noti`, `coll.3d.inv`, and `ship.3d.coll`. One faceted plot is
#' returned for each indicator, with one district-map panel per year.
#'
#' @param ctry.data Country data returned by `init_dr()` and
#'   `clean_ctry_data()`.
#' @param prov_name PROV name.
#' @param prov.shape,dist.shape Long-format PROV and DIST geometry.
#' @param start_date,end_date Analysis dates.
#' @param output_path Optional output directory.
#' @returns A named list of four ggplot objects, one per timeliness indicator.
generate_prov_district_timeliness_panel <- function(
    ctry.data, prov_name, prov.shape, dist.shape,
    start_date, end_date, output_path = NULL) {
  start_date <- lubridate::as_date(start_date)
  end_date <- lubridate::as_date(end_date)
  interval_columns <- c(
    "noti.7d.on", "inv.2d.noti", "coll.3d.inv", "ship.3d.coll"
  )
  missing_columns <- setdiff(interval_columns, names(ctry.data$afp.all.2))
  if (length(missing_columns) > 0) {
    cli::cli_abort(paste0(
      "AFP data is missing timeliness columns: ",
      paste(missing_columns, collapse = ", "),
      ". Run `clean_ctry_data()` before creating this panel."
    ))
  }

  prov_boundary <- .dr_prov_shape_years(
    prov.shape, prov_name, start_date, end_date
  )
  prov_districts <- .dr_prov_shape_years(
    dist.shape, prov_name, start_date, end_date
  )

  prov_afp <- .dr_filter_prov(ctry.data$afp.all.2, prov_name) |>
    dplyr::filter(
      dplyr::between(date, start_date, end_date),
      is.na(cdc.classification.all2) |
        cdc.classification.all2 != "NOT-AFP"
    ) |>
    dplyr::mutate(year = lubridate::year(date))

  interval_summary <- prov_afp |>
    dplyr::select(
      epid, year, dist, adm2guid, dplyr::all_of(interval_columns)
    ) |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(interval_columns),
      names_to = "type", values_to = "value"
    ) |>
    dplyr::group_by(year, type, dist, adm2guid) |>
    dplyr::summarise(

      case_count = dplyr::n(),
      observed_count = sum(!is.na(value)),
      timely_count = sum(value == TRUE, na.rm = TRUE),
      proportion = timely_count / case_count,
      .groups = "drop"
    )

  category_levels <- c(
    "<20%", "20-49%", "50-79%", "80-89%", "90-100%",
    "No AFP cases", "Missing"
  )
  category_colors <- sirfunctions::f.color.schemes("mapval")
  if (length(category_colors) < length(category_levels)) {
    cli::cli_abort(

      "The main desk-review `mapval` palette does not contain seven colors."
    )
  }
  category_colors <- stats::setNames(
    unname(category_colors)[seq_along(category_levels)], category_levels
  )

  interval_titles <- c(
    "noti.7d.on" =
      "Proportion of cases with notification within 7 days of onset",
    "inv.2d.noti" =
      "Proportion of cases with investigation within 2 days of notification",
    "coll.3d.inv" =
      "Proportion of cases with stool 1 collection within 3 days of investigation",
    "ship.3d.coll" =
      "Proportion of cases with stool shipped within 3 days of collection"
  )

  panel_plots <- stats::setNames(
    lapply(interval_columns, function(interval_name) {
      measure_summary <- interval_summary |>
        dplyr::filter(type == interval_name) |>
        dplyr::select(-type)
      measure_map <- dplyr::left_join(
        prov_districts,
        measure_summary,
        by = c("GUID" = "adm2guid", "year" = "year")
      ) |>
        dplyr::mutate(
          category = dplyr::case_when(
            is.na(case_count) | case_count == 0 ~ "No AFP cases",
            observed_count == 0 ~ "Missing",
            proportion < 0.20 ~ "<20%",
            proportion < 0.50 ~ "20-49%",
            proportion < 0.80 ~ "50-79%",
            proportion < 0.90 ~ "80-89%",
            proportion <= 1 ~ "90-100%",
            TRUE ~ "Missing"
          ),
          category = factor(category, levels = category_levels)
        )

      plot <- ggplot2::ggplot() +
      ggplot2::geom_sf(
        data = prov_boundary,
        color = "black", fill = NA, linewidth = 0.8
      ) +
      ggplot2::geom_sf(
        data = measure_map,
        ggplot2::aes(fill = category),
        color = "black", linewidth = 0.25,
        show.legend = TRUE
      ) +
      ggplot2::scale_fill_manual(
        name = "Proportion",
        values = category_colors,
        limits = category_levels,
        breaks = category_levels,
        drop = FALSE
      ) +
      ggplot2::facet_wrap(ggplot2::vars(year), ncol = 4) +
      ggplot2::ggtitle(paste0(
        prov_name, " - ", interval_titles[[interval_name]]
      )) +
      sirfunctions::f.plot.looks("epicurve") +

      ggplot2::theme(
        axis.text.x = ggplot2::element_blank(),
        axis.text.y = ggplot2::element_blank(),
        axis.ticks = ggplot2::element_blank(),
        plot.title = ggplot2::element_text(size = 12),
        legend.position = "bottom"
      )
      .dr_prov_save(
        plot,
        paste0(
          .dr_prov_slug(prov_name), "-district-timeliness-",
          gsub("\\.", "-", interval_name), ".png"
        ),
        output_path, 14, 8
      )

      plot
    }),
    unname(interval_titles[interval_columns])
  )
  panel_plots
}

#' ES detection dot chart for one prov
#'
#' This is the prov-filtered equivalent of `generate_es_site_det()` and uses
#' the same SIA shading, detection colors, labels, and theme.
#'
#' @param ctry.data Country data returned by `init_dr()`.
#' @param prov_name PROV name.
#' @param es_start_date,es_end_date ES analysis dates.
#' @param output_path Optional output directory.
#' @param vaccine_types,detection_types Optional named color vectors. Defaults
#'   match the main desk-review chart.
#' @returns A ggplot object.
generate_prov_es_detection_chart <- function(
    ctry.data, prov_name,
    es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
    es_end_date = end_date, output_path = NULL,
    vaccine_types = NULL, detection_types = NULL) {
  es_start_date <- lubridate::as_date(es_start_date)
  es_end_date <- lubridate::as_date(es_end_date)
  title <- paste("ES Sites and Detection -", prov_name)

  if (is.null(ctry.data$es) || nrow(ctry.data$es) == 0) {
    plot <- .dr_prov_empty_plot(title, "No ES records available")
    .dr_prov_save(
      plot, paste0(.dr_prov_slug(prov_name), "-es-detection-chart.png"),
      output_path, 14, 8
    )
    return(plot)
  }

  es_data <- .dr_filter_prov(ctry.data$es, prov_name) |>
    dplyr::filter(dplyr::between(collect.date, es_start_date, es_end_date))
  if (nrow(es_data) == 0) {
    plot <- .dr_prov_empty_plot(title, "No ES records in the analysis period")
    .dr_prov_save(
      plot, paste0(.dr_prov_slug(prov_name), "-es-detection-chart.png"),
      output_path, 14, 8
    )
    return(plot)
  }

  sia_data <- ctry.data$sia
  if (is.null(sia_data) || nrow(sia_data) == 0) {
    sias <- data.frame(
      yr.sia = integer(), province = character(),
      activity.start.date = as.Date(character()),
      activity.end.date = as.Date(character()), vaccine.type = character()
    )
  } else {
    sias <- .dr_filter_prov(
      sia_data, prov_name, columns = c("province", "ADM1_NAME", "prov")
    ) |>
      dplyr::filter(
        status == "Done",
        yr.sia >= lubridate::year(es_start_date),
        yr.sia <= lubridate::year(es_end_date)
      ) |>

      dplyr::mutate(
        activity.start.date = as.Date(activity.start.date),
        activity.end.date = as.Date(activity.end.date)
      )
  }

  sia_summary <- sias |>
    dplyr::count(
      yr.sia, province, activity.start.date, activity.end.date, vaccine.type
    )
  if ("province" %in% names(sia_summary)) {
    names(sia_summary)[names(sia_summary) == "province"] <- "ADM1_NAME"
  }

  if (is.null(vaccine_types)) {
    vaccine_types <- sirfunctions::f.color.schemes("es.vaccine.types")

  }
  if (is.null(detection_types)) {
    detection_types <- sirfunctions::f.color.schemes("es.detections")
  }

  missing_vaccines <- setdiff(unique(sia_summary$vaccine.type), names(vaccine_types))
  missing_detections <- setdiff(unique(es_data$all_dets), names(detection_types))
  if (length(missing_vaccines) > 0) {
    cli::cli_alert_warning(paste0(
      "Vaccine types missing from the default ES colors: ",
      paste(missing_vaccines, collapse = ", ")
    ))
  }
  if (length(missing_detections) > 0) {
    cli::cli_alert_warning(paste0(
      "Detection types missing from the default ES colors: ",
      paste(missing_detections, collapse = ", ")
    ))
  }

  plot <- ggplot2::ggplot() +
    ggplot2::geom_rect(
      data = sia_summary,
      ggplot2::aes(
        xmin = activity.start.date, xmax = activity.end.date,
        ymin = 0, ymax = Inf, fill = vaccine.type
      ),
      alpha = 0.5
    ) +
    ggplot2::geom_point(
      data = es_data |> dplyr::arrange(ADM1_NAME),
      ggplot2::aes(x = collect.date, y = site.name, color = all_dets),
      pch = 19, size = 3
    ) +
    ggplot2::geom_point(
      data = es_data |> dplyr::arrange(ADM1_NAME),
      ggplot2::aes(x = collect.date, y = site.name),
      fill = NA, pch = 21, size = 3
    ) +
    ggplot2::xlab("") +
    ggplot2::ylab("Detection Sites") +
    ggplot2::scale_x_date(limits = c(es_start_date, es_end_date)) +
    ggplot2::scale_fill_manual(name = "SIAs", values = vaccine_types) +
    ggplot2::scale_color_manual(name = "ES detections", values = detection_types) +
    ggplot2::facet_grid(
      ADM1_NAME ~ ., scales = "free_y", space = "free", switch = "y",
      labeller = ggplot2::label_wrap_gen(8)
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(strip.text.y.left = ggplot2::element_text(angle = 0))

  .dr_prov_save(
    plot, paste0(.dr_prov_slug(prov_name), "-es-detection-chart.png"),
    output_path, 14, 8
  )
  plot
}

#' ES location and detection-rate map for one prov
#'
#' This is the prov-filtered equivalent of `generate_es_det_map()` and uses
#' identical detection-rate categories, colors, labels, and theme.
#'

#' @param ctry.data Country data returned by `init_dr()`.
#' @param prov_name PROV name.
#' @param prov.shape,dist.shape Long-format PROV and DIST geometry.
#' @inheritParams generate_prov_es_detection_chart
#' @returns A ggplot or annotated ggarrange object.
generate_prov_es_location_map <- function(
    ctry.data, prov_name, prov.shape, dist.shape,
    es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
    es_end_date = end_date, output_path = NULL) {
  if (!requireNamespace("ggrepel", quietly = TRUE)) {
    stop('Package "ggrepel" must be installed to create the ES map.', call. = FALSE)
  }
  if (!requireNamespace("ggpubr", quietly = TRUE)) {
    stop('Package "ggpubr" must be installed to create the ES map.', call. = FALSE)
  }

  es_start_date <- lubridate::as_date(es_start_date)

  es_end_date <- lubridate::as_date(es_end_date)
  title <- paste("ES Detection Rate by Site -", prov_name)

  if (is.null(ctry.data$es) || nrow(ctry.data$es) == 0) {
    plot <- .dr_prov_empty_plot(title, "No ES records available")
    .dr_prov_save(
      plot, paste0(.dr_prov_slug(prov_name), "-es-location-map.png"),
      output_path, 9, 8
    )
    return(plot)
  }

  es_data <- .dr_filter_prov(ctry.data$es, prov_name) |>
    dplyr::filter(dplyr::between(collect.date, es_start_date, es_end_date))
  if (nrow(es_data) == 0) {
    plot <- .dr_prov_empty_plot(title, "No ES records in the analysis period")
    .dr_prov_save(
      plot, paste0(.dr_prov_slug(prov_name), "-es-location-map.png"),
      output_path, 9, 8
    )
    return(plot)
  }

  prov_boundary <- .dr_prov_shape_years(
    prov.shape, prov_name, es_end_date, es_end_date
  )
  prov_districts <- .dr_prov_shape_years(
    dist.shape, prov_name, es_end_date, es_end_date
  )

  detection_rate <- es_data |>
    dplyr::group_by(site.name) |>
    dplyr::summarise(
      det.rate = 100 * sum(as.numeric(ev.detect), na.rm = TRUE) / dplyr::n(),
      samp.num = dplyr::n(),
      .groups = "drop"
    )
  detection_rate$cats <- cut(
    detection_rate$det.rate,
    breaks = c(0, 50, 80, 101), right = FALSE,
    labels = c("<50%", "50-79%", "80-100%")
  )
  detection_rate <- detection_rate |>
    dplyr::mutate(
      cats = as.character(cats),
      cats = dplyr::case_when(samp.num < 5 ~ "<5 samples", TRUE ~ cats),
      cats = factor(cats, levels = c("<50%", "50-79%", "80-100%", "<5 samples"))
    )

  site_coordinates <- es_data |>
    dplyr::group_by(site.name) |>
    dplyr::reframe(lat = lat, lng = lng) |>
    unique()
  # Match the main desk-review join order: attach detection summaries to the
  # sample data before coordinates are added to the site-level summary. This
  # preserves `lat` and `lng` rather than creating `.x`/`.y` columns.
  es_data <- dplyr::left_join(es_data, detection_rate, by = "site.name")
  detection_rate <- dplyr::left_join(
    detection_rate, site_coordinates, by = "site.name"
  )

  plot <- ggplot2::ggplot() +

    ggplot2::geom_sf(
      data = prov_boundary, color = "black", fill = NA, size = 1
    ) +
    ggplot2::geom_sf(
      data = prov_districts, color = "black", fill = NA, size = 0.5
    ) +
    ggplot2::geom_point(
      data = detection_rate,
      ggplot2::aes(x = as.numeric(lng), y = as.numeric(lat), color = cats),
      show.legend = TRUE
    ) +
    ggrepel::geom_label_repel(
      data = detection_rate,
      ggplot2::aes(
        x = as.numeric(lng), y = as.numeric(lat),
        label = site.name, color = cats
      ),
      show.legend = FALSE, force = 100

    ) +
    ggplot2::ggtitle(paste0(
      "ES detection rate by site: ",
      format(es_start_date, "%B %Y"), " - ", format(es_end_date, "%B %Y")
    )) +
    ggplot2::scale_color_manual(
      values = c(
        "<50%" = "#FF0000", "50-79%" = "#feb24c",
        "80-100%" = "#0070c0", "<5 samples" = "black"
      ),
      name = "EV detection rate", drop = FALSE
    ) +
    sirfunctions::f.plot.looks("02") +
    ggplot2::theme(legend.position = "right")

  if ("imputed_coord" %in% names(es_data)) {
    imputed_sites <- es_data |>
      dplyr::filter(imputed_coord == TRUE, !is.na(lat), !is.na(lng)) |>
      dplyr::pull(site.name) |>
      unique()
    if (length(imputed_sites) > 0) {
      cli::cli_alert_info(
        "Some ES sites have imputed coordinates due to missing site coordinates."
      )
      plot <- ggpubr::annotate_figure(
        plot,
        bottom = ggpubr::text_grob(
          "Sites missing coordinates randomly assigned within their district:\n",
          hjust = 0.75, vjust = 0.5, size = 10, color = "darkgrey"
        )
      )
      plot <- ggpubr::annotate_figure(
        plot,
        bottom = ggpubr::text_grob(
          paste0(imputed_sites, collapse = ", "),
          hjust = 0.97, vjust = -1.7, size = 8, color = "grey"
        )
      )
    }
  }

  .dr_prov_save(
    plot, paste0(.dr_prov_slug(prov_name), "-es-location-map.png"),
    output_path, 9, 8
  )
  plot
}

#' ES sample-transport timeliness for one prov
#'
#' This is the prov-filtered equivalent of `generate_es_timely()` and uses
#' the same site colors, three-day target line, labels, and formatting.
#'
#' @param ctry.data Country data returned by `init_dr()`.
#' @param prov_name PROV name.
#' @param es_start_date,es_end_date ES analysis dates.
#' @param output_path Optional output directory.
#' @param add_legend Whether to show the site-name legend.
#' @param .color ES column mapped to point color. Defaults to `site.name`.
#' @returns A ggplot object.
generate_prov_es_timeliness <- function(

    ctry.data, prov_name,
    es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
    es_end_date = end_date, output_path = NULL,
    add_legend = TRUE, .color = "site.name") {
  es_start_date <- lubridate::as_date(es_start_date)
  es_end_date <- lubridate::as_date(es_end_date)
  empty_title <- paste("Timeliness of ES Sample Transport -", prov_name)

  if (is.null(ctry.data$es) || nrow(ctry.data$es) == 0) {
    plot <- .dr_prov_empty_plot(empty_title, "No ES records available")
    .dr_prov_save(
      plot, paste0(.dr_prov_slug(prov_name), "-es-timeliness.png"),
      output_path, 14, 8
    )
    return(plot)
  }

  es_data <- .dr_filter_prov(ctry.data$es, prov_name) |>
    dplyr::filter(dplyr::between(collect.date, es_start_date, es_end_date))

  if (nrow(es_data) == 0) {
    plot <- .dr_prov_empty_plot(
      empty_title, "No ES records in the analysis period"
    )
    .dr_prov_save(
      plot, paste0(.dr_prov_slug(prov_name), "-es-timeliness.png"),
      output_path, 14, 8
    )
    return(plot)
  }

  es_data$timely <- difftime(
    as.Date(es_data$date.received.in.lab, format = "%d/%m/%Y"),
    es_data$collect.date,
    units = "days"
  )

  total_samples <- nrow(es_data)
  timely_samples <- sum(es_data$timely <= 3, na.rm = TRUE)
  missing_samples <- sum(is.na(es_data$timely))
  timeliness_title <- paste0(
    round(100 * timely_samples / total_samples, 0),
    "% of samples arrived in lab within 3 days of collection - \n",
    format(es_start_date, "%B %Y"), " - ", format(es_end_date, "%B %Y")
  )
  missing_caption <- paste0(
    missing_samples, " (",
    round(100 * missing_samples / total_samples, 0),
    "%) samples were missing date information"
  )

  valid_timeliness <- as.numeric(es_data$timely)
  valid_timeliness <- valid_timeliness[is.finite(valid_timeliness)]
  y_breaks <- if (length(valid_timeliness) > 0) {
    seq(0, max(pretty(valid_timeliness)), 6)
  } else {
    0
  }

  plot <- ggplot2::ggplot() +
    ggplot2::geom_hline(
      yintercept = 3, color = "dark gray", linetype = "dashed", lwd = 1
    ) +
    ggplot2::geom_point(
      data = dplyr::filter(es_data, timely >= 0),
      ggplot2::aes(
        x = collect.date,
        y = timely,
        color = !!dplyr::sym(.color)
      ),
      alpha = 0.7,
      position = ggplot2::position_jitter(height = 0.2, width = 0.5),
      size = 3
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::number_format(accuracy = 1),
      breaks = y_breaks
    ) +
    ggplot2::labs(
      x = "Date of collection",

      y = "Transport time to lab (days)",
      color = "Site Name",
      title = timeliness_title,
      caption = missing_caption
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      text = ggplot2::element_text(size = 16),
      axis.text = ggplot2::element_text(size = 14),
      plot.caption = ggplot2::element_text(hjust = 0)
    )

  if (!add_legend) {
    plot <- plot + ggplot2::theme(legend.position = "none")
  }

  .dr_prov_save(
    plot, paste0(.dr_prov_slug(prov_name), "-es-timeliness.png"),
    output_path, 14, 8
  )

  plot
}

#' ES site details table for one prov
#'
#' This is the prov-filtered equivalent of `generate_es_tab()` and preserves
#' the main desk-review calculations, labels, and flextable formatting.
#'
#' @param ctry.data Country data returned by `init_dr()`.
#' @param prov_name PROV name.
#' @param es_start_date,es_end_date ES analysis dates.
#' @returns A flextable.
generate_prov_es_site_table <- function(
    ctry.data, prov_name,
    es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
    es_end_date = end_date) {
  if (!requireNamespace("flextable", quietly = TRUE)) {
    stop('Package "flextable" must be installed to create the ES table.',
         call. = FALSE)
  }

  es_start_date <- lubridate::as_date(es_start_date)
  es_end_date <- lubridate::as_date(es_end_date)
  if (is.null(ctry.data$es) || nrow(ctry.data$es) == 0) {
    return(
      flextable::flextable(data.frame(Message = "No ES records available")) |>
        flextable::theme_booktabs()
    )
  }

  es_data <- .dr_filter_prov(ctry.data$es, prov_name) |>
    dplyr::filter(dplyr::between(collect.date, es_start_date, es_end_date))
  if (nrow(es_data) == 0) {
    return(
      flextable::flextable(data.frame(
        Message = "No ES records in the analysis period"
      )) |>
        flextable::theme_booktabs()
    )
  }

  es_data$timely <- difftime(
    as.Date(es_data$date.received.in.lab, format = "%d/%m/%Y"),
    es_data$collect.date,
    units = "days"
  )

  negative_intervals <- es_data |>
    dplyr::filter(timely < 0 | is.na(timely)) |>
    dplyr::group_by(ADM1_NAME, ADM2_NAME, site.name) |>
    dplyr::summarise(neg_intervals = dplyr::n(), .groups = "drop")
  sample_summary <- es_data |>
    dplyr::group_by(ADM1_NAME, ADM2_NAME, site.name) |>
    dplyr::summarise(samples = dplyr::n(), .groups = "drop")
  negative_intervals <- negative_intervals |>
    dplyr::left_join(
      sample_summary,
      by = c("ADM1_NAME", "ADM2_NAME", "site.name")
    ) |>

    dplyr::mutate(bad_samples = round(neg_intervals / samples * 100, 2))

  es_data <- es_data |>
    dplyr::mutate(timely = dplyr::if_else(timely < 0, NA, timely))

  es_summary <- es_data |>
    dplyr::group_by(site.name, ADM1_NAME, ADM2_NAME) |>
    dplyr::reframe(
      early.dat = format(early.dat, format = "%B %d, %Y"),
      ev.pct = 100 * sum(as.numeric(ev.detect), na.rm = TRUE) / dplyr::n(),
      num.spec = dplyr::n(),
      num.spec.bad = sum(is.na(timely)),
      condition.pct =
        100 * sum(sample.condition == "Good", na.rm = TRUE) / dplyr::n(),
      trans.pct = round(
        100 * sum(as.numeric(timely) <= 3, na.rm = TRUE) / dplyr::n(), 0
      ),
      med.trans = paste0(
        median(as.numeric(timely), na.rm = TRUE), " (",
        min(as.numeric(timely), na.rm = TRUE), ", ",
        max(as.numeric(timely), na.rm = TRUE), ")"

      ),
      num.wpv.or.vdpv = sum(wpv, na.rm = TRUE) + sum(vdpv, na.rm = TRUE)
    ) |>
    dplyr::distinct() |>
    dplyr::arrange(ADM1_NAME, ADM2_NAME, site.name)

  table <- es_summary |>
    flextable::flextable(
      col_keys = c(
        "ADM1_NAME", "ADM2_NAME", "site.name", "early.dat", "num.spec",
        "num.spec.bad", "ev.pct", "condition.pct", "trans.pct",
        "med.trans", "num.wpv.or.vdpv"
      )
    ) |>
    flextable::theme_booktabs() |>
    flextable::add_header_lines(values = paste0(
      format(es_start_date, "%B %Y"), " - ", format(es_end_date, "%B %Y")
    )) |>
    flextable::bold(bold = TRUE, part = "header") |>
    flextable::align(j = 4:9, align = "center", part = "all") |>
    flextable::align(j = 1:3, align = "left", part = "all") |>
    flextable::colformat_double(j = 5:8, digits = 0, na_str = "NA") |>
    flextable::width(width = 1) |>
    flextable::width(j = 3, width = 2.5) |>
    flextable::width(j = 1:2, width = 1.5) |>
    flextable::fontsize(size = 11, part = "all") |>
    flextable::set_header_labels(
      ADM1_NAME = "Province",
      ADM2_NAME = "District",
      early.dat = "Earliest date reporting to POLIS",
      site.name = "Site name",
      num.spec = "No. samples collected",
      num.spec.bad =
        "Excluded samples with bad data (negative or N/A time intervals)",
      ev.pct = "% detected EV",
      condition.pct = "% good condition",
      trans.pct = "% arriving within 3 days",
      med.trans = "Median lab transport time (d)",
      num.wpv.or.vdpv = "No. VDPV or WPV"
    ) |>
    flextable::align(j = 10:11, align = "center", part = "all")

  if (nrow(negative_intervals) > 0) {
    cli::cli_alert_info(paste0(
      prov_name, ": ", sum(negative_intervals$neg_intervals),
      " ES samples with negative or missing transport intervals were excluded ",
      "from interval calculations."
    ))
  }

  table
}

#' Generate the complete prov AFP review set
#'
#' This convenience function calls all nine prov outputs and returns them in a
#' named list. Use `list_desk_review_prov(ctry.data)` to obtain valid values
#' for `prov_name` or iterate over all prov_names.

#'
#' @param ctry.data Country data returned by `init_dr()`.
#' @param prov_name PROV name.
#' @param dist.extract District output from `f.npafp.rate.01()`.
#' @param pstool,dstool Province and district outputs from `f.stool.ad.01()`.
#' @param cases.need60day Output from `generate_60_day_table_data()`.
#' @param prov.shape,dist.shape Long-format PROV and DIST geometry.
#' @param start_date,end_date Analysis dates.
#' @param output_path Optional directory for PNG files. Tables are returned and
#'   are not written to disk.
#' @param es_start_date,es_end_date ES analysis dates. By default, the ES
#'   period is the year ending on `end_date`.
#' @returns A named list of PROV figures, timeliness panels, and flextables.
#' @export
generate_prov_desk_review_outputs <- function(
    ctry.data, prov_name, dist.extract, pstool, dstool, cases.need60day,
    prov.shape, dist.shape, start_date, end_date, output_path = NULL,
    es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
    es_end_date = end_date) {
  cli::cli_process_start(paste0("Generating province-level outputs for ", prov_name))
  on.exit(cli::cli_process_done(), add = TRUE)

  outputs <- list(
    population_roads_map = generate_prov_population_roads_map(
      ctry.data, prov_name, prov.shape, dist.shape, end_date, output_path

    ),
    afp_case_map = generate_prov_afp_case_map(
      ctry.data, prov_name, prov.shape, start_date, end_date, output_path,
      dist.shape = dist.shape
    ),
    afp_epicurve = generate_prov_afp_epicurve(
      ctry.data, prov_name, start_date, end_date, output_path
    ),
    npafp_rate_map = generate_prov_npafp_map(
      dist.extract, prov_name, prov.shape, dist.shape,
      start_date, end_date, output_path
    ),
    stool_adequacy_map = generate_prov_stool_adequacy_map(
      dstool, prov_name, prov.shape, dist.shape,
      start_date, end_date, output_path
    ),
    stool_adequacy_table = generate_prov_stool_adequacy_table(
      ctry.data, pstool, prov_name, start_date, end_date
    ),
    followup_60_day_table = generate_prov_60_day_table(
      cases.need60day, prov_name
    ),
    district_timeliness_panel = generate_prov_district_timeliness_panel(
      ctry.data, prov_name, prov.shape, dist.shape,
      start_date, end_date, output_path
    ),
    es_detection_chart = generate_prov_es_detection_chart(
      ctry.data, prov_name, es_start_date, es_end_date, output_path
    ),
    es_location_map = generate_prov_es_location_map(
      ctry.data, prov_name, prov.shape, dist.shape,
      es_start_date, es_end_date, output_path
    ),
    es_timeliness = generate_prov_es_timeliness(
      ctry.data, prov_name, es_start_date, es_end_date, output_path
    ),
    es_site_table = generate_prov_es_site_table(
      ctry.data, prov_name, es_start_date, es_end_date
    )
  )

  outputs
}
