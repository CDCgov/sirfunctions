# Maps of NPAFP rates by district and year

Generates maps of the NPAFP rates for each district per year.

## Usage

``` r
generate_npafp_maps_dist(
  dist.extract,
  ctry.shape,
  prov.shape,
  dist.shape,
  start_date,
  end_date,
  output_path = Sys.getenv("DR_FIGURE_PATH"),
  caption_size = 2
)
```

## Arguments

- dist.extract:

  `tibble` Province NPAFP rate table. This is the output of
  [`f.npafp.rate.01()`](https://cdcgov.github.io/sirfunctions/reference/f.npafp.rate.01.md)
  calculated at the province level.

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

  `str` Local path Where the figure is saved to.

- caption_size:

  `numeric` Size of the caption. Default is `2`.

## Value

`ggplot` A map of districts with their NPAFP rates.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
dist.extract <- f.npafp.rate.01(
  afp.data = ctry.data$afp.all.2,
  pop.data = ctry.data$prov.pop,
  start.date = start_date,
  end.date = end_date,
  spatial.scale = "dist",
  pending = T,
  rolling = F,
  sp_continuity_validation = F
)
ctry.shape <- load_clean_ctry_sp(ctry_name = "ALGERIA", type = "long")
prov.shape <- load_clean_prov_sp(ctry_name = "ALGERIA", type = "long")
dist.shape <- load_clean_dist_sp(ctry_name = "ALGERIA", type = "long")
generate_npafp_maps_dist(
  dist.extract, ctry.shape, prov.shape, dist.shape,
  "2021-01-01", "2023-12-31"
)
} # }
```
