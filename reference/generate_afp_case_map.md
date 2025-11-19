# AFP case map

Generates a map of AFP cases, excluding any with pending classification.

## Usage

``` r
generate_afp_case_map(
  afp.all,
  ctry.shape,
  prov.shape,
  start_date,
  end_date = lubridate::today(),
  output_path = Sys.getenv("DR_FIGURE_PATH")
)
```

## Arguments

- afp.all:

  `sf` AFP linelist containing point geometry. This is
  `ctry.data$afp.all`, which is an output of either
  [`extract_country_data()`](https://cdcgov.github.io/sirfunctions/reference/extract_country_data.md)
  and
  [`init_dr()`](https://cdcgov.github.io/sirfunctions/reference/init_dr.md).

- ctry.shape:

  `sf` Country shapefile in long format.

- prov.shape:

  `sf` Province shapefile in long format.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis. Default is today's date.

- output_path:

  `str` Local path where to save the figure to.

## Value

`ggplot` Map of AFP cases.

## See also

[`load_clean_ctry_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_ctry_sp.md),
[`load_clean_prov_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_prov_sp.md)

## Examples

``` r
if (FALSE) { # \dontrun{
ctry.data <- init_dr("algeria")
ctry.shape <- load_clean_ctry_sp(ctry_name = "ALGERIA", type = "long")
prov.shape <- load_clean_prov_sp(ctry_name = "ALGERIA", type = "long")
generate_afp_case_map(ctry.data, ctry.shape, prov.shape, "2023-12-31")
} # }
```
