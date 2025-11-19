# Timeliness of virus isolation to ITD results

**\[experimental\]**

Shows the timeliness of ITD results of specimens that require ITD. The
target is 7 days or less.

## Usage

``` r
generate_lab_itd_violin(
  lab_data,
  afp_data,
  start_date,
  end_date,
  priority_level = c("HIGH", "MEDIUM", "LOW (WATCHLIST)", "LOW"),
  who_region = NULL,
  rolling = TRUE,
  output_path = Sys.getenv("KPI_FIGURES"),
  y_max = 30
)
```

## Arguments

- lab_data:

  `tibble` Global lab dataset.

- afp_data:

  `tibble` AFP dataset.

- start_date:

  `str` Start date of the analysis formatted as "YYYY-MM-DD".

- end_date:

  `str` End date of the analysis formatted as "YYYY-MM-DD".

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

  `num` Maximum value in the y-axis.

## Value

`ggplot` A violin plot showing timeliness of ITD results from lab
culture.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data()
lab_data <- edav_io("read", file_loc = get_constant("CLEANED_LAB_DATA"))
generate_lab_itd_violin(lab_data, raw_data$afp,
                        "2021-01-01", "2023-12-31", getwd())
} # }
```
