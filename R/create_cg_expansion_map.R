
#' Function to create super regions from subsets of consequential geographies
#'
#' @param cg `tibble` table containing data about existing CGs, the dataset
#' is expected to contain the following headers: `type`, `label`, `ctry`, `prov`,
#' `dist`, `adm_level`. You can download an example dataset using:
#' sirfunctions_io("read", file_loc = "Data/misc/consequential_geographies.rds")
#' @param ctry `sp` country level spatial objects
#' @param prov `sp` province level spatial objects
#' @param dist `sp` district level spatial objects
#' @returns `sp` single spatial objects with all consequential geography
#' super regions
#' @examples
#' \dontrun{
#' create_cg_super_regions(cg = sirfunctions_io("read", file_loc = "Data/misc/consequential_geographies.rds"),
#' ctry = global.ctry, prov = global.prov, dist = global.dist)
#' }
create_cg_super_regions <- function(cg, ctry, prov, dist){

  cg_names <- cg |>
    dplyr::filter(type == "cg") |>
    dplyr::pull(label) |>
    unique()

  cg_super_regions <- lapply(cg_names, function(cg_name){

    level <- cg |>
      dplyr::filter(label == cg_name) |>
      dplyr::pull(adm_level) |>
      unique()

    if(level == "adm1"){
      region <- cg |>
        dplyr::filter(label == cg_name) |>
        dplyr::left_join(prov |> filter(yr.end == 9999) |> dplyr::select(ADM0_NAME, ADM1_NAME, GUID),
                         by = c("ctry" = "ADM0_NAME",
                                "prov" = "ADM1_NAME"))

      return(prov |>
        dplyr::filter(GUID %in% region$GUID) |>
        sf::st_union() |>
        sf::st_as_sf() |>
        dplyr::select(Shape = x) |>
        dplyr::mutate(name = cg_name,
                      adm_level = unique(region$adm_level),
                      GUIDs = paste0(region$GUID, collapse = ", ")))
    }

    if(level == "adm2"){
      region <- cg |>
        dplyr::filter(label == cg_name) |>
        dplyr::left_join(dist |> filter(yr.end == 9999) |> dplyr::select(ADM0_NAME, ADM1_NAME, ADM2_NAME, GUID),
                         by = c("ctry" = "ADM0_NAME",
                                "prov" = "ADM1_NAME",
                                "dist" = "ADM2_NAME"))

      return(dist |>
        dplyr::filter(GUID %in% region$GUID) |>
        sf::st_union() |>
        sf::st_as_sf() |>
        dplyr::select(Shape = x) |>
        dplyr::mutate(name = cg_name,
                      adm_level = unique(region$adm_level),
                      GUIDs = paste0(region$GUID, collapse = ", ")))
    }
  }) |>
    dplyr::bind_rows()

  return(cg_super_regions)
}

#' Function to flag positives data from identified consequential geographies
#'
#' @param cg_super_regions `sp` spatial object of all CG super regions and a
#' flag for all their specific GUIDs
#' @param pos `tibble` the positives file from `polio.data`
#' @param start.year `int` the the earliest year for analysis, defaults to 2016
#' @returns `sp` all cg related positives flagged and ready for mapping
#' @examples
#' \dontrun{
#' flag_cg_positives(cg_super_regions, pos)
#' }
flag_cg_positives <- function(cg_super_regions, pos, start.year = 2016){

  earliest_emergences <- pos |>
    dplyr::filter(!is.na(emergencegroup)) |>
    dplyr::select(dateonset, adm1guid, admin2guid, emergencegroup, yronset) |>
    dplyr::group_by(emergencegroup) |>
    dplyr::filter(dateonset == min(dateonset)) |>
    dplyr::ungroup() |>
    dplyr::filter(yronset >= start.year)

  pos_dets <- lapply(1:nrow(cg_super_regions), function(x){

    current_region <- cg_super_regions |>
      dplyr::slice(x)


    guids <- current_region |>
      dplyr::pull(GUIDs) |>
      str_split(", ") |>
      unlist()

    adm_level <- current_region |>
      dplyr::pull(adm_level)

    if(adm_level == "adm1"){

      emergences <- earliest_emergences |>
        dplyr::filter(adm1guid %in% guids) |>
        dplyr::pull(emergencegroup) |>
        unique()

      return(pos |>
               dplyr::filter(emergencegroup %in% emergences) |>
               dplyr::select(latitude, longitude, adm1guid) |>
               tidyr::drop_na() |>
               dplyr::mutate(in_cg = adm1guid %in% guids,
                             cg_label = current_region$name) |>
               sf::st_as_sf(coords = c(x = "longitude", y = "latitude")))

    }

    if(adm_level == "adm2"){

      emergences <- earliest_emergences |>
        dplyr::filter(admin2guid %in% guids) |>
        dplyr::pull(emergencegroup) |>
        unique()

      return(pos |>
               dplyr::filter(emergencegroup %in% emergences) |>
               dplyr::select(latitude, longitude, admin2guid) |>
               tidyr::drop_na() |>
               dplyr::mutate(in_cg = admin2guid %in% guids,
                             cg_label = current_region$name) |>
               sf::st_as_sf(coords = c(x = "longitude", y = "latitude")))

    }

  }) |>
    dplyr::bind_rows()

  sf::st_crs(pos_dets) <- sf::st_crs(cg_super_regions)

  return(pos_dets)

}

#' Function to create the consequential geography expansion map
#'
#'
#' @param polio.data `list` SIR polio data rds
#' @param cg `tibble` table containing data about existing CGs, the dataset
#' is expected to contain the following headers: `type`, `label`, `ctry`, `prov`,
#' `dist`, `adm_level`. You can download an example dataset using:
#' sirfunctions_io("read", file_loc = "Data/misc/consequential_geographies.rds")
#' originating from this CG super region
#' @returns `ggplot` CG expansion map
#' @export
create_cg_expansion_map <- function(polio.data, cg){

  ctry <- polio.data$global.ctry
  prov <- polio.data$global.prov
  dist <- polio.data$global.dist

  cg_super_regions <- create_cg_super_regions(cg = cg, ctry = ctry, prov = prov, dist = dist)

  pos_cg_dets <- flag_cg_positives(cg_super_regions = cg_super_regions, pos = polio.data$pos)

  bbox <- sf::st_bbox(pos_cg_dets)

  bbox["xmin"] <- bbox["xmin"] - (100000 / 6370000) * (180 / pi) / cos(bbox["xmin"] * pi / 180)
  bbox["xmax"] <- bbox["xmax"] + (100000 / 6370000) * (180 / pi) / cos(bbox["xmax"] * pi / 180)
  bbox["ymin"] <- bbox["ymin"] - (100000 / 6370000) * (180 / pi)
  bbox["ymax"] <- bbox["ymax"] + (100000 / 6370000) * (180 / pi)

  pos_cg_dets2 <- pos_cg_dets |>
    dplyr::mutate(in_cg = ifelse(in_cg, "In CG", "Out of CG"))

  plot <- ggplot2::ggplot() +
    ggplot2::geom_sf(data = ctry |> dplyr::filter(yr.end == 9999), fill = NA) +
    ggplot2::geom_sf(data = pos_cg_dets2, aes(color = cg_label, alpha = in_cg), size = 0.5) +
    ggplot2::geom_sf(data = cg_super_regions, aes(color = name), linewidth = 0.5, fill = NA) +
    ggplot2::coord_sf(xlim = bbox[c("xmin", "xmax")], ylim = bbox[c("ymin", "ymax")]) +
    ggplot2::scale_alpha_manual(values = c(1, 0.3)) +
    ggplot2::scale_color_brewer(palette = "Dark2", direction = -1) +
    ggplot2::theme_void() +
    ggplot2::labs(color = "Consequential Geography", alpha = "Location",
                  title = "Consequential geographies and the global footprint of emergences from those regions") +
    ggplot2::theme(legend.position = "bottom",
                   legend.box.background = element_rect(color = "black")) +
    ggplot2::guides(alpha = ggplot2::guide_legend(nrow=2,byrow=T),
                    color = ggplot2::guide_legend(nrow=3,byrow=T))

  return(plot)

}
