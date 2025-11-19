# Stool adequacy maps by province

Generates maps that contain the stool adequacy rate for each province
per year.

## Usage

``` r
generate_stool_ad_maps(
  ctry.data,
  pstool,
  ctry.shape,
  prov.shape,
  start_date,
  end_date,
  output_path = Sys.getenv("DR_FIGURE_PATH"),
  caption_size = 3
)
```

## Arguments

- ctry.data:

  `list` Large list containing polio data of a country. This is the
  output of either
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- pstool:

  `tibble` Stool adequacy table at province level. This is the output of
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md)
  calculated at the province level.

- ctry.shape:

  `sf` Country shapefile in long format.

- prov.shape:

  `sf` Province shapefile in long format.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- output_path:

  `str` Where to save the figure to.

- caption_size:

  `numeric` Size of the caption. Defaults to 3.

## Value

`ggplot` A map of stool adequacy rates for each province by year.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
pstool <- f.stool.ad.01(
  afp.data = ctry.data$afp.all.2,
  admin.data = ctry.data$prov.pop,
  start.date = start_date,
  end.date = end_date,
  spatial.scale = "prov",
  missing = "good",
  bad.data = "inadequate",
  rolling = F,
  sp_continuity_validation = F
)
ctry.shape <- load_clean_ctry_sp(ctry_name = "ALGERIA", type = "long")
prov.shape <- load_clean_prov_sp(ctry_name = "ALGERIA", type = "long")
generate_stool_ad_maps(ctry.data, pstool, ctry.shape, prov.shape, "2021-01-01", "2023-12-31")
} # }
```
