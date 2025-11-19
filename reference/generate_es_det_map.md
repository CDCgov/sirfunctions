# ES detection map

Generates a map showing the detection rate of each ES sites on a rolling
period as defined by the start and end dates of the analysis.

## Usage

``` r
generate_es_det_map(
  es.data,
  ctry.shape,
  prov.shape,
  es_start_date = (lubridate::as_date(es_end_date) - lubridate::years(1)),
  es_end_date = end_date,
  output_path = Sys.getenv("DR_FIGURE_PATH"),
  es.data.long = lifecycle::badge("deprecated")
)
```

## Arguments

- es.data:

  `tibble` ES data for a country. This is `ctry.data$es`, which is part
  of the outputs of
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  and
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- ctry.shape:

  `sf` Country shapefile in long format.

- prov.shape:

  `sf` Province shapefile in long format.

- es_start_date:

  `str` Start date of analysis. Default is one year from the end date.

- es_end_date:

  `str` End date of analysis.

- output_path:

  `str` Local path where to save the figure to.

- es.data.long:

  **\[deprecated\]** `tibble` Please pass the output of
  [`clean_es_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_es_data.md)
  into es.data instead. This paramater is not being used in the
  function.

## Value

`ggplot` Map of EV detection rates for the environmental surveillance
sites.

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
es.data.long <- generate_es_data_long(ctry.data$es)
ctry.shape <- load_clean_ctry_sp(ctry_name = "ALGERIA", type = "long")
prov.shape <- load_clean_prov_sp(ctry_name = "ALGERIA", type = "long")
generate_es_det_map(ctry.data$es, ctry.shape, prov.shape,
  es_end_date = "2023-01-01"
)
} # }
```
