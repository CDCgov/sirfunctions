# SG Prioritization Map

**\[experimental\]**

Creates a map showing the SG prioritization map.

## Usage

``` r
generate_sg_priority_map(
  ctry_risk_cat = NULL,
  year = lubridate::year(Sys.Date()),
  ctry_sf = NULL,
  output_path = Sys.getenv("KPI_FIGURES")
)
```

## Arguments

- ctry_risk_cat:

  `tibble` Risk category for each country. Defaults to `NULL`, which
  downloads the SG risk category data set from EDAV.

- year:

  `tibble` Active year for the country shape files.

- ctry_sf:

  `sf` Country shapefile in long format.

- output_path:

  `str` Where to output the figure to. Defaults to the path to the
  figures folder set when running
  [`init_kpi()`](https://cdcgov.github.io/sirfunctions/reference/init_kpi.md).

## Value

`ggplot` A map.

## Examples

``` r
if (FALSE) { # \dontrun{
sg_priority_map(output_path = getwd())
} # }
```
