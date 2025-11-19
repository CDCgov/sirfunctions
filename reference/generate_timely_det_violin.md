# Timely detection of AFP/ES samples

**\[experimental\]**

Generates a violin plot highlighting the median detection time of
samples.

## Usage

``` r
generate_timely_det_violin(
  raw_data,
  start_date,
  end_date,
  priority_level = c("HIGH", "MEDIUM", "LOW (WATCHLIST)", "LOW"),
  who_region = NULL,
  rolling = TRUE,
  output_path = Sys.getenv("KPI_FIGURES"),
  y_max = 250
)
```

## Arguments

- raw_data:

  `list` Global polio data. Output of
  [`get_all_polio_data()`](https://cdcgov.github.io/sirfunctions/reference/get_all_polio_data.md)

- start_date:

  `str` Analysis start date formatted as "YYYY-MM-DD".

- end_date:

  `str` Analysis end date formatted as "YYYY-MM-DD".

- priority_level:

  `list` Priority levels to display. Defaults to
  `c("HIGH", "MEDIUM", "LOW (WATCHLIST)", "LOW")`.

- who_region:

  `list` Regions to display. Defaults to `NULL`, which shows all of the
  regions.

- rolling:

  `logical` Using rolling periods or year-to-year? Defaults to `TRUE`.

- output_path:

  `str` Where to output the figure to.

- y_max:

  `num` The maximum y-axis value.

## Value

`ggplot` A violin plot showing timeliness of detection.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data()
generate_timely_det_violin(raw_data, "2021-01-01", "2023-12-31")
} # }
```
