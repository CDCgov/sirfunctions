# Generate district level stool adequacy maps

**\[experimental\]**

Generates a map of district level stool adequacy maps

## Usage

``` r
generate_kpi_stool_map(
  c2,
  year_label,
  who_region = NULL,
  risk_category = NULL,
  output_path = Sys.getenv("KPI_FIGURES"),
  ctry_sf = NULL,
  dist_sf = NULL
)
```

## Arguments

- c2:

  `tibble` Output of
  [`generate_c2_table()`](https://cdcgov.github.io/sirfunctions/reference/generate_c2_table.md).

- year_label:

  `str` Roll up year (i.e., `"Year 1", "Year 2", ...`).

- who_region:

  `str` A WHO region or a list of regions. Valid values are:

  - `"AFRO"`: African Region

  - `"AMRO"`: Region of the Americas

  - `"EMRO"`: Eastern Mediterranean Region

  - `"EURO"`: European Region

  - `"SEARO"`:South-East Asia Region

  - `"WPRO"`:Western Pacific Region

- risk_category:

  `str` A string or a list of strings with priority categories. Valid
  values are: "LOW", "LOW (WATCHLIST)", "MEDIUM", "HIGH".

- output_path:

  `str` Where to output the figure to. Defaults to the path initialized
  when
  [`init_kpi()`](https://cdcgov.github.io/sirfunctions/reference/init_kpi.md)
  was ran.

- ctry_sf:

  `sf` Country shapefile in long format. Output of
  [`load_clean_ctry_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_ctry_sp.md)
  with `type = "long"`. Defaults to `NULL`, which will download the
  required country shapefile when the function is ran.

- dist_sf:

  `sf` District shapefile in long format. Output of
  [`load_clean_dist_sp()`](https://cdcgov.github.io/sirfunctions/reference/load_clean_dist_sp.md)
  with `type = "long"`. Defaults to `NULL`, which will download the
  required district shapefile when the function is ran.

## Value

`ggplot` A stool adequacy map.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data()
c2 <- generate_c2_table(raw_data$afp, raw_data$dist, "2021-01-01",
"2023-12-31", c("ctry", "dist", "adm2guid", "year"))
map <- generate_kpi_stool_map(c2, "Year 1", "AFRO", output_path = getwd())
} # }
```
