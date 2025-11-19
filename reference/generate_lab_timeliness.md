# Summary of lab sample timeliness

Generates a summary of the timeliness of samples for specific intervals.

## Usage

``` r
generate_lab_timeliness(
  lab_data,
  spatial.scale,
  start_date,
  end_date,
  start.date = lifecycle::deprecated(),
  end.date = lifecycle::deprecated()
)
```

## Arguments

- lab_data:

  `tibble` Lab data. Ensure that this lab data is cleaned using
  [`clean_lab_data()`](https://cdcgov.github.io/sirfunctions/reference/clean_lab_data.md)
  before running the function.

- spatial.scale:

  `str` Spatial scale to analyze the data. Valid values are
  `"ctry", "prov", "all"`.

- start_date:

  `str` Start date of analysis.

- end_date:

  `str` End date of analysis.

- start.date:

  `str` **\[deprecated\]** renamed in favor of `start_date`.

- end.date:

  `str` **\[deprecated\]** renamed in favor of `end_date`.

## Value

`tibble` A table with timeliness data summary.

## Examples

``` r
if (FALSE) { # \dontrun{
lab_path <- "C:/Users/XRG9/lab_data_who.csv"
ctry.data <- init_dr("algeria", lab_data_path = lab_path)
ctry.data$lab_data <- clean_lab_data(ctry.data, "2021-01-01", "2023-12-31")
lab.timeliness.ctry <- generate_lab_timeliness(ctry.data$lab_data, "ctry", start_date, end_date)
} # }
```
