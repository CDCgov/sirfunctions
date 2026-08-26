# PROV-level AFP desk-review PowerPoints ----------------------------------

.dr_prov_ppt_requirements <- function() {
  for (package in c("officer", "rvg")) {
    if (!requireNamespace(package, quietly = TRUE)) {
      stop(
        paste0('Package "', package, '" must be installed to create the PowerPoint.'),
        call. = FALSE
      )
    }
  }
}

.dr_prov_ppt_assumptions <- function(prov_name, start_date, end_date) {
  assumption_text <- c(
    paste0("PROV-level analysis: ", prov_name),
    paste0(
      "Timeframe for analysis: ", format(start_date, "%d-%b-%Y"),
      " to ", format(end_date, "%d-%b-%Y")
    ),
    "NPAFP cases include pending lab and pending classification cases where indicated.",
    "Stool adequacy includes all AFP cases.",
    "Samples with missing stool condition are considered good quality.",
    "Samples with invalid date data are considered inadequate."
  )

  officer::unordered_list(
    level_list = c(1, 1, 1, 1, 2, 2),
    str_list = assumption_text,
    style = officer::fp_text(color = "black", font.size = 17)
  )
}

.dr_prov_ppt_template <- function(path = NULL) {
  if (is.null(path)) {
    system.file(
      "extdata", "desk_review_template.pptx",
      package = "sirfunctions"
    )
  } else {
    file.path(path)
  }
}

.dr_prov_ppt_add_plot <- function(deck, title, plot,
                                   layout = "Title and Content",
                                   master = "1_Office Theme") {
  deck <- officer::add_slide(deck, layout = layout, master = master)
  deck <- officer::ph_with(
    deck,
    value = title,
    location = officer::ph_location_type("title")
  )
  tryCatch(
    officer::ph_with(
      deck,
      value = rvg::dml(ggobj = plot),
      location = officer::ph_location_type("body")
    ),
    error = function(error) {
      cli::cli_abort(
        paste0(
          "PowerPoint could not render the plot on slide `", title, "`: ",
          conditionMessage(error)
        ),
        parent = error
      )
    }
  )
}

.dr_prov_ppt_add_table <- function(deck, title, table,
                                    layout = "Title and Content",
                                    master = "1_Office Theme") {
  deck <- officer::add_slide(deck, layout = layout, master = master)
  deck <- officer::ph_with(
    deck,
    value = title,
    location = officer::ph_location_type("title")
  )


  officer::ph_with(
    deck,
    value = table,
    location = officer::ph_location_type("body")
  )
}

.dr_prov_ppt_validate_outputs <- function(prov_outputs) {
  required <- c(
    "afp_case_map",
    "population_roads_map",
    "afp_epicurve",
    "npafp_rate_map",
    "stool_adequacy_map",
    "stool_adequacy_table",
    "followup_60_day_table",
    "district_timeliness_panel",
    "es_detection_chart",
    "es_location_map",
    "es_timeliness",
    "es_site_table"
  )
  missing_outputs <- setdiff(required, names(prov_outputs))
  if (length(missing_outputs) > 0) {
    cli::cli_abort(paste0(
      "`prov_outputs` is missing: ",
      paste(missing_outputs, collapse = ", "), "."
    ))
  }
  invisible(TRUE)
}

#' Write prov AFP outputs to a PowerPoint
#'
#' The title slide begins with the selected prov name. Figures are inserted as
#' editable vector graphics and flextables remain native PowerPoint tables.
#'
#' @param prov_outputs Named list returned by
#'   `generate_prov_desk_review_outputs()`.
#' @param prov_name PROV name displayed on the first slide.
#' @param start_date,end_date Analysis dates.
#' @param ppt_output_file Full path and filename for the `.pptx` file.
#' @param ppt_template_path Optional desk-review PowerPoint template. `NULL`
#'   uses the template returned by `get_ppt_template()`.
#' @param master PowerPoint master name used by the desk-review template.
#' @param title_layout,content_layout Layout names used by the template.
#' @returns The normalized path of the PowerPoint file, invisibly.
#' @export
write_prov_desk_review_ppt <- function(
    prov_outputs, prov_name, start_date, end_date, ppt_output_file,
    ppt_template_path = NULL, master = "1_Office Theme",
    title_layout = "Title Slide", content_layout = "Title and Content") {
  .dr_prov_ppt_requirements()
  .dr_prov_ppt_validate_outputs(prov_outputs)
  cli::cli_process_start(paste0("Writing province-level PowerPoint for ", prov_name))
  on.exit(cli::cli_process_done(), add = TRUE)

  start_date <- lubridate::as_date(start_date)
  end_date <- lubridate::as_date(end_date)

  if (!nzchar(ppt_output_file)) {
    cli::cli_abort("`ppt_output_file` must be supplied.")
  }
  if (tolower(tools::file_ext(ppt_output_file)) != "pptx") {
    ppt_output_file <- paste0(ppt_output_file, ".pptx")
  }
  output_dir <- dirname(ppt_output_file)
  if (!dir.exists(output_dir)) {
    cli::cli_abort(paste0("PowerPoint output directory does not exist: ", output_dir))
  }

  ppt_template_path <- .dr_prov_ppt_template(ppt_template_path)
  if (!nzchar(ppt_template_path) || !file.exists(ppt_template_path)) {
    cli::cli_abort("PowerPoint template path does not exist.")
  }

  deck <- officer::read_pptx(ppt_template_path)

  # First slide: prov name

  deck <- officer::add_slide(deck, layout = title_layout, master = master)
  deck <- officer::ph_with(
    deck,

    value = paste(toupper(prov_name), "AFP DESK REVIEW"),
    location = officer::ph_location_type("ctrTitle")
  )

  # Analysis scope and assumptions
  assumptions <- .dr_prov_ppt_assumptions(prov_name, start_date, end_date)
  deck <- officer::add_slide(deck, layout = content_layout, master = master)
  deck <- officer::ph_with(
    deck,
    value = paste("Analysis Notes -", prov_name),
    location = officer::ph_location_type("title")
  )
  deck <- officer::ph_with(
    deck,
    value = assumptions,
    location = officer::ph_location_type("body")
  )

  # PROV surveillance outputs
  deck <- .dr_prov_ppt_add_plot(
    deck,
    paste("PROV Population and Roads -", prov_name),
    prov_outputs$population_roads_map,
    content_layout, master
  )
  deck <- .dr_prov_ppt_add_plot(
    deck,
    paste("Paralytic Polio and Compatible Cases -", prov_name),
    prov_outputs$afp_case_map,
    content_layout, master
  )
  deck <- .dr_prov_ppt_add_plot(
    deck,
    paste("AFP Epicurve -", prov_name),
    prov_outputs$afp_epicurve,
    content_layout, master
  )
  deck <- .dr_prov_ppt_add_plot(
    deck,
    paste("NPAFP Rate by District -", prov_name),
    prov_outputs$npafp_rate_map,
    content_layout, master
  )
  deck <- .dr_prov_ppt_add_plot(
    deck,
    paste("Stool Adequacy by District -", prov_name),
    prov_outputs$stool_adequacy_map,
    content_layout, master
  )
  deck <- .dr_prov_ppt_add_table(
    deck,
    paste("Main Issues with Stool Adequacy -", prov_name),
    prov_outputs$stool_adequacy_table,
    content_layout, master
  )
  deck <- .dr_prov_ppt_add_table(
    deck,
    paste("60-Day Follow-up -", prov_name),
    prov_outputs$followup_60_day_table,
    content_layout, master
  )
  timeliness_panels <- prov_outputs$district_timeliness_panel
  if (!is.list(timeliness_panels) || length(timeliness_panels) != 4) {
    cli::cli_abort(
      "`district_timeliness_panel` must contain the four annual timeliness plots."
    )
  }
  for (measure_name in names(timeliness_panels)) {
    deck <- .dr_prov_ppt_add_plot(
      deck,
      paste(measure_name, "-", prov_name),
      timeliness_panels[[measure_name]],
      content_layout, master
    )
  }


  # Environmental surveillance section and outputs
  deck <- officer::add_slide(deck, layout = title_layout, master = master)
  deck <- officer::ph_with(
    deck,

    value = paste("Environmental Surveillance -", prov_name),
    location = officer::ph_location_type("ctrTitle")
  )
  deck <- .dr_prov_ppt_add_plot(
    deck,
    paste("ES Sites and Detection 1 -", prov_name),
    prov_outputs$es_detection_chart,
    content_layout, master
  )
  deck <- .dr_prov_ppt_add_plot(
    deck,
    paste("ES Sites and Detection 2 -", prov_name),
    prov_outputs$es_location_map,
    content_layout, master
  )
  deck <- .dr_prov_ppt_add_plot(
    deck,
    paste("Timeliness of ES Sample Transport -", prov_name),
    prov_outputs$es_timeliness,
    content_layout, master
  )
  deck <- .dr_prov_ppt_add_table(
    deck,
    paste("ES Site Details -", prov_name),
    prov_outputs$es_site_table,
    content_layout, master
  )

  print(deck, target = ppt_output_file)
  invisible(normalizePath(ppt_output_file, winslash = "/", mustWork = TRUE))
}

#' Generate and write one prov AFP desk-review PowerPoint
#'
#' This is the one-call interface: it creates all prov figures and tables in
#' memory, then writes them to a PowerPoint. No separate figure files are
#' required.
#'
#' @param ctry.data Country data returned by `init_dr()`.
#' @param prov_name PROV name.
#' @param dist.extract District output from `f.npafp.rate.01()`.
#' @param pstool,dstool Province and district outputs from `f.stool.ad.01()`.
#' @param cases.need60day Output from `generate_60_day_table_data()`.
#' @param prov.shape,dist.shape Long-format PROV and DIST geometry.
#' @param start_date,end_date Analysis dates.
#' @param ppt_output_file Full output filename.
#' @param ppt_template_path Optional PowerPoint template path.
#' @param master,title_layout,content_layout Template master and layout names.
#' @param es_start_date,es_end_date ES analysis dates. Defaults to the year
#'   ending on `end_date`.
#' @returns The normalized path of the PowerPoint file, invisibly.
#' @export
generate_prov_desk_review_ppt <- function(
    ctry.data, prov_name, dist.extract, pstool, dstool, cases.need60day,
    prov.shape, dist.shape, start_date, end_date, ppt_output_file,
    ppt_template_path = NULL, master = "1_Office Theme",
    title_layout = "Title Slide", content_layout = "Title and Content",
    es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
    es_end_date = end_date) {
  prov_outputs <- generate_prov_desk_review_outputs(
    ctry.data = ctry.data,
    prov_name = prov_name,
    dist.extract = dist.extract,
    pstool = pstool,
    dstool = dstool,
    cases.need60day = cases.need60day,
    prov.shape = prov.shape,
    dist.shape = dist.shape,
    start_date = start_date,
    end_date = end_date,
    output_path = NULL,
    es_start_date = es_start_date,
    es_end_date = es_end_date
  )


  write_prov_desk_review_ppt(
    prov_outputs = prov_outputs,
    prov_name = prov_name,
    start_date = start_date,
    end_date = end_date,

    ppt_output_file = ppt_output_file,
    ppt_template_path = ppt_template_path,
    master = master,
    title_layout = title_layout,
    content_layout = content_layout
  )
}

#' Generate one AFP desk-review PowerPoint per prov
#'
#' @inheritParams generate_prov_desk_review_ppt
#' @param ppt_output_dir Existing directory where the prov decks are written.
#' @param prov_names Character vector of prov_names. Defaults to every prov returned by
#'   `list_desk_review_prov(ctry.data)`.
#' @returns A named character vector of generated PowerPoint paths.
#' @export
generate_all_prov_desk_review_ppts <- function(
    ctry.data, dist.extract, pstool, dstool, cases.need60day,
    prov.shape, dist.shape, start_date, end_date, ppt_output_dir,
    prov_names = list_desk_review_prov(ctry.data), ppt_template_path = NULL,
    master = "1_Office Theme", title_layout = "Title Slide",
    content_layout = "Title and Content",
    es_start_date = lubridate::as_date(es_end_date) - lubridate::years(1),
    es_end_date = end_date) {
  if (!dir.exists(ppt_output_dir)) {
    cli::cli_abort(paste0(
      "PowerPoint output directory does not exist: ", ppt_output_dir
    ))
  }
  if (length(prov_names) == 0) {
    cli::cli_abort("No prov_names were supplied.")
  }

  output_files <- character(length(prov_names))
  names(output_files) <- prov_names
  for (i in seq_along(prov_names)) {
    prov_name <- prov_names[[i]]
    output_file <- file.path(
      ppt_output_dir,
      paste0(
        "Deskreview_", .dr_prov_slug(prov_name), "_",
        format(Sys.Date(), "%d%m%Y"), ".pptx"
      )
    )
    output_files[[i]] <- generate_prov_desk_review_ppt(
      ctry.data = ctry.data,
      prov_name = prov_name,
      dist.extract = dist.extract,
      pstool = pstool,
      dstool = dstool,
      cases.need60day = cases.need60day,
      prov.shape = prov.shape,
      dist.shape = dist.shape,
      start_date = start_date,
      end_date = end_date,
      ppt_output_file = output_file,
      ppt_template_path = ppt_template_path,
      master = master,
      title_layout = title_layout,
      content_layout = content_layout,
      es_start_date = es_start_date,
      es_end_date = es_end_date
    )
  }

  invisible(output_files)
}

