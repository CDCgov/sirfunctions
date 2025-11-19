# EV detection rate map

**\[experimental\]**

Generates a map of EV detection rates for each environmental
surveillance site.

## Usage

``` r
generate_kpi_ev_map(
  c3,
  .year_label,
  who_region = NULL,
  output_path = Sys.getenv("KPI_FIGURES"),
  dot_size = 2.3,
  ctry_sf = NULL
)
```

## Arguments

- c3:

  `tibble` Output of
  [`generate_c3_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c3_table.md).
  This must be summarized at the site level (i.e., use the default
  `.group_by`) param of the
  [`generate_c3_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c3_table.md).

- .year_label:

  `str` Roll up year (i.e., `"Year 1", "Year 2", ...`).

- who_region:

  `str` Name of the region or a list of regions.

- output_path:

  `str` Where to output the figure to. Defaults to the figure path
  assigned after running
  [`init_kpi()`](https://cdcgov.github.io/sirfunctions/reference/init_kpi.md).

- dot_size:

  `num` Point size.

- ctry_sf:

  `sf` Country shapefile in long format. Output of
  [`load_clean_ctry_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_ctry_sp.md)
  with `type = "long"`. Defaults to `NULL`, which will download the
  required country shapefile when the function is ran.

## Value

`ggplot` A map showing EV detection rate by site.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data()
c3 <- generate_c3_table(raw_data$es, "2021-01-01", "2023-12-31")
map <- generate_kpi_ev_map(c3, "Year 1", "AFRO", getwd())
} # }
```
