
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


