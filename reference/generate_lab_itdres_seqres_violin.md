# Timeliness of final ITD results to sequencing results

**\[experimental\]**

Shows the timeliness from date of ITD results to sequencing results. The
target is 7 days for cases not shipped for sequencing and 14 days for
samples shipped for sequencing.

## Usage

``` r
generate_lab_itdres_seqres_violin(
  lab_data,
  afp_data,
  start_date,
  end_date,
  priority_level = c("HIGH", "MEDIUM", "LOW (WATCHLIST)", "LOW"),
  who_region = NULL,
  rolling = TRUE,
  output_path = Sys.getenv("KPI_FIGURES"),
  y_max = 60
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

`ggplot` A violin plot showing the timeliness of sequencing results.

## Examples

``` r
if (FALSE) { # \dontrun{
raw_data <- get_all_polio_data()
lab_data <- edav_io("read", file_loc = get_constant("CLEANED_LAB_DATA"))
generate_lab_itdres_seqres_violin(lab_data, raw_data$afp,
                           "2021-01-01", "2023-12-31", getwd())
} # }
```
