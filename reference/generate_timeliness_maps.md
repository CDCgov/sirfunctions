# Maps evaluating timeliness of samples against timeliness targets.

Generates a map at the provincial level summarizing the timeliness of
samples across different timeliness targets. The figure is faceted by
the type of timeliness target, with each facet containing the percentage
of samples from each province that met the targets over the years.

## Usage

``` r
generate_timeliness_maps(
  ctry.data,
  ctry.shape,
  prov.shape,
  start_date,
  end_date,
  mark_x = T,
  pt_size = 4,
  output_path = Sys.getenv("DR_FIGURE_PATH")
)
```

## Arguments

- ctry.data:

  `list` Large list containing polio data for a country. This is the
  output of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  or
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- ctry.shape:

  `sf` Country shapefile in long format.

- prov.shape:

  `sf` Province shapefile in long format.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- mark_x:

  `logical` Mark where there are less than 5 AFP cases? Defaults to
  `TRUE`.

- pt_size:

  `numeric` Size of the marks.

- output_path:

  `str` Local path where to save the figure to.

## Value

`ggplot` Faceted map of each province evaluated against timeliness
targets across years.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
ctry.shape <- load_clean_ctry_sp(ctry_name = "ALGERIA", type = "long")
prov.shape <- load_clean_prov_sp(ctry_name = "ALGERIA", type = "long")
generate_timeliness_maps(ctry.data, ctry.shape, prov.shape, "2021-01-01", "2023-12-31")
} # }
```
