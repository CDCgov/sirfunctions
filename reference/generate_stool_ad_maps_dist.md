# Maps of stool adequacy by district and year

Generates maps of stool adequacy map by district and year.

## Usage

``` r
generate_stool_ad_maps_dist(
  ctry.data,
  dstool,
  ctry.shape,
  prov.shape,
  dist.shape,
  start_date,
  end_date,
  output_path = Sys.getenv("DR_FIGURE_PATH"),
  caption_size = 3
)
```

## Arguments

- ctry.data:

  `list` Large list containing polio data for a country. This is the
  output of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- dstool:

  `tibble` District stool adequacy table. This is the output of
  [`f.stool.ad.01()`](https://cdcgov.github.io/sirfunctions/reference/f.stool.ad.01.md)
  calculated at the district level.

- ctry.shape:

  `sf` Country shapefile in long format.

- prov.shape:

  `sf` Province shapefile in long format.

- dist.shape:

  `sf` District shapefile in long format.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- output_path:

  `str` Local path where to save the figure to.

- caption_size:

  `numeric` Size of the caption. Defaults to 3.

## Value

`ggplot` Maps of stool adequacy rates for each district by year.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
dstool <- f.stool.ad.01(
  afp.data = ctry.data$afp.all.2,
  admin.data = ctry.data$dist.pop,
  start.date = start_date,
  end.date = end_date,
  spatial.scale = "dist",
  missing = "good",
  bad.data = "inadequate",
  rolling = F,
  sp_continuity_validation = F
)
ctry.shape <- load_clean_ctry_sp(ctry_name = "ALGERIA", type = "long")
prov.shape <- load_clean_prov_sp(ctry_name = "ALGERIA", type = "long")
dist.shape <- load_clean_dist_sp(ctry_name = "ALGERIA", type = "long")
generate_stool_ad_maps_dist(
  ctry.data, dstool,
  ctry.shape, prov.shape, dist.shape,
  "2021-01-01", "2023-12-31"
)
} # }
```
